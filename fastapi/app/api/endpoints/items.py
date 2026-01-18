import uuid
from datetime import datetime, timezone
from typing import List, Union

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.algorithm import find_next_comparison
from app.core.auth import get_current_user
from app.core.constants import (
    COMPARISON_SESSION_NOT_FOUND_ERROR,
    ITEM_NOT_FOUND_ERROR,
    SESSION_NOT_FOUND_ERROR,
)
from app.db.database import get_db
from app.db.models import ComparisonSession as ComparisonSessionModel
from app.db.models import Item as ItemModel
from app.db.models import List as ListModel
from app.schemas.item import (
    Comparison,
    ComparisonResultRequest,
    ComparisonSession,
    Item,
    ItemCreate,
    ItemUpdate,
)
from app.schemas.user import User
from app.utils.helper import sort_items_linked_list_style
from fastapi import APIRouter, Depends, HTTPException, status

router = APIRouter()

# Tier assignment mapping: tier_set -> (high_tier, low_tier)
TIER_SET_MAP = {
    "good": ("S", "A"),
    "mid": ("B", "C"),
    "bad": ("D", "F"),
}


def assign_tiers_for_set(sorted_items: List[ItemModel], tier_set: str) -> None:
    """
    Assign tiers to items in a sorted list based on their position.
    Top 50% gets the higher tier, bottom 50% gets the lower tier.

    Args:
        sorted_items: Items sorted from lowest to highest rank
        tier_set: The tier set (good, mid, bad)
    """
    if not sorted_items or tier_set not in TIER_SET_MAP:
        return

    high_tier, low_tier = TIER_SET_MAP[tier_set]
    total = len(sorted_items)

    # Items are sorted from lowest to highest
    # Bottom half (first half of list) gets low tier
    # Top half (second half of list) gets high tier
    midpoint = total // 2

    for i, item in enumerate(sorted_items):
        if i < midpoint:
            item.tier = low_tier
        else:
            item.tier = high_tier


@router.post("/", response_model=Union[Item, ComparisonSession])
async def create_item(
    list_title: str,
    item_in: ItemCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Union[Item, ComparisonSession]:
    """
    Create a new item within a list.

    Args:
        list_id: ID of the list to add the item to
        item_in: Item creation data
        db: Database session
        current_user: Current authenticated user

    Returns:
        Created item object
    """
    # Check if list exists and belongs to current user
    query = select(ListModel).where(
        ListModel.title == list_title, ListModel.user_id == current_user.user_id
    )
    result = await db.execute(query)
    list_obj = result.scalar_one_or_none()

    if not list_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="List not found or does not belong to current user",
        )

    # Create item
    item_obj = ItemModel(
        item_id=uuid.uuid4(),
        list_id=list_obj.list_id,
        name=item_in.name,
        description=item_in.description,
        image_url=str(item_in.image_url) if item_in.image_url else None,
        prev_item_id=None,
        next_item_id=None,  # Initially unranked
        rating=None,  # Initially unrated
        tier=None,  # Initially unrated
        tier_set=item_in.tier_set.value,  # Set tier_set from request
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
    )

    # Get all items in the list that have the same tier_set
    items_stmt = select(ItemModel).where(
        ItemModel.list_id == list_obj.list_id,
        ItemModel.tier_set == item_in.tier_set.value,
    )
    items_result = await db.execute(items_stmt)
    set_items = list(items_result.scalars().all())

    # Filter to only items that have been ranked (have a tier assigned)
    ranked_items = [i for i in set_items if i.tier is not None]

    # If no ranked items exist in this set, this is the first item
    if not ranked_items:
        # Assign initial tier based on tier_set (lower tier since it's the only item)
        tier_map = {"good": "A", "mid": "C", "bad": "F"}
        item_obj.tier = tier_map[item_in.tier_set.value]
        db.add(item_obj)
        await db.commit()
        await db.refresh(item_obj)
        return item_obj  # type: ignore[return-value]

    # Sort the ranked items by linked list order
    try:
        all_items = sort_items_linked_list_style(ranked_items)  # type: ignore[arg-type]
    except ValueError:
        # Invalid linked list structure, treat as empty
        tier_map = {"good": "A", "mid": "C", "bad": "F"}
        item_obj.tier = tier_map[item_in.tier_set.value]
        db.add(item_obj)
        await db.commit()
        await db.refresh(item_obj)
        return item_obj  # type: ignore[return-value]

    # Initialize comparison - save new item first to get a valid item_id
    db.add(item_obj)
    await db.flush()

    middle = len(all_items) // 2
    target_item = all_items[middle]

    # Create session in database
    session_id = uuid.uuid4()
    db_session = ComparisonSessionModel(
        session_id=session_id,
        list_id=list_obj.list_id,
        new_item_id=item_obj.item_id,
        target_item_id=target_item.item_id,
        tier_set=item_in.tier_set.value,
        min_index=0,
        max_index=len(all_items) - 1,
        comparison_index=middle,
        is_complete=False,
    )
    db.add(db_session)
    await db.commit()
    await db.refresh(db_session)
    await db.refresh(item_obj)

    # Build response
    comparison = Comparison(
        reference_item=item_obj,  # type: ignore[arg-type]
        target_item=target_item,  # type: ignore[arg-type]
        min_index=0,
        comparison_index=middle,
        max_index=len(all_items) - 1,
        is_winner=None,
        done=False,
    )

    comparison_session = ComparisonSession(
        session_id=str(session_id),
        list_id=list_obj.list_id,
        item_id=item_obj.item_id,
        current_comparison=comparison,
        is_complete=False,
        created_at=db_session.created_at,
        updated_at=db_session.updated_at,
    )

    return comparison_session


