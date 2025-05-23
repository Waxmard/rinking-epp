from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field, HttpUrl


# Shared properties
class ItemBase(BaseModel):
    """Base item schema with shared properties."""

    name: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = None
    image_url: Optional[HttpUrl] = None


# Properties to receive via API on creation
class ItemCreate(ItemBase):
    """Schema for item creation."""

    pass


# Properties to receive via API on update
class ItemUpdate(BaseModel):
    """Schema for item update."""

    name: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = None
    image_url: Optional[HttpUrl] = None


# Tier ranking enum
class TierRank(str, Enum):
    """Enum for tier rankings."""

    S = "S"
    A = "A"
    B = "B"
    C = "C"
    D = "D"
    F = "F"


# Properties to return to client
class Item(ItemBase):
    """Schema for item response."""

    item_id: int
    list_id: int
    position: Optional[int] = None
    rating: Optional[float] = None
    tier: Optional[TierRank] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        """Pydantic config."""

        from_attributes = True


# Schema for comparison request
class ComparisonRequest(BaseModel):
    """Schema for comparison request."""

    item1_id: int
    item2_id: int
    winner_id: int

    class Config:
        """Pydantic config."""

        from_attributes = True


# Schema for next comparison
class NextComparison(BaseModel):
    """Schema for next comparison response."""

    item1: Item
    item2: Item

    class Config:
        """Pydantic config."""

        from_attributes = True
