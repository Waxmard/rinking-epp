import uuid
from typing import Any, Dict, List, Optional, Tuple

from sqlalchemy import case, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Item as ItemModel
from app.db.models import List as ListModel


async def get_by_id(db: AsyncSession, list_id: uuid.UUID) -> Optional[ListModel]:
    """Get a list by ID."""
    result = await db.execute(select(ListModel).where(ListModel.list_id == list_id))
    return result.scalar_one_or_none()


async def get_by_id_and_user(
    db: AsyncSession, list_id: uuid.UUID, user_id: uuid.UUID
) -> Optional[ListModel]:
    """Get a list by ID, verifying user ownership."""
    result = await db.execute(
        select(ListModel).where(
            ListModel.list_id == list_id,
            ListModel.user_id == user_id,
        )
    )
    return result.scalar_one_or_none()


async def get_by_title_and_user(
    db: AsyncSession, title: str, user_id: uuid.UUID
) -> Optional[ListModel]:
    """Get a list by title for a specific user."""
    result = await db.execute(
        select(ListModel).where(
            ListModel.title == title,
            ListModel.user_id == user_id,
        )
    )
    return result.scalar_one_or_none()


async def get_by_user_with_stats(
    db: AsyncSession, user_id: uuid.UUID, skip: int = 0, limit: int = 100
) -> List[Tuple]:
    """Get all lists for a user with item counts and tier distribution."""
    query = (
        select(
            ListModel,
            func.count(ItemModel.item_id).label("item_count"),
            func.sum(case((ItemModel.tier == "S", 1), else_=0)).label("tier_s"),
            func.sum(case((ItemModel.tier == "A", 1), else_=0)).label("tier_a"),
            func.sum(case((ItemModel.tier == "B", 1), else_=0)).label("tier_b"),
            func.sum(case((ItemModel.tier == "C", 1), else_=0)).label("tier_c"),
            func.sum(case((ItemModel.tier == "D", 1), else_=0)).label("tier_d"),
            func.sum(case((ItemModel.tier == "F", 1), else_=0)).label("tier_f"),
        )
        .outerjoin(ItemModel)
        .where(ListModel.user_id == user_id)
        .group_by(ListModel.list_id)
        .offset(skip)
        .limit(limit)
    )
    result = await db.execute(query)
    return list(result.all())


async def create(db: AsyncSession, list_obj: ListModel) -> ListModel:
    """Create a new list."""
    db.add(list_obj)
    await db.commit()
    await db.refresh(list_obj)
    return list_obj


async def update(
    db: AsyncSession, list_obj: ListModel, update_data: Dict[str, Any]
) -> ListModel:
    """Update a list with the given data."""
    for field, value in update_data.items():
        setattr(list_obj, field, value)
    db.add(list_obj)
    await db.commit()
    await db.refresh(list_obj)
    return list_obj


async def delete(db: AsyncSession, list_obj: ListModel) -> None:
    """Delete a list (items cascade deleted via relationship)."""
    await db.delete(list_obj)
    await db.commit()
