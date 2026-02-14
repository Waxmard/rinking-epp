import uuid
from datetime import datetime, timezone
from typing import Union

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.auth import get_current_user
from app.core.constants import (
    COMPARISON_SESSION_NOT_FOUND_ERROR,
    ITEM_NOT_FOUND_ERROR,
    SESSION_NOT_FOUND_ERROR,
)
from app.core.fractional_index import generate_key_between
from app.crud import comparison as comparison_crud
from app.crud import item as item_crud
from app.crud import list as list_crud
from app.db.database import get_db
from app.db.models import Item as ItemModel
from app.schemas.item import (
    Comparison,
    ComparisonResultRequest,
    ComparisonSession,
    Item,
    ItemCreate,
    ItemUpdate,
)
from app.schemas.user import User
from app.services.comparison_service import (
    build_comparison_session_response,
    finalize_comparison,
    process_comparison_result,
    start_comparison,
)
from app.services.ranking import filter_ranked_items, get_initial_tier
from app.utils.helper import sort_items_by_position
from fastapi import APIRouter, Depends, HTTPException, status

router = APIRouter()


@router.post("/", response_model=Union[Item, ComparisonSession])
async def create_item(
    list_title: str,
    item_in: ItemCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Union[Item, ComparisonSession]:
    """
    Create a new item within a list.
    """
    # Check if list exists and belongs to current user
    list_obj = await list_crud.get_by_title_and_user(
        db, list_title, current_user.user_id
    )
    if not list_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="List not found or does not belong to current user",
        )

    # Create item (position will be set during comparison or as initial item)
    item_obj = ItemModel(
        item_id=uuid.uuid4(),
        list_id=list_obj.list_id,
        name=item_in.name,
        description=item_in.description,
        image_url=str(item_in.image_url) if item_in.image_url else None,
        position=None,
        rating=None,
        tier=None,
        tier_set=item_in.tier_set.value,
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
    )

    # Get all items in the list with the same tier_set
    set_items = await item_crud.get_by_list_and_tier_set(
        db, list_obj.list_id, item_in.tier_set.value
    )

    # Filter to only ranked items (those with position)
    ranked_items = filter_ranked_items(set_items)

    # If no ranked items exist in this set, this is the first item
    if not ranked_items:
        item_obj.tier = get_initial_tier(item_in.tier_set.value)
        item_obj.position = generate_key_between(None, None)  # Initial position
        await item_crud.create(db, item_obj)
        await db.commit()
        await db.refresh(item_obj)
        return item_obj  # type: ignore[return-value]

    # Sort the ranked items by position
    sorted_ranked = sort_items_by_position(ranked_items)
    if not sorted_ranked:
        # No valid ranked items, treat as first item
        item_obj.tier = get_initial_tier(item_in.tier_set.value)
        item_obj.position = generate_key_between(None, None)
        await item_crud.create(db, item_obj)
        await db.commit()
        await db.refresh(item_obj)
        return item_obj  # type: ignore[return-value]

    # Initialize comparison - save new item first to get a valid item_id
    await item_crud.create(db, item_obj)
    await db.flush()

    # Start comparison session
    db_session = await start_comparison(
        db,
        item_obj,
        list_obj.list_id,
        item_in.tier_set.value,
        ranked_items,
    )
    await db.commit()
    await db.refresh(db_session)
    await db.refresh(item_obj)

    # Get target item for response
    target_item = await item_crud.get_by_id(db, db_session.target_item_id)

    # Build comparison for response
    all_items = sort_items_by_position(ranked_items)
    comparison = Comparison(
        reference_item=item_obj,  # type: ignore[arg-type]
        target_item=target_item,  # type: ignore[arg-type]
        min_index=0,
        comparison_index=len(all_items) // 2,
        max_index=len(all_items) - 1,
        is_winner=None,
        done=False,
    )

    return build_comparison_session_response(
        db_session, item_obj, target_item, comparison
    )