@router.post("/comparison/result", response_model=Union[ComparisonSession, None])
async def submit_comparison_result(
    session_id: str,
    result_request: ComparisonResultRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Union[ComparisonSession, None]:
    """
    Submit a comparison result and get the next comparison.

    Args:
        session_id: ID of the comparison session
        result: Comparison result (better or worse)
        db: Database session
        current_user: Current authenticated user

    Returns:
        Next comparison if more comparisons are needed
        Final ranking result if comparisons are complete
        None if session is invalid/expired
    """
    # Parse session_id as UUID
    try:
        session_uuid = uuid.UUID(session_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=COMPARISON_SESSION_NOT_FOUND_ERROR,
        )

    # Load session from database
    stmt = select(ComparisonSessionModel).where(
        ComparisonSessionModel.session_id == session_uuid,
        ComparisonSessionModel.is_complete == False,  # noqa: E712
    )
    result = await db.execute(stmt)
    db_session = result.scalar_one_or_none()

    if not db_session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=COMPARISON_SESSION_NOT_FOUND_ERROR,
        )

    # Verify list ownership
    list_stmt = select(ListModel).where(
        ListModel.list_id == db_session.list_id,
        ListModel.user_id == current_user.user_id,
    )
    list_result = await db.execute(list_stmt)
    if not list_result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=COMPARISON_SESSION_NOT_FOUND_ERROR,
        )

    ref_tier_set = db_session.tier_set

    # Get all ranked items in the list with the same tier_set
    items_stmt = select(ItemModel).where(
        ItemModel.list_id == db_session.list_id,
        ItemModel.tier_set == ref_tier_set,
    )
    items_result = await db.execute(items_stmt)
    set_items = list(items_result.scalars().all())

    # Filter to ranked items only (exclude the new item being ranked)
    ranked_items = [
        i
        for i in set_items
        if i.tier is not None and i.item_id != db_session.new_item_id
    ]
    all_items = sort_items_linked_list_style(ranked_items)  # type: ignore[arg-type]

    # Get the new item and current target item
    new_item_stmt = select(ItemModel).where(ItemModel.item_id == db_session.new_item_id)
    new_item_result = await db.execute(new_item_stmt)
    new_item = new_item_result.scalar_one_or_none()

    target_item_stmt = select(ItemModel).where(
        ItemModel.item_id == db_session.target_item_id
    )
    target_item_result = await db.execute(target_item_stmt)
    target_item = target_item_result.scalar_one_or_none()

    if not new_item or not target_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail=ITEM_NOT_FOUND_ERROR
        )

    # Build the current comparison state
    comparison = Comparison(
        reference_item=new_item,  # type: ignore[arg-type]
        target_item=target_item,  # type: ignore[arg-type]
        min_index=db_session.min_index,
        comparison_index=db_session.comparison_index,
        max_index=db_session.max_index,
        is_winner=result_request.result == "better",
        done=False,
    )

    # Find next comparison
    comparison = find_next_comparison(all_items, comparison)

    if comparison.done:
        # Set reference item pointers
        if comparison.is_winner:
            new_item.prev_item_id = comparison.target_item.item_id
            new_item.next_item_id = comparison.target_item.next_item_id
        else:
            new_item.next_item_id = comparison.target_item.item_id
            new_item.prev_item_id = comparison.target_item.prev_item_id

        new_item.updated_at = datetime.now(timezone.utc)
        db.add(new_item)
        await db.flush()

        # Update target item pointer
        if comparison.is_winner:
            target_item.next_item_id = new_item.item_id
        else:
            target_item.prev_item_id = new_item.item_id
        target_item.updated_at = datetime.now(timezone.utc)

        await db.flush()

        # Recalculate tiers for all items in this tier_set
        rebalance_stmt = select(ItemModel).where(
            ItemModel.list_id == db_session.list_id,
            ItemModel.tier_set == ref_tier_set,
        )
        rebalance_result = await db.execute(rebalance_stmt)
        all_set_items = list(rebalance_result.scalars().all())

        try:
            sorted_items = sort_items_linked_list_style(all_set_items)  # type: ignore[arg-type]
            assign_tiers_for_set(sorted_items, ref_tier_set)  # type: ignore[arg-type]
        except ValueError:
            pass  # Linked list invalid, skip tier assignment

        # Mark session as complete
        db_session.is_complete = True
        await db.commit()
        return None

    # Update session in database with new comparison state
    db_session.target_item_id = comparison.target_item.item_id
    db_session.min_index = comparison.min_index
    db_session.max_index = comparison.max_index
    db_session.comparison_index = comparison.comparison_index
    await db.commit()
    await db.refresh(db_session)

    # Build response
    comparison_session = ComparisonSession(
        session_id=str(db_session.session_id),
        list_id=db_session.list_id,
        item_id=db_session.new_item_id,
        current_comparison=comparison,
        is_complete=False,
        created_at=db_session.created_at,
        updated_at=db_session.updated_at,
    )

    return comparison_session


