import uuid
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import ComparisonSession as ComparisonSessionModel


async def get_by_id(
    db: AsyncSession, session_id: uuid.UUID
) -> Optional[ComparisonSessionModel]:
    """Get a comparison session by ID."""
    result = await db.execute(
        select(ComparisonSessionModel).where(
            ComparisonSessionModel.session_id == session_id
        )
    )
    return result.scalar_one_or_none()


async def get_active(
    db: AsyncSession, session_id: uuid.UUID
) -> Optional[ComparisonSessionModel]:
    """Get an active (not complete) comparison session by ID."""
    result = await db.execute(
        select(ComparisonSessionModel).where(
            ComparisonSessionModel.session_id == session_id,
            ComparisonSessionModel.is_complete.is_(False),
        )
    )
    return result.scalar_one_or_none()


async def create(
    db: AsyncSession, session: ComparisonSessionModel
) -> ComparisonSessionModel:
    """Create a new comparison session."""
    db.add(session)
    await db.flush()
    return session


async def update(  # pylint: disable=too-many-arguments,too-many-positional-arguments
    db: AsyncSession,
    session: ComparisonSessionModel,
    target_item_id: uuid.UUID,
    min_index: int,
    max_index: int,
    comparison_index: int,
) -> ComparisonSessionModel:
    """Update comparison session state."""
    session.target_item_id = target_item_id
    session.min_index = min_index
    session.max_index = max_index
    session.comparison_index = comparison_index
    await db.flush()
    return session


async def mark_complete(
    db: AsyncSession,
    session: ComparisonSessionModel,
) -> ComparisonSessionModel:
    """Mark a comparison session as complete."""
    session.is_complete = True
    await db.flush()
    return session
