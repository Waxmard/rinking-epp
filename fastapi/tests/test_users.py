"""Tests for user endpoints."""
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import User


@pytest.mark.asyncio
class TestUserCreation:
    """Tests for user creation endpoint."""

    async def test_create_user_success(self, client: AsyncClient):
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

    async def test_create_user_duplicate_email(self, client: AsyncClient, test_user: User):
        """Test user creation with duplicate email fails."""
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
        self, client: AsyncClient, test_user: User, auth_headers: dict
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

    async def test_read_users_unauthenticated(self, client: AsyncClient):
        """Test reading users list without authentication fails."""
        response = await client.get("/api/users/")
        assert response.status_code == 401

    async def test_read_users_pagination(
        self, client: AsyncClient, test_user: User, test_user2: User, auth_headers: dict
    ):
        """Test users pagination."""
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
