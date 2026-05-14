from typing import Any

from app.schemas.item import Comparison


def find_next_comparison(all_items: list[Any], comparison: Comparison) -> Comparison:
    """
    Return the next comparison item

    Fetches all items in the list and binary-searches for the next item to compare.
    """
    if comparison.is_winner:
        comparison.max_index = comparison.comparison_index
    else:
        comparison.min_index = comparison.comparison_index

    comparison.comparison_index = (comparison.min_index + comparison.max_index) // 2
    comparison.target_item = all_items[comparison.comparison_index]
    comparison.done = comparison.max_index - comparison.min_index <= 1
    return comparison
