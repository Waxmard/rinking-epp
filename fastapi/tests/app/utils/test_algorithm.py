import pytest
from unittest.mock import AsyncMock, MagicMock, create_autospec
from app.schemas.item import Item, Comparison
from app.core.algorithm import find_next_comparison

# Create mock classes for testing
class MockItem:
    def __init__(self, position=None, list_id=None, item_id=None):
        self.position = position
        self.list_id = list_id
        self.item_id = item_id

    def __repr__(self):
        return f"Item(id={self.item_id}, position={self.position})"

# Mock the imports
Item = MockItem

@pytest.fixture
def mock_item():
    item = MockItem()
    item.list_id = 1
    item.position = None
    item.item_id = 1
    return item


@pytest.mark.asyncio
async def test_find_next_comparison_initial(mock_item):
    """Test initial comparison with no previous state"""
    # Create items
    item1 = mock_item
    item1.position = None
    item2 = mock_item
    item2.position = 0
    item3 = mock_item
    item3.position = 1
    
    all_items = [item2, item3]
    comparison = Comparison(
        reference_item=item1,
        target_item=item2,
        comparison_index=None,
        min_index=0,
        max_index=1
    )
    
    result = find_next_comparison(all_items, comparison, False)
    assert result.target_item == item2
    assert result.comparison_index == 1
    assert result.min_index == 0
    assert result.max_index == 2
    assert result.done == False


@pytest.mark.asyncio
async def test_find_next_comparison_worse(mock_item):
    """Test when item1 is worse than item2"""
    # Create items
    item1 = mock_item
    item1.position = 1
    item2 = mock_item
    item2.position = 2
    item3 = mock_item
    item3.position = 3
    item4 = mock_item
    item4.position = 4
    
    all_items = [item1, item2, item3, item4]
    comparison = Comparison(
        reference_item=item1,
        target_item=item2,
        comparison_index=2,
        min_index=0,
        max_index=3
    )
    
    result = find_next_comparison(all_items, comparison, False)
    assert result.target_item == item2
    assert result.comparison_index == 2
    assert result.min_index == 0
    assert result.max_index == 1
    assert result.done == True
    assert item1.position == 1
    assert item2.position == 2


@pytest.mark.asyncio
async def test_find_next_comparison_better(mock_item):
    """Test when item1 is better than item2"""
    # Create items
    item1 = mock_item
    item1.position = 1
    item2 = mock_item
    item2.position = 2
    item3 = mock_item
    item3.position = 3
    item4 = mock_item
    item4.position = 4
    
    all_items = [item1, item2, item3, item4]
    comparison = Comparison(
        reference_item=item1,
        target_item=item2,
        comparison_index=1,
        min_index=0,
        max_index=1
    )
    
    result = find_next_comparison(all_items, comparison, True)
    assert result.target_item == item2
    assert result.comparison_index == 1
    assert result.min_index == 0
    assert result.max_index == 1
    assert result.done == True
    assert item1.position == 1
    assert item2.position == 2


@pytest.mark.asyncio
async def test_find_next_comparison_done(mock_item):
    """Test when search is complete"""
    # Create items
    item1 = mock_item
    item1.position = 1
    item2 = mock_item
    item2.position = 2
    
    all_items = [item1, item2]
    comparison = Comparison(
        reference_item=item1,
        target_item=item2,
        comparison_index=1,
        min_index=1,
        max_index=1
    )
    
    result = find_next_comparison(all_items, comparison, True)
    assert result.target_item == item2
    assert result.comparison_index == 1
    assert result.min_index == 1
    assert result.max_index == 1
    assert result.done == True
    assert item1.position == 1
    assert item2.position == 2
