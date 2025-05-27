from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field


# Shared properties
class UserBase(BaseModel):
    """Base user schema with shared properties."""

    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr


# Properties to receive via API on creation
class UserCreate(UserBase):
    """Schema for user creation."""
    username: Optional[str] = Field(None, min_length=3, max_length=50)
    email: Optional[EmailStr] = None
    password: str = Field(..., min_length=8)


# Properties to receive via API on update
class UserUpdate(BaseModel):
    """Schema for user update."""

    username: Optional[str] = Field(None, min_length=3, max_length=50)
    email: Optional[EmailStr] = None
    password: Optional[str] = Field(None, min_length=8)


# Properties to return to client
class User(UserBase):
    """Schema for user response."""

    user_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        """Pydantic config."""

        from_attributes = True


# Properties stored in token
class UserInDB(User):
    """Schema for user in database."""

    user_id: UUID
    password_hash: str


class Token(BaseModel):
    """Schema for authentication token."""

    access_token: str
    token_type: str


class TokenPayload(BaseModel):
    """Schema for token payload."""

    sub: Optional[int] = None
