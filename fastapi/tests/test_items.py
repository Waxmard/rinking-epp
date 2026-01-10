"""Tests for item endpoints."""

import pytest
from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import List as ListModel, Item as ItemModel


@pytest.mark.asyncio
class TestCreateItem:
    """Tests for creating items endpoint."""

    async def test_create_first_item_success(
        self,
        client: AsyncClient,
        test_list: ListModel,
        auth_headers: dict,
        test_db: AsyncSession,
    ):
        """Test creating first item in an empty list."""
        response = await client.post(
            "/api/items/",
            params={"list_title": test_list.title},
            json={
                "name": "First Item",
                "description": "The first item",
                "image_url": "https://example.com/first.jpg",
            },
            headers=auth_headers,
        )
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "First Item"
        assert data["description"] == "The first item"
        assert "item_id" in data

        # Verify item was created in database
        result = await test_db.execute(
            select(ItemModel).where(ItemModel.list_id == test_list.list_id)
        )
        db_items = result.scalars().all()
        assert len(db_items) == 1
        assert db_items[0].name == "First Item"
        assert db_items[0].description == "The first item"
        assert db_items[0].list_id == test_list.list_id
        assert str(db_items[0].item_id) == data["item_id"]

    async def test_create_second_item_starts_comparison(
        self,
        client: AsyncClient,
        test_list: ListModel,
        test_item: ItemModel,
        auth_headers: dict,
        test_db: AsyncSession,
    ):
        """Test creating second item starts a comparison session."""
        # Verify we start with 1 item in database
        result = await test_db.execute(
            select(ItemModel).where(ItemModel.list_id == test_list.list_id)
        )
        items_before = result.scalars().all()
        assert len(items_before) == 1

        response = await client.post(
            "/api/items/",
            params={"list_title": test_list.title},
            json={
                "name": "Second Item",
                "description": "The second item",
                "image_url": "https://example.com/second.jpg",
            },
            headers=auth_headers,
        )
        assert response.status_code == 200
        data = response.json()
        # Should return a ComparisonSession
        assert "session_id" in data
        assert "current_comparison" in data
        assert data["is_complete"] is False
        # Verify comparison data
        comparison = data["current_comparison"]
        assert "reference_item" in comparison
        assert "target_item" in comparison
        assert comparison["reference_item"]["name"] == "Second Item"

        # Note: Second item is NOT yet committed to database during comparison
        # It will only be saved when comparison is complete
        result = await test_db.execute(
            select(ItemModel).where(ItemModel.list_id == test_list.list_id)
        )
        items_after = result.scalars().all()
        assert len(items_after) == 1  # Still only 1 item until comparison completes

    async def test_create_item_unauthenticated(
        self, client: AsyncClient, test_list: ListModel
    ):
        """Test creating item without authentication fails."""
        response = await client.post(
            "/api/items/",
            params={"list_title": test_list.title},
            json={
                "name": "New Item",
                "description": "Description",
                "image_url": "https://example.com/image.jpg",
            },
        )
        assert response.status_code == 401

    async def test_create_item_list_not_found(
        self, client: AsyncClient, auth_headers: dict
    ):
        """Test creating item in non-existent list fails."""
        response = await client.post(
            "/api/items/",
            params={"list_title": "Nonexistent List"},
            json={
                "name": "New Item",
                "description": "Description",
                "image_url": "https://example.com/image.jpg",
            },
            headers=auth_headers,
        )
        assert response.status_code == 404

    async def test_create_item_wrong_user_list(
        self, client: AsyncClient, test_list: ListModel, auth_headers_user2: dict
    ):
        """Test creating item in another user's list fails."""
        response = await client.post(
            "/api/items/",
            params={"list_title": test_list.title},
            json={
                "name": "New Item",
                "description": "Description",
                "image_url": "https://example.com/image.jpg",
            },
            headers=auth_headers_user2,
        )
        assert response.status_code == 404


