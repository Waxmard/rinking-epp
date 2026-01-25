"""Comparison session business logic."""

import logging
import uuid
from datetime import datetime, timezone
from typing import List, Optional, Tuple

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.algorithm import find_next_comparison
from app.core.fractional_index import generate_key_between
from app.crud import comparison as comparison_crud
from app.db.models import ComparisonSession as ComparisonSessionModel
from app.db.models import Item as ItemModel
from app.schemas.item import Comparison, ComparisonSession
from app.services.ranking import assign_tiers_for_set
from app.utils.helper import sort_items_by_position

logger = logging.getLogger(__name__)


async def start_comparison(
    db: AsyncSession,
    new_item: ItemModel,
    list_id: uuid.UUID,
    tier_set: str,
    ranked_items: List[ItemModel],
) -> ComparisonSessionModel:
    """
    Start a new comparison session for ranking an item.

    Args:
        db: Database session
        new_item: The new item being ranked
        list_id: ID of the list
        tier_set: The tier set (good, mid, bad)
        ranked_items: Already ranked items in the same tier_set

    Returns:
        The created comparison session model
    """
    all_items = sort_items_by_position(ranked_items)

    middle = len(all_items) // 2
    target_item = all_items[middle]

    session_id = uuid.uuid4()
    db_session = ComparisonSessionModel(
        session_id=session_id,
        list_id=list_id,
        new_item_id=new_item.item_id,
        target_item_id=target_item.item_id,
        tier_set=tier_set,
        min_index=0,
        max_index=len(all_items) - 1,
        comparison_index=middle,
        is_complete=False,
    )

    await comparison_crud.create(db, db_session)
    return db_session


def build_comparison_session_response(
    db_session: ComparisonSessionModel,
    new_item: ItemModel,
    target_item: Optional[ItemModel],
    comparison: Optional[Comparison] = None,
) -> ComparisonSession:
    """
    Build a ComparisonSession response from database models.

    Args:
        db_session: The database session model
        new_item: The new item being ranked
        target_item: The current target item for comparison
        comparison: Optional pre-built comparison object

    Returns:
        ComparisonSession schema object
    """
    if comparison is None and target_item is not None and not db_session.is_complete:
        comparison = Comparison(
            reference_item=new_item,  # type: ignore[arg-type]
            target_item=target_item,  # type: ignore[arg-type]
            min_index=db_session.min_index,
            comparison_index=db_session.comparison_index,
            max_index=db_session.max_index,
            is_winner=None,
            done=False,
        )

    return ComparisonSession(
        session_id=str(db_session.session_id),
        list_id=db_session.list_id,
        item_id=db_session.new_item_id,
        current_comparison=comparison,
        is_complete=db_session.is_complete,
        created_at=db_session.created_at,
        updated_at=db_session.updated_at,
    )


def process_comparison_result(
    db_session: ComparisonSessionModel,
    is_winner: bool,
    new_item: ItemModel,
    target_item: ItemModel,
    ranked_items: List[ItemModel],
) -> Tuple[Comparison, List[ItemModel]]:
    """
    Process a comparison result and determine the next step.

    Args:
        db_session: The comparison session
        is_winner: Whether the new item won the comparison
        new_item: The new item being ranked
        target_item: The current target item
        ranked_items: Already ranked items (excluding new_item)

    Returns:
        Tuple of (Updated Comparison object, sorted items list)
    """
    sorted_items = sort_items_by_position(ranked_items)

    comparison = Comparison(
        reference_item=new_item,  # type: ignore[arg-type]
        target_item=target_item,  # type: ignore[arg-type]
        min_index=db_session.min_index,
        comparison_index=db_session.comparison_index,
        max_index=db_session.max_index,
        is_winner=is_winner,
        done=False,
    )

    result = find_next_comparison(sorted_items, comparison)
    return result, sorted_items


async def finalize_comparison(
    db: AsyncSession,
    db_session: ComparisonSessionModel,
    comparison: Comparison,
    new_item: ItemModel,
    sorted_items: List[ItemModel],
    list_id: uuid.UUID,
    tier_set: str,
) -> None:
    """
    Finalize a comparison by setting item position and recalculating tiers.

    Args:
        db: Database session
        db_session: The comparison session
        comparison: The final comparison result
        new_item: The new item being ranked
        sorted_items: Already sorted ranked items (excluding new_item)
        list_id: ID of the list
        tier_set: The tier set (good, mid, bad)
    """
    target_index = comparison.comparison_index

    # Calculate the new position using fractional indexing
    # Use the comparison index to get adjacent items directly
    if comparison.is_winner:
        # New item ranks higher (goes after target in the list)
        lower_bound = sorted_items[target_index].position if target_index >= 0 else None
        upper_bound = (
            sorted_items[target_index + 1].position
            if target_index + 1 < len(sorted_items)
            else None
        )
    else:
        # New item ranks lower (goes before target in the list)
        lower_bound = (
            sorted_items[target_index - 1].position if target_index > 0 else None
        )
        upper_bound = (
            sorted_items[target_index].position if target_index >= 0 else None
        )

    new_item.position = generate_key_between(lower_bound, upper_bound)
    new_item.updated_at = datetime.now(timezone.utc)
    db.add(new_item)
    await db.flush()

    # Recalculate tiers for all items in this tier_set (including new item)
    all_ranked_items = sorted_items + [new_item]
    all_ranked_items_sorted = sort_items_by_position(all_ranked_items)

    try:
        assign_tiers_for_set(all_ranked_items_sorted, tier_set)
    except ValueError as e:
        logger.warning(
            "Failed to assign tiers for list_id=%s, tier_set=%s: %s",
            list_id,
            tier_set,
            str(e),
        )

    # Mark session as complete
    await comparison_crud.mark_complete(db, db_session)