@router.get("/items/{item_id}", response_model=Item)
async def read_item(
    item_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Item:
    """
    Get a specific item by ID.

    Args:
        item_id: ID of the item to retrieve
        db: Database session
        current_user: Current authenticated user

    Returns:
        Item object with details
    """
    # Get the item and check ownership
    query = (
        select(ItemModel, ListModel)
        .join(ListModel, ItemModel.list_id == ListModel.list_id)
        .where(ItemModel.item_id == item_id, ListModel.user_id == current_user.user_id)
    )

    result = await db.execute(query)
    row = result.first()

    if not row:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=ITEM_NOT_FOUND_ERROR,
        )

    item_obj = row[0]
    return item_obj


@router.put("/items/{item_id}", response_model=Item)
async def update_item(
    item_id: uuid.UUID,
    item_in: ItemUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Item:
    """
    Update an item's metadata.

    Args:
        item_id: ID of the item to update
        item_in: Item update data
        db: Database session
        current_user: Current authenticated user

    Returns:
        Updated item object
    """
    # Get the item and check ownership
    query = (
        select(ItemModel, ListModel)
        .join(ListModel, ItemModel.list_id == ListModel.list_id)
        .where(ItemModel.item_id == item_id, ListModel.user_id == current_user.user_id)
    )

    result = await db.execute(query)
    row = result.first()

    if not row:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=ITEM_NOT_FOUND_ERROR,
        )

    item_obj = row[0]

    # Update fields
    update_data = item_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        # Convert HttpUrl to string for database storage
        if field == "image_url" and value is not None:
            value = str(value)
        setattr(item_obj, field, value)

    db.add(item_obj)
    await db.commit()
    await db.refresh(item_obj)

    return item_obj


@router.delete("/items/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_item(
    item_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> None:
    """
    Delete an item.

    Args:
        item_id: ID of the item to delete
        db: Database session
        current_user: Current authenticated user

    Returns:
        None
    """
    # Get the item and check ownership
    query = (
        select(ItemModel, ListModel)
        .join(ListModel, ItemModel.list_id == ListModel.list_id)
        .where(ItemModel.item_id == item_id, ListModel.user_id == current_user.user_id)
    )

    result = await db.execute(query)
    row = result.first()

    if not row:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=ITEM_NOT_FOUND_ERROR,
        )

    item_obj = row[0]

    # Delete the item
    await db.delete(item_obj)
    await db.commit()


@router.get("/comparison/{session_id}/status", response_model=ComparisonSession)
async def get_comparison_status(
    session_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ComparisonSession:
    """
    Get the status of a comparison session.

    Args:
        session_id: ID of the comparison session
        db: Database session
        current_user: Current authenticated user

    Returns:
        Current status of the comparison session
    """
    # Parse session_id as UUID
    try:
        session_uuid = uuid.UUID(session_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=SESSION_NOT_FOUND_ERROR,
        )

    # Load session from database
    stmt = select(ComparisonSessionModel).where(
        ComparisonSessionModel.session_id == session_uuid,
    )
    result = await db.execute(stmt)
    db_session = result.scalar_one_or_none()

    if not db_session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=SESSION_NOT_FOUND_ERROR,
        )

    # Verify list ownership
    list_stmt = select(ListModel).where(
        ListModel.list_id == db_session.list_id,
        ListModel.user_id == current_user.user_id,
    )
    list_result = await db.execute(list_stmt)
    if not list_result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=SESSION_NOT_FOUND_ERROR,
        )

    # Get the new item and current target item
    new_item_stmt = select(ItemModel).where(ItemModel.item_id == db_session.new_item_id)
    new_item_result = await db.execute(new_item_stmt)
    new_item = new_item_result.scalar_one_or_none()

    target_item_stmt = select(ItemModel).where(
        ItemModel.item_id == db_session.target_item_id
    )
    target_item_result = await db.execute(target_item_stmt)
    target_item = target_item_result.scalar_one_or_none()

    if not new_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=ITEM_NOT_FOUND_ERROR,
        )

    # Build comparison if session is not complete
    comparison = None
    if not db_session.is_complete and target_item:
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
