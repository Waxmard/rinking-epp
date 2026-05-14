"""Tests for service layer functions."""

import uuid
from datetime import datetime
from typing import Callable

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import (
    ComparisonSession as ComparisonSessionModel,
    Item as ItemModel,
    List as ListModel,
)
from app.schemas.item import Comparison
from app.services.comparison_service import (
    build_comparison_session_response,
    finalize_comparison,
    start_comparison,
)
from app.services.ranking import (
    assign_tiers_for_set,
    filter_ranked_items,
    get_initial_tier,
)


def create_test_item(
    name: str = "Test Item",
    tier: str | None = "A",
    tier_set: str = "good",
    list_id: uuid.UUID | None = None,
    item_id: uuid.UUID | None = None,
    position: str | None = "a0",
) -> ItemModel:
    """Helper function to create ItemModel instances for unit tests."""
    return ItemModel(
        item_id=item_id or uuid.uuid4(),
        list_id=list_id or uuid.uuid4(),
        name=name,
        description="",
        image_url=None,
        position=position,
        rating=None,
        tier=tier,
        tier_set=tier_set,
        created_at=datetime.now(),
        updated_at=datetime.now(),
    )


def create_test_session(
    list_id: uuid.UUID,
    new_item_id: uuid.UUID,
    target_item_id: uuid.UUID,
    tier_set: str = "good",
    is_complete: bool = False,
    min_index: int = 0,
    max_index: int = 0,
    comparison_index: int = 0,
) -> ComparisonSessionModel:
    """Helper function to create ComparisonSessionModel instances for unit tests."""
    return ComparisonSessionModel(
        session_id=uuid.uuid4(),
        list_id=list_id,
        new_item_id=new_item_id,
        target_item_id=target_item_id,
        tier_set=tier_set,
        min_index=min_index,
        max_index=max_index,
        comparison_index=comparison_index,
        is_complete=is_complete,
        created_at=datetime.now(),
        updated_at=datetime.now(),
    )


def create_test_comparison(
    reference_item: ItemModel,
    target_item: ItemModel,
    min_index: int = 0,
    max_index: int = 0,
    comparison_index: int = 0,
    is_winner: bool | None = None,
    done: bool = False,
) -> Comparison:
    """Helper function to create Comparison schema instances for unit tests."""
    return Comparison(
        reference_item=reference_item,  # type: ignore
        target_item=target_item,  # type: ignore
        min_index=min_index,
        comparison_index=comparison_index,
        max_index=max_index,
        is_winner=is_winner,
        done=done,
    )


