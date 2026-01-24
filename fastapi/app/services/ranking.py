"""Ranking and tier assignment business logic."""

import uuid
from typing import List, Optional

from app.db.models import Item as ItemModel

# Tier assignment mapping: tier_set -> (high_tier, low_tier)
TIER_SET_MAP = {
    "good": ("S", "A"),
    "mid": ("B", "C"),
    "bad": ("D", "F"),
}

# Initial tier for first item in each tier_set (lower tier)
INITIAL_TIER_MAP = {
    "good": "A",
    "mid": "C",
    "bad": "F",
}


def get_initial_tier(tier_set: str) -> str:
    """Get the initial tier for the first item in a tier_set."""
    return INITIAL_TIER_MAP.get(tier_set, "C")


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


def filter_ranked_items(
    items: List[ItemModel], exclude_id: Optional[uuid.UUID] = None
) -> List[ItemModel]:
    """
    Filter items to only those that have been ranked (have a tier assigned).

    Args:
        items: List of items to filter
        exclude_id: Optional item ID to exclude from the result

    Returns:
        List of ranked items, optionally excluding the specified item
    """
    if exclude_id is None:
        return [item for item in items if item.tier is not None]
    return [
        item for item in items if item.tier is not None and item.item_id != exclude_id
    ]
