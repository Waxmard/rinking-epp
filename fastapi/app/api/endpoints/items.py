from typing import Any, List, Union

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

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
from app.core.algorithm import find_next_comparison
import uuid
from datetime import datetime

router = APIRouter()

session_id_cache = dict()

@router.post("/", response_model=Item)
async def create_item(
    list_title: str,
    item_in: ItemCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ComparisonSession:
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
        image_url=item_in.image_url,
        position=None,  # Initially unranked
        rating=None,  # Initially unrated
        tier=None,  # Initially unrated
        created_at=datetime.now(),
        updated_at=datetime.now(),
    )

        # Get all items in the list
    stmt = select(ItemModel).where(ItemModel.list_id == list_obj.list_id).order_by(ItemModel.position)
    result = await db.execute(stmt)
    all_items = result.scalars().all()

    if not all_items:
        db.add(item_obj)
        await db.commit()
        await db.refresh(item_obj)
        return item_obj

    # Initialize comparison
    middle = len(all_items) // 2
    comparison = Comparison(
        item1=item_obj,
        item2=all_items[middle],
        low=0,
        mid=middle,
        high=len(all_items) - 1,
        is_winner=None,
        done=False
    )

    # Create session ID (using timestamp for simplicity)
    session_id = f"session_{int(datetime.now().timestamp())}"

    comparison_session = ComparisonSession(
        session_id=session_id,
        list_id=list_obj.list_id,
        item_id=item_obj,
        current_comparison=comparison,
        is_complete=False,
        created_at=datetime.now(),
        updated_at=datetime.now()
    )

    session_id_cache[session_id] = comparison_session

    return comparison_session


@router.post("/comparison/{session_id}/result", response_model=Union[ComparisonSession, None])
async def submit_comparison_result(
    session_id: str,
    result: ComparisonResultRequest,
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
        return None

    # Get all items in the list
    stmt = select(ItemModel).where(ItemModel.list_id == list_id).order_by(ItemModel.position)
    result = await db.execute(stmt)
    all_items = result.scalars().all()

    # Find next comparison
    comparison_session.current_comparison = find_next_comparison(all_items, comparison_session.current_comparison, result.result == "better")

    if comparison_session.current_comparison.done:
        db.add(comparison_session.current_comparison.reference_item)
        await db.commit()
        await db.refresh(comparison_session.current_comparison.reference_item)
        session_id_cache.pop(session_id)
        return None

    return ComparisonSession(
        session_id=session_id,
        list_id=list_id,
        item_id=item_id,
        current_comparison=next_comparison,
        is_complete=False,
        created_at=datetime.now(),
        updated_at=datetime.now()
    )


@router.get("/items/{item_id}", response_model=Item)
async def read_item(
    item_id: int,
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
    item_id: int,
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
        setattr(item_obj, field, value)

    db.add(item_obj)
    await db.commit()
    await db.refresh(item_obj)

    return item_obj


@router.delete("/items/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_item(
    item_id: int,
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