@pytest.mark.asyncio
class TestComparisonService:
    """Tests for comparison service functions."""

    async def test_start_comparison(
        self,
        test_db: AsyncSession,
        test_list: ListModel,
        item_factory: Callable[..., ItemModel],
    ):
        """Test starting a comparison session."""
        # Create ranked items for comparison
        item1 = item_factory(name="Ranked Item 1")
        test_db.add(item1)
        await test_db.commit()

        # Create new item to rank
        new_item = item_factory(name="New Item", tier=None, position=None)
        test_db.add(new_item)
        await test_db.commit()

        session = await start_comparison(
            test_db,
            new_item,
            test_list.list_id,
            "good",
            [item1],
        )
        await test_db.commit()

        assert session.session_id is not None
        assert session.list_id == test_list.list_id
        assert session.new_item_id == new_item.item_id
        assert session.is_complete is False

    def test_build_comparison_session_response_complete(
        self, test_db: AsyncSession, test_list: ListModel, test_item: ItemModel
    ):
        """Test building response for completed session."""
        session = create_test_session(
            list_id=test_list.list_id,
            new_item_id=test_item.item_id,
            target_item_id=test_item.item_id,
            is_complete=True,
        )

        response = build_comparison_session_response(session, test_item, None)

        assert response.session_id == str(session.session_id)
        assert response.is_complete is True
        assert response.current_comparison is None

    def test_build_comparison_session_response_with_comparison(
        self, test_db: AsyncSession, test_list: ListModel, test_item: ItemModel
    ):
        """Test building response with pre-built comparison."""
        session = create_test_session(
            list_id=test_list.list_id,
            new_item_id=test_item.item_id,
            target_item_id=test_item.item_id,
            max_index=5,
            comparison_index=2,
        )

        comparison = create_test_comparison(
            reference_item=test_item,
            target_item=test_item,
            max_index=5,
            comparison_index=2,
        )

        response = build_comparison_session_response(
            session, test_item, test_item, comparison
        )

        assert response.is_complete is False
        assert response.current_comparison is not None
        assert response.current_comparison.comparison_index == 2

    async def test_finalize_comparison_winner(
        self,
        test_db: AsyncSession,
        test_list: ListModel,
        item_factory: Callable[..., ItemModel],
    ):
        """Test finalizing comparison when new item wins."""
        # Create target item (existing ranked item)
        target_item = item_factory(name="Target Item", position="a0")
        test_db.add(target_item)
        await test_db.commit()

        # Create new item
        new_item = item_factory(name="New Item", tier=None, position=None)
        test_db.add(new_item)
        await test_db.commit()

        # Create session
        session = create_test_session(
            list_id=test_list.list_id,
            new_item_id=new_item.item_id,
            target_item_id=target_item.item_id,
        )
        test_db.add(session)
        await test_db.commit()

        # Create comparison result (new item wins)
        # comparison_index=0 since target is the only item at index 0
        comparison = create_test_comparison(
            reference_item=new_item,
            target_item=target_item,
            comparison_index=0,
            is_winner=True,
            done=True,
        )

        await finalize_comparison(
            test_db,
            session,
            comparison,
            new_item,
            target_item,
            test_list.list_id,
            "good",
        )
        await test_db.commit()

        # Verify position is set (new item wins means it goes after target)
        await test_db.refresh(new_item)
        assert new_item.position is not None
        assert new_item.position > target_item.position

    async def test_finalize_comparison_loser(
        self,
        test_db: AsyncSession,
        test_list: ListModel,
        item_factory: Callable[..., ItemModel],
    ):
        """Test finalizing comparison when new item loses."""
        # Create target item
        target_item = item_factory(name="Target Item", position="a0")
        test_db.add(target_item)
        await test_db.commit()

        # Create new item
        new_item = item_factory(name="New Item", tier=None, position=None)
        test_db.add(new_item)
        await test_db.commit()

        # Create session
        session = create_test_session(
            list_id=test_list.list_id,
            new_item_id=new_item.item_id,
            target_item_id=target_item.item_id,
        )
        test_db.add(session)
        await test_db.commit()

        # Create comparison result (new item loses)
        # comparison_index=0 since target is the only item at index 0
        comparison = create_test_comparison(
            reference_item=new_item,
            target_item=target_item,
            comparison_index=0,
            is_winner=False,
            done=True,
        )

        await finalize_comparison(
            test_db,
            session,
            comparison,
            new_item,
            target_item,
            test_list.list_id,
            "good",
        )
        await test_db.commit()

        # Verify position is set (new item loses means it goes before target)
        await test_db.refresh(new_item)
        assert new_item.position is not None
        assert new_item.position < target_item.position

    async def test_finalize_comparison_marks_session_complete(
        self,
        test_db: AsyncSession,
        test_list: ListModel,
        item_factory: Callable[..., ItemModel],
    ):
        """Test finalizing comparison marks session as complete."""
        # Create target item
        target_item = item_factory(name="Target Item", position="a0")
        test_db.add(target_item)
        await test_db.commit()

        new_item = item_factory(name="New Item", tier=None, position=None)
        test_db.add(new_item)
        await test_db.commit()

        # Create session
        session = create_test_session(
            list_id=test_list.list_id,
            new_item_id=new_item.item_id,
            target_item_id=target_item.item_id,
        )
        test_db.add(session)
        await test_db.commit()

        # Create comparison result
        # comparison_index=0 since target is the only item at index 0
        comparison = create_test_comparison(
            reference_item=new_item,
            target_item=target_item,
            comparison_index=0,
            is_winner=True,
            done=True,
        )

        await finalize_comparison(
            test_db,
            session,
            comparison,
            new_item,
            target_item,
            test_list.list_id,
            "good",
        )
        await test_db.commit()

        # Verify session was marked complete
        await test_db.refresh(session)
        assert session.is_complete is True