@router.post("/comparison/result", response_model=Union[ComparisonSession, None])
async def submit_comparison_result(
    session_id: str,
    result_request: ComparisonResultRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Union[ComparisonSession, None]:
    """
    Submit a comparison result and get the next comparison.
    """
    # Parse session_id as UUID
    try:
        session_uuid = uuid.UUID(session_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=COMPARISON_SESSION_NOT_FOUND_ERROR,
        )

    # Load active session from database
    db_session = await comparison_crud.get_active(db, session_uuid)
    if not db_session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=COMPARISON_SESSION_NOT_FOUND_ERROR,
        )

    # Verify list ownership
    list_obj = await list_crud.get_by_id_and_user(
        db, db_session.list_id, current_user.user_id
    )
    if not list_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=COMPARISON_SESSION_NOT_FOUND_ERROR,
        )

    ref_tier_set = db_session.tier_set

    # Get all items in the list with the same tier_set
    set_items = await item_crud.get_by_list_and_tier_set(
        db, db_session.list_id, ref_tier_set
    )

    # Filter to ranked items only (exclude the new item being ranked)
    ranked_items = filter_ranked_items(set_items, db_session.new_item_id)

    # Get the new item and current target item
    new_item = await item_crud.get_by_id(db, db_session.new_item_id)
    target_item = await item_crud.get_by_id(db, db_session.target_item_id)

    if not new_item or not target_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail=ITEM_NOT_FOUND_ERROR
        )

    # Process the comparison result
    is_winner = result_request.result == "better"
    comparison, sorted_items = process_comparison_result(
        db_session, is_winner, new_item, target_item, ranked_items
    )

    if comparison.done:
        # Finalize the comparison (set position and tiers)
        await finalize_comparison(
            db,
            db_session,
            comparison,
            new_item,
            target_item,
            db_session.list_id,
            ref_tier_set,
        )
        await db.commit()
        return None

    # Update session in database with new comparison state
    await comparison_crud.update(
        db,
        db_session,
        comparison.target_item.item_id,
        comparison.min_index,
        comparison.max_index,
        comparison.comparison_index,
    )
    await db.commit()
    await db.refresh(db_session)

    # Get the new target item from database for the response
    new_target_item = await item_crud.get_by_id(db, comparison.target_item.item_id)

    return build_comparison_session_response(
        db_session, new_item, new_target_item, comparison
    )


@router.get("/items/{item_id}", response_model=Item)
async def read_item(
    item_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Item:
    """
    Get a specific item by ID.
    """
    item_obj = await item_crud.get_by_id_with_ownership(
        db, item_id, current_user.user_id
    )
    if not item_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=ITEM_NOT_FOUND_ERROR,
        )

    return item_obj  # type: ignore[return-value]


@router.put("/items/{item_id}", response_model=Item)
async def update_item(
    item_id: uuid.UUID,
    item_in: ItemUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Item:
    """
    Update an item's metadata.
    """
    item_obj = await item_crud.get_by_id_with_ownership(
        db, item_id, current_user.user_id
    )
    if not item_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=ITEM_NOT_FOUND_ERROR,
        )

    update_data = item_in.dict(exclude_unset=True)
    await item_crud.update(db, item_obj, update_data)
    await db.commit()
    await db.refresh(item_obj)

    return item_obj  # type: ignore[return-value]


@router.delete("/items/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_item(
    item_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> None:
    """
    Delete an item.
    """
    item_obj = await item_crud.get_by_id_with_ownership(
        db, item_id, current_user.user_id
    )
    if not item_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=ITEM_NOT_FOUND_ERROR,
        )

    await item_crud.delete(db, item_obj)
    await db.commit()


@router.get("/comparison/{session_id}/status", response_model=ComparisonSession)
async def get_comparison_status(
    session_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ComparisonSession:
    """
    Get the status of a comparison session.
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
    db_session = await comparison_crud.get_by_id(db, session_uuid)
    if not db_session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=SESSION_NOT_FOUND_ERROR,
        )

    # Verify list ownership
    list_obj = await list_crud.get_by_id_and_user(
        db, db_session.list_id, current_user.user_id
    )
    if not list_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=SESSION_NOT_FOUND_ERROR,
        )

    # Get the new item and current target item
    new_item = await item_crud.get_by_id(db, db_session.new_item_id)
    target_item = await item_crud.get_by_id(db, db_session.target_item_id)

    if not new_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=ITEM_NOT_FOUND_ERROR,
        )

    return build_comparison_session_response(db_session, new_item, target_item)
