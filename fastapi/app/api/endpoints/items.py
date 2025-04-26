from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.auth import get_current_user
from app.db.database import get_db
from app.db.models import Item as ItemModel
from app.db.models import List as ListModel
from app.schemas.item import (
    ComparisonRequest,
    Item,
    ItemCreate,
    ItemUpdate,
    NextComparison,
)
from app.schemas.user import User
from app.utils.algorithm import find_next_comparison_pair, update_rankings

router = APIRouter()


@router.post("/{list_id}", response_model=Item)
async def create_item(
    list_id: int,
    item_in: ItemCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    """
    Create a new item within a list.
    """
    # Check if list exists and belongs to current user
    query = select(ListModel).where(
        ListModel.list_id == list_id, ListModel.user_id == current_user.user_id
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
        list_id=list_id,
        name=item_in.name,
        description=item_in.description,
        image_url=item_in.image_url,
        position=None,  # Initially unranked
        rating=None,  # Initially unrated
    )

    db.add(item_obj)
    await db.commit()
    await db.refresh(item_obj)

    return {
        "item_id": item_obj.item_id,
        "list_id": item_obj.list_id,
        "name": item_obj.name,
        "description": item_obj.description,
        "image_url": item_obj.image_url,
        "position": item_obj.position,
        "rating": item_obj.rating,
        "created_at": item_obj.created_at,
        "updated_at": item_obj.updated_at,
    }


@router.get("/{item_id}", response_model=Item)
async def read_item(
    item_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    """
    Get a specific item by ID.
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

    return {
        "item_id": item_obj.item_id,
        "list_id": item_obj.list_id,
        "name": item_obj.name,
        "description": item_obj.description,
        "image_url": item_obj.image_url,
        "position": item_obj.position,
        "rating": item_obj.rating,
        "created_at": item_obj.created_at,
        "updated_at": item_obj.updated_at,
    }


@router.put("/{item_id}", response_model=Item)
async def update_item(
    item_id: int,
    item_in: ItemUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    """
    Update an item.
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

    return {
        "item_id": item_obj.item_id,
        "list_id": item_obj.list_id,
        "name": item_obj.name,
        "description": item_obj.description,
        "image_url": item_obj.image_url,
        "position": item_obj.position,
        "rating": item_obj.rating,
        "created_at": item_obj.created_at,
        "updated_at": item_obj.updated_at,
    }


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_item(
    item_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> None:
    """
    Delete an item.
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

    # TODO: Update positions and ratings of remaining items


@router.get("/list/{list_id}/next-comparison", response_model=NextComparison)
async def get_next_comparison(
    list_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    """
    Get the next pair of items to compare for ranking.
    """
    # Check if list exists and belongs to current user
    query = select(ListModel).where(
        ListModel.list_id == list_id, ListModel.user_id == current_user.user_id
    )
    result = await db.execute(query)
    list_obj = result.scalar_one_or_none()

    if not list_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="List not found or does not belong to current user",
        )

    try:
        # Use algorithm to find next comparison pair
        next_comparison = await find_next_comparison_pair(db, list_id)
        return next_comparison
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.post("/compare", response_model=List[Item])
async def compare_items(
    comparison: ComparisonRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    """
    Submit a comparison result and update rankings.
    """
    # Verify both items exist and belong to the same list owned by the user
    query = select(ItemModel.list_id).where(ItemModel.item_id == comparison.item1_id)
    result = await db.execute(query)
    list_id1 = result.scalar_one_or_none()

    query = select(ItemModel.list_id).where(ItemModel.item_id == comparison.item2_id)
    result = await db.execute(query)
    list_id2 = result.scalar_one_or_none()

    if not list_id1 or not list_id2 or list_id1 != list_id2:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Items must exist and belong to the same list",
        )

    # Check list ownership
    query = select(ListModel).where(
        ListModel.list_id == list_id1, ListModel.user_id == current_user.user_id
    )
    result = await db.execute(query)
    list_obj = result.scalar_one_or_none()

    if not list_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="List not found or does not belong to current user",
        )

    # Verify winner is one of the compared items
    if (
        comparison.winner_id != comparison.item1_id
        and comparison.winner_id != comparison.item2_id
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Winner must be one of the compared items",
        )

    # Determine winner and loser
    winner_id = comparison.winner_id
    loser_id = (
        comparison.item1_id if winner_id == comparison.item2_id else comparison.item2_id
    )

    try:
        # Update rankings based on comparison
        updated_items = await update_rankings(db, list_id1, winner_id, loser_id)

        # Format response
        items_data = [
            {
                "item_id": item.item_id,
                "list_id": item.list_id,
                "name": item.name,
                "description": item.description,
                "image_url": item.image_url,
                "position": item.position,
                "rating": item.rating,
                "created_at": item.created_at,
                "updated_at": item.updated_at,
            }
            for item in updated_items
        ]

        return items_data

    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
