import uuid
from datetime import datetime, timezone
from typing import Union

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.algorithm import find_next_comparison
from app.core.auth import get_current_user
from app.db.database import get_db
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
from app.utils.helper import (
    convert_pydantic_to_sqlalchemy,
    sort_items_linked_list_style,
)
from fastapi import APIRouter, Depends, HTTPException, status

router = APIRouter()

session_id_cache = dict()


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
        image_url=str(item_in.image_url),
        prev_item_id=None,
        next_item_id=None,  # Initially unranked
        rating=None,  # Initially unrated
        tier=None,  # Initially unrated
        created_at=datetime.now(),
        updated_at=datetime.now(),
    )

    # Get all items in the list
    stmt = select(ItemModel).where(ItemModel.list_id == list_obj.list_id)
    result = await db.execute(stmt)
    all_items = sort_items_linked_list_style(list(result.scalars().all()))  # type: ignore[arg-type]

    if not all_items:
        db.add(item_obj)
        await db.commit()
        await db.refresh(item_obj)
        return item_obj  # type: ignore[return-value]

    # Initialize comparison
    middle = len(all_items) // 2
    comparison = Comparison(
        reference_item=item_obj,  # type: ignore[arg-type]
        target_item=all_items[middle],  # type: ignore[arg-type]
        min_index=0,
        comparison_index=middle,
        max_index=len(all_items) - 1,
        is_winner=None,
        done=False,
    )

    # Create session ID (using timestamp for simplicity)
    session_id = f"session_{int(datetime.now().timestamp())}"

    comparison_session = ComparisonSession(
        session_id=session_id,
        list_id=list_obj.list_id,
        item_id=item_obj.item_id,
        current_comparison=comparison,
        is_complete=False,
        created_at=datetime.now(),
        updated_at=datetime.now(),
    )

    session_id_cache[session_id] = comparison_session

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
    comparison_session = session_id_cache.get(session_id)
    if not comparison_session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Comparison session not found or invalid",
        )

    # Get all items in the list
    stmt = select(ItemModel).where(ItemModel.list_id == comparison_session.list_id)
    result = await db.execute(stmt)
    all_items = sort_items_linked_list_style(list(result.scalars().all()))  # type: ignore[arg-type]

    # Find next comparison
    assert comparison_session.current_comparison is not None
    comparison_session.current_comparison.is_winner = result_request.result == "better"
    comparison_session.current_comparison = find_next_comparison(
        all_items, comparison_session.current_comparison
    )

    # TODO: Update reference item and target item from Pydantic to SQLAlchemy models
    if comparison_session.current_comparison.done:
        # Set reference item pointers
        if comparison_session.current_comparison.is_winner:
            comparison_session.current_comparison.reference_item.prev_item_id = (
                comparison_session.current_comparison.target_item.item_id
            )
            comparison_session.current_comparison.reference_item.next_item_id = (
                comparison_session.current_comparison.target_item.next_item_id
            )
        else:
            comparison_session.current_comparison.reference_item.next_item_id = (
                comparison_session.current_comparison.target_item.item_id
            )
            comparison_session.current_comparison.reference_item.prev_item_id = (
                comparison_session.current_comparison.target_item.prev_item_id
            )

        db.add(
            convert_pydantic_to_sqlalchemy(
                comparison_session.current_comparison.reference_item
            )
        )
        await db.commit()
        stmt = select(ItemModel).where(
            ItemModel.item_id
            == comparison_session.current_comparison.target_item.item_id
        )
        result = await db.execute(stmt)
        item = result.scalar_one_or_none()

        if item is None:
            raise HTTPException(status_code=404, detail="Item not found")

        # Apply in-place updates
        if comparison_session.current_comparison.is_winner:
            item.next_item_id = (
                comparison_session.current_comparison.reference_item.item_id
            )
        else:
            item.prev_item_id = (
                comparison_session.current_comparison.reference_item.item_id
            )
        item.updated_at = datetime.now(timezone.utc)  # optional

        await db.flush()
        session_id_cache.pop(session_id)
        return None

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
            detail="Item not found or does not belong to current user",
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
            detail="Item not found or does not belong to current user",
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
            detail="Item not found or does not belong to current user",
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
    comparison_session = session_id_cache.get(session_id)
    if not comparison_session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found or invalid",
        )

    return comparison_session
