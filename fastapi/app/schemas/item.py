import uuid
from datetime import datetime
from enum import Enum
from typing import Literal, Optional

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

    name: str
    description: Optional[str] = None
    image_url: Optional[HttpUrl] = None


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

    item_id: uuid.UUID
    list_id: uuid.UUID
    name: str
    description: Optional[str] = None
    image_url: Optional[HttpUrl] = None
    prev_item_id: Optional[uuid.UUID] = None
    next_item_id: Optional[uuid.UUID] = None
    rating: Optional[float] = None
    tier: Optional[TierRank] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        """Pydantic config."""

        from_attributes = True


# Schema for comparison
class Comparison(BaseModel):
    """Schema for comparison."""

    reference_item: Item
    target_item: Item
    comparison_index: int
    min_index: int
    max_index: int
    is_winner: Optional[bool] = None
    done: bool = False

    class Config:
        """Pydantic config."""

        from_attributes = True


# Schema for comparison
ComparisonResult = Literal["better", "worse"]


class ComparisonSession(BaseModel):
    """Schema for comparison session."""

    session_id: str
    list_id: uuid.UUID
    item_id: uuid.UUID
    current_comparison: Optional[Comparison] = None
    is_complete: bool = False
    created_at: datetime
    updated_at: datetime

    class Config:
        """Pydantic config."""

        from_attributes = True


class ComparisonResultRequest(BaseModel):
    """Schema for comparison result request."""

    result: ComparisonResult

    class Config:
        """Pydantic config."""

        from_attributes = True