class TestRankingService:
    """Tests for ranking service functions."""

    def test_get_initial_tier_good(self):
        """Test initial tier for 'good' tier_set."""
        assert get_initial_tier("good") == "A"

    def test_get_initial_tier_mid(self):
        """Test initial tier for 'mid' tier_set."""
        assert get_initial_tier("mid") == "C"

    def test_get_initial_tier_bad(self):
        """Test initial tier for 'bad' tier_set."""
        assert get_initial_tier("bad") == "F"

    def test_get_initial_tier_unknown(self):
        """Test initial tier for unknown tier_set."""
        # Should default to "C" for unknown tier_sets
        assert get_initial_tier("unknown") == "C"

    def test_filter_ranked_items_empty(self):
        """Test filtering empty list."""
        result = filter_ranked_items([])
        assert result == []

    def test_filter_ranked_items_all_ranked(self):
        """Test filtering when all items are ranked (have position)."""
        items = [create_test_item(name=f"Item {i}", position=f"a{i}") for i in range(3)]
        result = filter_ranked_items(items)
        assert len(result) == 3

    def test_filter_ranked_items_excludes_unranked(self):
        """Test that items without position are excluded."""
        items = [
            create_test_item(name="Ranked", position="a0"),
            create_test_item(name="Unranked", position=None),
        ]
        result = filter_ranked_items(items)
        assert len(result) == 1
        assert result[0].name == "Ranked"

    def test_filter_ranked_items_excludes_specific_id(self):
        """Test that specific item_id is excluded."""
        exclude_id = uuid.uuid4()
        items = [
            create_test_item(name="Item 1", position="a0"),
            create_test_item(name="Item to exclude", item_id=exclude_id, position="a1"),
        ]
        result = filter_ranked_items(items, exclude_id)
        assert len(result) == 1
        assert result[0].item_id != exclude_id

    def test_assign_tiers_for_set_good(self):
        """Test tier assignment for 'good' tier_set."""
        list_id = uuid.uuid4()
        items = [
            create_test_item(name=f"Item {i}", list_id=list_id, position=f"a{i}")
            for i in range(4)
        ]

        assign_tiers_for_set(items, "good")

        # All items should have tiers (S or A for good tier_set)
        for item in items:
            assert item.tier in ["S", "A"]

    def test_assign_tiers_for_set_mid(self):
        """Test tier assignment for 'mid' tier_set."""
        list_id = uuid.uuid4()
        items = [
            create_test_item(
                name=f"Item {i}",
                tier="C",
                tier_set="mid",
                list_id=list_id,
                position=f"a{i}",
            )
            for i in range(4)
        ]

        assign_tiers_for_set(items, "mid")

        # All items should have tiers (B, C, D for mid tier_set)
        for item in items:
            assert item.tier in ["B", "C", "D"]

    def test_assign_tiers_for_set_bad(self):
        """Test tier assignment for 'bad' tier_set."""
        list_id = uuid.uuid4()
        items = [
            create_test_item(
                name=f"Item {i}",
                tier="F",
                tier_set="bad",
                list_id=list_id,
                position=f"a{i}",
            )
            for i in range(2)
        ]

        assign_tiers_for_set(items, "bad")

        # All items should have tiers (D, F for bad tier_set)
        for item in items:
            assert item.tier in ["D", "F"]

    def test_assign_tiers_for_set_empty(self):
        """Test tier assignment with empty list returns early."""
        # Should not raise any exception
        assign_tiers_for_set([], "good")

    def test_assign_tiers_for_set_unknown_tier_set(self):
        """Test tier assignment with unknown tier_set returns early."""
        item = create_test_item(name="Item", tier_set="unknown")
        original_tier = item.tier

        # Should return early without modifying items
        assign_tiers_for_set([item], "unknown")

        # Tier should remain unchanged
        assert item.tier == original_tier


class TestHelperFunctions:
    """Tests for helper utility functions."""

    def test_sort_items_by_position_empty(self):
        """Test sorting empty list returns empty list."""
        from app.utils.helper import sort_items_by_position

        result = sort_items_by_position([])
        assert result == []

    def test_sort_items_by_position_ordered(self):
        """Test sorting items by position."""
        from app.utils.helper import sort_items_by_position

        item1 = create_test_item(name="Item 1", position="a0")
        item2 = create_test_item(name="Item 2", position="a1")
        item3 = create_test_item(name="Item 3", position="a2")

        # Pass in reverse order
        result = sort_items_by_position([item3, item1, item2])

        assert result[0] is item1
        assert result[1] is item2
        assert result[2] is item3
