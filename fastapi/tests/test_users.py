"""Tests for user endpoints."""
import pytest
from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import User
from app.core.security import verify_password


@pytest.mark.asyncio
class TestUserCreation:
    """Tests for user creation endpoint."""

    async def test_create_user_success(self, client: AsyncClient, test_db: AsyncSession):
        """Test successful user creation."""
        response = await client.post(
            "/api/users/",
            json={
                "email": "newuser@example.com",
                "username": "newuser",
                "password": "securepassword123",
            },
        )
        assert response.status_code == 201
        data = response.json()
        assert data["email"] == "newuser@example.com"
        assert data["username"] == "newuser"
        assert "user_id" in data
        assert "password" not in data
        assert "password_hash" not in data

        # Verify user was created in database
        result = await test_db.execute(
            select(User).where(User.email == "newuser@example.com")
        )
        db_user = result.scalar_one_or_none()
        assert db_user is not None
        assert db_user.email == "newuser@example.com"
        assert db_user.username == "newuser"
        assert db_user.password_hash is not None
        assert verify_password("securepassword123", db_user.password_hash)
        assert str(db_user.user_id) == data["user_id"]

    async def test_create_user_duplicate_email(
        self, client: AsyncClient, test_user: User, test_db: AsyncSession
    ):
        """Test user creation with duplicate email fails."""
        # Count users before attempt
        result = await test_db.execute(select(User))
        users_before = len(result.scalars().all())

        response = await client.post(
            "/api/users/",
            json={
                "email": test_user.email,
                "username": "differentusername",
                "password": "securepassword123",
            },
        )
        assert response.status_code == 400
        assert "email already exists" in response.json()["detail"].lower()

        # Verify no new user was created in database
        result = await test_db.execute(select(User))
        users_after = len(result.scalars().all())
        assert users_after == users_before

    async def test_create_user_invalid_email(self, client: AsyncClient):
        """Test user creation with invalid email fails."""
        response = await client.post(
            "/api/users/",
            json={
                "email": "notanemail",
                "username": "newuser",
                "password": "securepassword123",
            },
        )
        assert response.status_code == 422

    async def test_create_user_short_password(self, client: AsyncClient):
        """Test user creation with short password fails."""
        response = await client.post(
            "/api/users/",
            json={
                "email": "newuser@example.com",
                "username": "newuser",
                "password": "short",
            },
        )
        assert response.status_code == 422

    async def test_create_user_missing_fields(self, client: AsyncClient):
        """Test user creation with missing required fields fails."""
        response = await client.post(
            "/api/users/",
            json={
                "email": "newuser@example.com",
            },
        )
        assert response.status_code == 422


@pytest.mark.asyncio
class TestUserLogin:
    """Tests for user login endpoint."""

    async def test_login_success_with_email(self, client: AsyncClient, test_user: User):
        """Test successful login with email."""
        response = await client.post(
            "/api/users/token",
            data={
                "username": test_user.email,
                "password": "testpassword123",
            },
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"

    async def test_login_success_with_username(self, client: AsyncClient, test_user: User):
        """Test successful login with username."""
        response = await client.post(
            "/api/users/token",
            data={
                "username": test_user.username,
                "password": "testpassword123",
            },
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"

    async def test_login_wrong_password(self, client: AsyncClient, test_user: User):
        """Test login with wrong password fails."""
        response = await client.post(
            "/api/users/token",
            data={
                "username": test_user.email,
                "password": "wrongpassword",
            },
        )
        assert response.status_code == 401
        assert "incorrect" in response.json()["detail"].lower()

    async def test_login_nonexistent_user(self, client: AsyncClient):
        """Test login with non-existent user fails."""
        response = await client.post(
            "/api/users/token",
            data={
                "username": "nonexistent@example.com",
                "password": "somepassword",
            },
        )
        assert response.status_code == 401


@pytest.mark.asyncio
class TestReadUsers:
    """Tests for reading users endpoint."""

    async def test_read_users_authenticated(
        self, client: AsyncClient, test_user: User, auth_headers: dict, test_db: AsyncSession
    ):
        """Test reading users list when authenticated."""
        response = await client.get("/api/users/", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) >= 1

        # Verify user data structure
        user_data = data[0]
        assert "user_id" in user_data
        assert "email" in user_data
        assert "password" not in user_data
        assert "password_hash" not in user_data

        # Verify data matches database
        result = await test_db.execute(select(User))
        db_users = result.scalars().all()
        assert len(data) == len(db_users)

        # Verify the test_user is in the response
        user_ids_in_response = [u["user_id"] for u in data]
        assert str(test_user.user_id) in user_ids_in_response

    async def test_read_users_unauthenticated(self, client: AsyncClient):
        """Test reading users list without authentication fails."""
        response = await client.get("/api/users/")
        assert response.status_code == 401

    async def test_read_users_pagination(
        self, client: AsyncClient, test_user: User, test_user2: User,
        auth_headers: dict, test_db: AsyncSession
    ):
        """Test users pagination."""
        # Verify we have 2 users in database
        result = await test_db.execute(select(User))
        db_users = result.scalars().all()
        assert len(db_users) == 2

        # Test with limit
        response = await client.get("/api/users/?limit=1", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1

        # Test with skip
        response = await client.get("/api/users/?skip=1", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) == 1  # Should return 1 user (total 2 - skip 1)


@pytest.mark.asyncio
class TestReadCurrentUser:
    """Tests for reading current user endpoint."""

    async def test_read_current_user_success(
        self, client: AsyncClient, test_user: User, auth_headers: dict
    ):
        """Test reading current user info when authenticated."""
        response = await client.get("/api/users/me", headers=auth_headers)
        assert response.status_code == 200
        data = response.json()
        assert data["email"] == test_user.email
        assert data["username"] == test_user.username
        assert str(data["user_id"]) == str(test_user.user_id)
        assert "password" not in data
        assert "password_hash" not in data

    async def test_read_current_user_unauthenticated(self, client: AsyncClient):
        """Test reading current user without authentication fails."""
        response = await client.get("/api/users/me")
        assert response.status_code == 401

    async def test_read_current_user_invalid_token(self, client: AsyncClient):
        """Test reading current user with invalid token fails."""
        response = await client.get(
            "/api/users/me", headers={"Authorization": "Bearer invalid_token"}
        )
        assert response.status_code == 401
