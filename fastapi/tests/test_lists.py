"""Tests for list endpoints."""

import pytest
from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import User, List as ListModel


@pytest.mark.asyncio
class TestReadLists:
    """Tests for reading lists endpoint."""

    async def test_read_lists_authenticated(
        self,
        client: AsyncClient,
        test_user: User,
        test_list: ListModel,
        auth_headers: dict,
        test_db: AsyncSession,
    ):
        """Test reading lists when authenticated."""
        response = await client.get("/api/lists/", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) >= 1

        # Verify list data structure
        list_data = data[0]
        assert "list_id" in list_data
        assert "title" in list_data
        assert "description" in list_data
        assert "item_count" in list_data

        # Verify data matches database
        result = await test_db.execute(
            select(ListModel).where(ListModel.user_id == test_user.user_id)
        )
        db_lists = result.scalars().all()
        assert len(data) == len(db_lists)
        assert str(data[0]["list_id"]) == str(test_list.list_id)
        assert data[0]["title"] == test_list.title

    async def test_read_lists_unauthenticated(self, client: AsyncClient):
        """Test reading lists without authentication fails."""
        response = await client.get("/api/lists/")
        assert response.status_code == 401

    async def test_read_lists_only_own_lists(
        self,
        client: AsyncClient,
        test_user: User,
        test_user2: User,
        test_list: ListModel,
        auth_headers: dict,
        auth_headers_user2: dict,
        test_db: AsyncSession,
    ):
        """Test that users only see their own lists."""
        # Verify test_list belongs to test_user in database
        result = await test_db.execute(
            select(ListModel).where(ListModel.list_id == test_list.list_id)
        )
        db_list = result.scalar_one()
        assert db_list.user_id == test_user.user_id

        # User 1 should see their list
        response = await client.get("/api/lists/", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert len(data) >= 1
        assert str(data[0]["user_id"]) == str(test_user.user_id)

        # User 2 should not see user 1's lists
        response = await client.get("/api/lists/", headers=auth_headers_user2)
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 0

        # Verify test_user2 has no lists in database
        result = await test_db.execute(
            select(ListModel).where(ListModel.user_id == test_user2.user_id)
        )
        user2_lists = result.scalars().all()
        assert len(user2_lists) == 0

    async def test_read_lists_pagination(
        self,
        client: AsyncClient,
        test_user: User,
        test_list: ListModel,
        auth_headers: dict,
    ):
        """Test lists pagination."""
        # Test with limit
        response = await client.get("/api/lists/?limit=1", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert len(data) <= 1

        # Test with skip
        response = await client.get("/api/lists/?skip=1", headers=auth_headers)
        assert response.status_code == 200


@pytest.mark.asyncio
class TestCreateList:
    """Tests for creating lists endpoint."""

    async def test_create_list_success(
        self,
        client: AsyncClient,
        test_user: User,
        auth_headers: dict,
        test_db: AsyncSession,
    ):
        """Test successful list creation."""
        response = await client.post(
            "/api/lists/",
            params={
                "name": "My New List",
                "description": "A brand new list",
            },
            headers=auth_headers,
        )
        assert response.status_code == 200
        data = response.json()
        assert data["title"] == "My New List"
        assert data["description"] == "A brand new list"
        assert "list_id" in data
        assert str(data["user_id"]) == str(test_user.user_id)

        # Verify list was created in database
        result = await test_db.execute(
            select(ListModel).where(ListModel.title == "My New List")
        )
        db_list = result.scalar_one_or_none()
        assert db_list is not None
        assert db_list.title == "My New List"
        assert db_list.description == "A brand new list"
        assert db_list.user_id == test_user.user_id
        assert str(db_list.list_id) == data["list_id"]

    async def test_create_list_unauthenticated(self, client: AsyncClient):
        """Test creating list without authentication fails."""
        response = await client.post(
            "/api/lists/",
            params={
                "name": "My New List",
                "description": "A brand new list",
            },
        )
        assert response.status_code == 401

    async def test_create_list_duplicate_title(
        self, client: AsyncClient, test_list: ListModel, auth_headers: dict
    ):
        """Test creating list with duplicate title fails."""
        response = await client.post(
            "/api/lists/",
            params={
                "name": test_list.title,
                "description": "Different description",
            },
            headers=auth_headers,
        )
        assert response.status_code == 409
        assert "already exists" in response.json()["detail"].lower()

    async def test_create_list_empty_description(
        self, client: AsyncClient, auth_headers: dict
    ):
        """Test creating list with empty description."""
        response = await client.post(
            "/api/lists/",
            params={
                "name": "List Without Description",
                "description": "",
            },
            headers=auth_headers,
        )
        assert response.status_code == 200
        data = response.json()
        assert data["title"] == "List Without Description"


@pytest.mark.asyncio
class TestReadList:
    """Tests for reading a specific list endpoint."""

    async def test_read_list_success(
        self, client: AsyncClient, test_list: ListModel, auth_headers: dict
    ):
        """Test reading a specific list."""
        response = await client.get(
            f"/api/lists/{test_list.list_id}", headers=auth_headers
        )
        assert response.status_code == 200
        data = response.json()
        assert str(data["list_id"]) == str(test_list.list_id)
        assert data["title"] == test_list.title
        assert data["description"] == test_list.description

    async def test_read_list_unauthenticated(
        self, client: AsyncClient, test_list: ListModel
    ):
        """Test reading a list without authentication fails."""
        response = await client.get(f"/api/lists/{test_list.list_id}")
        assert response.status_code == 401

    async def test_read_list_not_found(self, client: AsyncClient, auth_headers: dict):
        """Test reading non-existent list fails."""
        import uuid

        fake_id = uuid.uuid4()
        response = await client.get(f"/api/lists/{fake_id}", headers=auth_headers)
        assert response.status_code == 404

    async def test_read_list_wrong_user(
        self,
        client: AsyncClient,
        test_list: ListModel,
        auth_headers_user2: dict,
    ):
        """Test reading another user's list fails."""
        response = await client.get(
            f"/api/lists/{test_list.list_id}", headers=auth_headers_user2
        )
        assert response.status_code == 404


@pytest.mark.asyncio
class TestUpdateList:
    """Tests for updating lists endpoint."""

    async def test_update_list_success(
        self,
        client: AsyncClient,
        test_list: ListModel,
        auth_headers: dict,
        test_db: AsyncSession,
    ):
        """Test successful list update."""
        original_title = test_list.title
        original_description = test_list.description

        response = await client.put(
            f"/api/lists/{test_list.list_id}",
            json={
                "title": "Updated Title",
                "description": "Updated description",
            },
            headers=auth_headers,
        )
        assert response.status_code == 200
        data = response.json()
        assert data["title"] == "Updated Title"
        assert data["description"] == "Updated description"
        assert str(data["list_id"]) == str(test_list.list_id)

        # Verify list was updated in database
        await test_db.refresh(test_list)
        assert test_list.title == "Updated Title"
        assert test_list.description == "Updated description"
        assert test_list.title != original_title
        assert test_list.description != original_description

    async def test_update_list_partial(
        self, client: AsyncClient, test_list: ListModel, auth_headers: dict
    ):
        """Test partial list update (only title)."""
        _original_description = test_list.description  # noqa: F841
        response = await client.put(
            f"/api/lists/{test_list.list_id}",
            json={
                "title": "New Title Only",
            },
            headers=auth_headers,
        )
        assert response.status_code == 200
        data = response.json()
        assert data["title"] == "New Title Only"

    async def test_update_list_unauthenticated(
        self, client: AsyncClient, test_list: ListModel
    ):
        """Test updating list without authentication fails."""
        response = await client.put(
            f"/api/lists/{test_list.list_id}",
            json={
                "title": "Updated Title",
            },
        )
        assert response.status_code == 401

    async def test_update_list_not_found(self, client: AsyncClient, auth_headers: dict):
        """Test updating non-existent list fails."""
        import uuid

        fake_id = uuid.uuid4()
        response = await client.put(
            f"/api/lists/{fake_id}",
            json={
                "title": "Updated Title",
            },
            headers=auth_headers,
        )
        assert response.status_code == 404

    async def test_update_list_wrong_user(
        self,
        client: AsyncClient,
        test_list: ListModel,
        auth_headers_user2: dict,
    ):
        """Test updating another user's list fails."""
        response = await client.put(
            f"/api/lists/{test_list.list_id}",
            json={
                "title": "Trying to update",
            },
            headers=auth_headers_user2,
        )
        assert response.status_code == 404


@pytest.mark.asyncio
class TestDeleteList:
    """Tests for deleting lists endpoint."""

    async def test_delete_list_success(
        self,
        client: AsyncClient,
        test_list: ListModel,
        auth_headers: dict,
        test_db: AsyncSession,
    ):
        """Test successful list deletion."""
        list_id = test_list.list_id

        # Verify list exists in database before deletion
        result = await test_db.execute(
            select(ListModel).where(ListModel.list_id == list_id)
        )
        assert result.scalar_one_or_none() is not None

        response = await client.delete(f"/api/lists/{list_id}", headers=auth_headers)
        assert response.status_code == 204

        # Verify list is deleted from database
        result = await test_db.execute(
            select(ListModel).where(ListModel.list_id == list_id)
        )
        assert result.scalar_one_or_none() is None

        # Verify list is deleted via API
        response = await client.get(f"/api/lists/{list_id}", headers=auth_headers)
        assert response.status_code == 404

    async def test_delete_list_unauthenticated(
        self, client: AsyncClient, test_list: ListModel
    ):
        """Test deleting list without authentication fails."""
        response = await client.delete(f"/api/lists/{test_list.list_id}")
        assert response.status_code == 401

    async def test_delete_list_not_found(self, client: AsyncClient, auth_headers: dict):
        """Test deleting non-existent list fails."""
        import uuid

        fake_id = uuid.uuid4()
        response = await client.delete(f"/api/lists/{fake_id}", headers=auth_headers)
        assert response.status_code == 404

    async def test_delete_list_wrong_user(
        self,
        client: AsyncClient,
        test_list: ListModel,
        auth_headers_user2: dict,
    ):
        """Test deleting another user's list fails."""
        response = await client.delete(
            f"/api/lists/{test_list.list_id}", headers=auth_headers_user2
        )
        assert response.status_code == 404