@pytest.mark.asyncio
class TestComparisonFlow:
    """Tests for comparison workflow."""

    async def test_submit_comparison_result_better(
        self,
        client: AsyncClient,
        test_list: ListModel,
        test_item: ItemModel,
        auth_headers: dict,
    ):
        """Test submitting comparison result where new item is better."""
        # Create second item to start comparison
        create_response = await client.post(
            "/api/items/",
            params={"list_title": test_list.title},
            json={
                "name": "Better Item",
                "description": "A better item",
                "image_url": "https://example.com/better.jpg",
            },
            headers=auth_headers,
        )
        assert create_response.status_code == 200
        session_data = create_response.json()
        session_id = session_data["session_id"]

        # Submit comparison result
        response = await client.post(
            "/api/items/comparison/result",
            params={"session_id": session_id},
            json={"result": "better"},
            headers=auth_headers,
        )
        assert response.status_code == 200

    async def test_submit_comparison_result_worse(
        self,
        client: AsyncClient,
        test_list: ListModel,
        test_item: ItemModel,
        auth_headers: dict,
    ):
        """Test submitting comparison result where new item is worse."""
        # Create second item to start comparison
        create_response = await client.post(
            "/api/items/",
            params={"list_title": test_list.title},
            json={
                "name": "Worse Item",
                "description": "A worse item",
                "image_url": "https://example.com/worse.jpg",
            },
            headers=auth_headers,
        )
        assert create_response.status_code == 200
        session_data = create_response.json()
        session_id = session_data["session_id"]

        # Submit comparison result
        response = await client.post(
            "/api/items/comparison/result",
            params={"session_id": session_id},
            json={"result": "worse"},
            headers=auth_headers,
        )
        assert response.status_code == 200

    async def test_submit_comparison_invalid_session(
        self, client: AsyncClient, auth_headers: dict
    ):
        """Test submitting comparison with invalid session fails."""
        response = await client.post(
            "/api/items/comparison/result",
            params={"session_id": "invalid_session"},
            json={"result": "better"},
            headers=auth_headers,
        )
        assert response.status_code == 404

    async def test_get_comparison_status(
        self,
        client: AsyncClient,
        test_list: ListModel,
        test_item: ItemModel,
        auth_headers: dict,
    ):
        """Test getting comparison session status."""
        # Create second item to start comparison
        create_response = await client.post(
            "/api/items/",
            params={"list_title": test_list.title},
            json={
                "name": "New Item",
                "description": "Description",
                "image_url": "https://example.com/new.jpg",
            },
            headers=auth_headers,
        )
        session_data = create_response.json()
        session_id = session_data["session_id"]

        # Get comparison status
        response = await client.get(
            f"/api/items/comparison/{session_id}/status",
            headers=auth_headers,
        )
        assert response.status_code == 200
        data = response.json()
        assert data["session_id"] == session_id
        assert "current_comparison" in data

    async def test_get_comparison_status_invalid_session(
        self, client: AsyncClient, auth_headers: dict
    ):
        """Test getting status for invalid session fails."""
        response = await client.get(
            "/api/items/comparison/invalid_session/status",
            headers=auth_headers,
        )
        assert response.status_code == 404


@pytest.mark.asyncio
class TestReadItem:
    """Tests for reading a specific item endpoint."""

    async def test_read_item_success(
        self,
        client: AsyncClient,
        test_item: ItemModel,
        auth_headers: dict,
        test_db: AsyncSession,
    ):
        """Test reading a specific item."""
        response = await client.get(
            f"/api/items/items/{test_item.item_id}", headers=auth_headers
        )
        assert response.status_code == 200
        data = response.json()
        assert str(data["item_id"]) == str(test_item.item_id)
        assert data["name"] == test_item.name
        assert data["description"] == test_item.description

        # Verify item exists in database
        result = await test_db.execute(
            select(ItemModel).where(ItemModel.item_id == test_item.item_id)
        )
        db_item = result.scalar_one_or_none()
        assert db_item is not None
        assert db_item.name == test_item.name
        assert db_item.list_id == test_item.list_id

    async def test_read_item_unauthenticated(
        self, client: AsyncClient, test_item: ItemModel
    ):
        """Test reading item without authentication fails."""
        response = await client.get(f"/api/items/items/{test_item.item_id}")
        assert response.status_code == 401

    async def test_read_item_not_found(self, client: AsyncClient, auth_headers: dict):
        """Test reading non-existent item fails."""
        import uuid

        fake_id = uuid.uuid4()
        response = await client.get(f"/api/items/items/{fake_id}", headers=auth_headers)
        assert response.status_code == 404

    async def test_read_item_wrong_user(
        self, client: AsyncClient, test_item: ItemModel, auth_headers_user2: dict
    ):
        """Test reading another user's item fails."""
        response = await client.get(
            f"/api/items/items/{test_item.item_id}", headers=auth_headers_user2
        )
        assert response.status_code == 404


