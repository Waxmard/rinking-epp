from typing import Dict, List, Tuple

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.sql import func

from app.db.models import Item
from app.schemas.item import NextComparison, TierRank


async def find_next_comparison_pair(db: AsyncSession, list_id: int) -> NextComparison:
    """
    Find the next pair of items to compare.
    
    This selects a newly added item that needs ranking and an already ranked item.
    If all items are ranked, it chooses two items with adjacent rankings.
    """
    # Find an unranked item
    stmt = (
        select(Item)
        .where(Item.list_id == list_id)
        .where(Item.position.is_(None))
        .order_by(func.random())
        .limit(1)
    )
    result = await db.execute(stmt)
    unranked_item = result.scalar_one_or_none()

    if unranked_item:
        # Find a ranked item for comparison
        stmt = (
            select(Item)
            .where(Item.list_id == list_id)
            .where(Item.position.is_not(None))
            .order_by(func.random())
            .limit(1)
        )
        result = await db.execute(stmt)
        ranked_item = result.scalar_one_or_none()

        if ranked_item:
            return NextComparison(item1=unranked_item, item2=ranked_item)
        else:
            # If there are no ranked items yet, choose another unranked item
            stmt = (
                select(Item)
                .where(Item.list_id == list_id)
                .where(Item.position.is_(None))
                .where(Item.item_id != unranked_item.item_id)
                .order_by(func.random())
                .limit(1)
            )
            result = await db.execute(stmt)
            second_unranked_item = result.scalar_one_or_none()

            if second_unranked_item:
                return NextComparison(item1=unranked_item, item2=second_unranked_item)
            else:
                # Only one item exists, can't make a comparison
                raise ValueError("Not enough items for comparison")
    else:
        # All items are ranked, compare adjacent items for refinement
        stmt = select(Item).where(Item.list_id == list_id).order_by(Item.position)
        result = await db.execute(stmt)
        items = result.scalars().all()

        if len(items) < 2:
            raise ValueError("Not enough items for comparison")

        # Choose two adjacent items randomly
        import random

        idx = random.randint(0, len(items) - 2)
        return NextComparison(item1=items[idx], item2=items[idx + 1])


async def update_rankings(
    db: AsyncSession, list_id: int, winner_id: int, loser_id: int
) -> List[Item]:
    """
    Update rankings based on a comparison result.
    
    After each comparison, this function updates the position of all items
    in the list and recalculates their ratings.
    """
    # Get all items in the list
    stmt = select(Item).where(Item.list_id == list_id).order_by(Item.position)
    result = await db.execute(stmt)
    items = result.scalars().all()

    # Get the winner and loser items
    winner = next((item for item in items if item.item_id == winner_id), None)
    loser = next((item for item in items if item.item_id == loser_id), None)

    if not winner or not loser:
        raise ValueError("Winner or loser item not found")

    # Handle first comparison in the list
    if all(item.position is None for item in items):
        winner.position = 1
        loser.position = 2
    else:
        # Handle case where winner is already ranked but loser is not
        if winner.position is not None and loser.position is None:
            # Insert loser after winner
            for item in items:
                if item.position is not None and item.position > winner.position:
                    item.position += 1
            loser.position = winner.position + 1
        # Handle case where loser is already ranked but winner is not
        elif loser.position is not None and winner.position is None:
            # Insert winner before loser
            for item in items:
                if item.position is not None and item.position >= loser.position:
                    item.position += 1
            winner.position = loser.position
        # Handle case where both are ranked
        elif winner.position is not None and loser.position is not None:
            # If winner is already ranked higher than loser, no change needed
            if winner.position < loser.position:
                pass
            # If loser is ranked higher than winner, swap them
            else:
                # Move winner before loser
                new_pos = loser.position
                # Shift items between old winner position and new position
                for item in items:
                    if (
                        item.item_id != winner.item_id
                        and item.position is not None
                        and loser.position <= item.position < winner.position
                    ):
                        item.position += 1
                winner.position = new_pos

    # Recalculate ratings based on positions
    items_with_positions = [item for item in items if item.position is not None]
    items_with_positions.sort(key=lambda x: x.position)

    total_items = len(items_with_positions)
    if total_items > 0:
        for idx, item in enumerate(items_with_positions):
            # Scale from 10.0 (top) to 0.1 (bottom)
            if total_items > 1:
                item.rating = 10.0 - ((idx) / (total_items - 1)) * 9.9
            else:
                item.rating = 10.0

            # Set tier based on rating
            item.tier = get_tier_from_rating(item.rating)

    # Save changes
    await db.commit()

    # Return the updated items
    stmt = select(Item).where(Item.list_id == list_id).order_by(Item.position)
    result = await db.execute(stmt)
    return result.scalars().all()


async def get_next_items_to_compare(
    db: AsyncSession, list_id: int, current_item_id: int
) -> Tuple[Item, Item]:
    """
    Get the next two items to compare when ranking a new item.
    
    This implements a binary search approach to efficiently find
    the right position for a new item with minimal comparisons.
    """
    # Get all ranked items
    stmt = (
        select(Item)
        .where(Item.list_id == list_id)
        .where(Item.position.is_not(None))
        .order_by(Item.position)
    )
    result = await db.execute(stmt)
    ranked_items = result.scalars().all()

    # Get the current item being ranked
    stmt = select(Item).where(Item.item_id == current_item_id)
    result = await db.execute(stmt)
    current_item = result.scalar_one_or_none()

    if not current_item:
        raise ValueError("Item not found")

    # If there are no ranked items yet
    if not ranked_items:
        raise ValueError("No ranked items to compare with")

    # If this is the first comparison for this item
    if current_item.position is None:
        # Start with middle item
        mid_idx = len(ranked_items) // 2
        return current_item, ranked_items[mid_idx]
    else:
        # Binary search to find next comparison
        # Find current item's position in the sorted list
        sorted_items = sorted(
            [*ranked_items, current_item], key=lambda x: x.position or float("inf")
        )
        current_idx = next(
            i for i, item in enumerate(sorted_items) if item.item_id == current_item_id
        )

        # If it's at position 0, compare with the next item
        if current_idx == 0 and len(sorted_items) > 1:
            return current_item, sorted_items[1]
        # If it's at the last position, compare with the previous item
        elif current_idx == len(sorted_items) - 1:
            return current_item, sorted_items[current_idx - 1]
        # Otherwise, choose the item to compare based on confidence
        else:
            # In a more advanced implementation, you could use confidence
            # or other metrics to determine which comparison would be most informative
            # For now, just alternate between comparing with next and previous
            if len(sorted_items) > current_idx + 1:
                return current_item, sorted_items[current_idx + 1]
            else:
                return current_item, sorted_items[current_idx - 1]


def get_tier_from_rating(rating: float) -> str:
    """
    Convert a numeric rating (0.1-10.0) to a tier ranking (S-F).

    Args:
        rating: A float between 0.1 and 10.0 representing the item's rating

    Returns:
        A string representing the tier (S, A, B, C, D, E, or F)
    """
    tier_ranges = {
        'S': (9.0, 10.0),
        'A': (7.5, 8.9),
        'B': (6.0, 7.4),
        'C': (4.5, 5.9),
        'D': (3.0, 4.4),
        'E': (1.5, 2.9),
        'F': (0.1, 1.4)
    }

    for tier, (min_val, max_val) in tier_ranges.items():
        if min_val <= rating <= max_val:
            return tier

    # Default fallback (shouldn't happen with ratings 0.1-10.0)
    return 'C'
