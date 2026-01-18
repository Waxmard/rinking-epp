import uuid
from typing import Any, Dict, List, Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Item as ItemModel
from app.db.models import List as ListModel


async def get_by_id(db: AsyncSession, item_id: uuid.UUID) -> Optional[ItemModel]:
    """Get an item by ID."""
    result = await db.execute(select(ItemModel).where(ItemModel.item_id == item_id))
    return result.scalar_one_or_none()


async def get_by_id_with_ownership(
    db: AsyncSession, item_id: uuid.UUID, user_id: uuid.UUID
) -> Optional[ItemModel]:
    """Get an item by ID, verifying the user owns the list it belongs to."""
    query = (
        select(ItemModel)
        .join(ListModel, ItemModel.list_id == ListModel.list_id)
        .where(ItemModel.item_id == item_id, ListModel.user_id == user_id)
    )
    result = await db.execute(query)
    return result.scalar_one_or_none()


async def get_by_list_id(db: AsyncSession, list_id: uuid.UUID) -> List[ItemModel]:
    """Get all items for a list."""
    result = await db.execute(select(ItemModel).where(ItemModel.list_id == list_id))
    return list(result.scalars().all())


async def get_by_list_and_tier_set(
    db: AsyncSession, list_id: uuid.UUID, tier_set: str
) -> List[ItemModel]:
    """Get all items in a list with a specific tier_set."""
    result = await db.execute(
        select(ItemModel).where(
            ItemModel.list_id == list_id,
            ItemModel.tier_set == tier_set,
        )
    )
    return list(result.scalars().all())


async def create(db: AsyncSession, item: ItemModel) -> ItemModel:
    """Create a new item (add to session, commit not performed)."""
    db.add(item)
    return item


async def update(
    db: AsyncSession, item: ItemModel, update_data: Dict[str, Any]
) -> ItemModel:
    """Update an item with the given data."""
    for field, value in update_data.items():
        if field == "image_url" and value is not None:
            value = str(value)
        setattr(item, field, value)
    db.add(item)
    return item


async def delete(db: AsyncSession, item: ItemModel) -> None:
    """Delete an item."""
    await db.delete(item)