@pytest.mark.asyncio
class TestUpdateItem:
    """Tests for updating items endpoint."""

    async def test_update_item_success(
        self,
        client: AsyncClient,
        test_item: ItemModel,
        auth_headers: dict,
        test_db: AsyncSession,
    ):
        """Test successful item update."""
        original_name = test_item.name
        original_description = test_item.description

        response = await client.put(
            f"/api/items/items/{test_item.item_id}",
            json={
                "name": "Updated Name",
                "description": "Updated description",
                "image_url": "https://example.com/updated.jpg",
            },
            headers=auth_headers,
        )
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "Updated Name"
        assert data["description"] == "Updated description"
        assert data["image_url"] == "https://example.com/updated.jpg"

        # Verify item was updated in database
        await test_db.refresh(test_item)
        assert test_item.name == "Updated Name"
        assert test_item.description == "Updated description"
        assert test_item.image_url == "https://example.com/updated.jpg"
        assert test_item.name != original_name
        assert test_item.description != original_description

    async def test_update_item_partial(
        self, client: AsyncClient, test_item: ItemModel, auth_headers: dict
    ):
        """Test partial item update (only name)."""
        response = await client.put(
            f"/api/items/items/{test_item.item_id}",
            json={
                "name": "New Name Only",
            },
            headers=auth_headers,
        )
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "New Name Only"

    async def test_update_item_unauthenticated(
        self, client: AsyncClient, test_item: ItemModel
    ):
        """Test updating item without authentication fails."""
        response = await client.put(
            f"/api/items/items/{test_item.item_id}",
            json={
                "name": "Updated Name",
            },
        )
        assert response.status_code == 401

    async def test_update_item_not_found(self, client: AsyncClient, auth_headers: dict):
        """Test updating non-existent item fails."""
        import uuid

        fake_id = uuid.uuid4()
        response = await client.put(
            f"/api/items/items/{fake_id}",
            json={
                "name": "Updated Name",
            },
            headers=auth_headers,
        )
        assert response.status_code == 404

    async def test_update_item_wrong_user(
        self, client: AsyncClient, test_item: ItemModel, auth_headers_user2: dict
    ):
        """Test updating another user's item fails."""
        response = await client.put(
            f"/api/items/items/{test_item.item_id}",
            json={
                "name": "Trying to update",
            },
            headers=auth_headers_user2,
        )
        assert response.status_code == 404


@pytest.mark.asyncio
class TestDeleteItem:
    """Tests for deleting items endpoint."""

    async def test_delete_item_success(
        self,
        client: AsyncClient,
        test_item: ItemModel,
        auth_headers: dict,
        test_db: AsyncSession,
    ):
        """Test successful item deletion."""
        item_id = test_item.item_id
        list_id = test_item.list_id

        # Verify item exists in database before deletion
        result = await test_db.execute(
            select(ItemModel).where(ItemModel.item_id == item_id)
        )
        assert result.scalar_one_or_none() is not None

        # Count items in list before deletion
        result = await test_db.execute(
            select(ItemModel).where(ItemModel.list_id == list_id)
        )
        items_before = len(result.scalars().all())

        response = await client.delete(
            f"/api/items/items/{item_id}", headers=auth_headers
        )
        assert response.status_code == 204

        # Verify item is deleted from database
        result = await test_db.execute(
            select(ItemModel).where(ItemModel.item_id == item_id)
        )
        assert result.scalar_one_or_none() is None

        # Verify item count decreased
        result = await test_db.execute(
            select(ItemModel).where(ItemModel.list_id == list_id)
        )
        items_after = len(result.scalars().all())
        assert items_after == items_before - 1

        # Verify item is deleted via API
        response = await client.get(f"/api/items/items/{item_id}", headers=auth_headers)
        assert response.status_code == 404

    async def test_delete_item_unauthenticated(
        self, client: AsyncClient, test_item: ItemModel
    ):
        """Test deleting item without authentication fails."""
        response = await client.delete(f"/api/items/items/{test_item.item_id}")
        assert response.status_code == 401

    async def test_delete_item_not_found(self, client: AsyncClient, auth_headers: dict):
        """Test deleting non-existent item fails."""
        import uuid

        fake_id = uuid.uuid4()
        response = await client.delete(
            f"/api/items/items/{fake_id}", headers=auth_headers
        )
        assert response.status_code == 404

    async def test_delete_item_wrong_user(
        self, client: AsyncClient, test_item: ItemModel, auth_headers_user2: dict
    ):
        """Test deleting another user's item fails."""
        response = await client.delete(
            f"/api/items/items/{test_item.item_id}", headers=auth_headers_user2
        )
        assert response.status_code == 404
