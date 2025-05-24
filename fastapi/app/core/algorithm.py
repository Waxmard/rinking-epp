from typing import List, Tuple

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.sql import func

from app.db.models import Item
from app.schemas.item import Comparison

def find_next_comparison(all_items: List[Item], comparison: Comparison, is_winner: bool) -> Comparison:
    """
    Return the next comparison item

    This fetches all items in the list and performs binary search to get the next item to compare
    """
    if not is_winner:
        comparison.high = comparison.mid
    else:
        comparison.low = comparison.mid
    
    comparison.mid = (comparison.low + comparison.high) // 2
    comparison.item2 = all_items[comparison.mid]
    comparison.done = True if comparison.high - comparison.low <= 1 else False
    return comparison