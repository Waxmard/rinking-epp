from datetime import datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, Field

from app.schemas.item import Item


# Shared properties
class ListBase(BaseModel):
    """Base list schema with shared properties."""

    title: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = None


# Properties to receive via API on creation
class ListCreate(ListBase):
    """Schema for list creation."""
    pass


# Properties to receive via API on update
class ListUpdate(BaseModel):
    """Schema for list update."""

    title: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = None


# Properties to return to client
class List(ListBase):
    """Schema for list response."""

    list_id: UUID
    user_id: UUID
    title: str
    description: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        """Pydantic config."""

        from_attributes = True


# Simple list (without items) for listing purposes
class ListSimple(ListBase):
    """Schema for simple list response (without items)."""

    list_id: UUID
    user_id: UUID
    title: str
    description: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    item_count: int = 0

    class Config:
        """Pydantic config."""

        from_attributes = True
