"""Tests for fractional indexing."""

import pytest

from app.core.fractional_index import (
    ALPHABET,
    generate_key_between,
    generate_n_keys_between,
)


class TestBasicGeneration:
    def test_no_bounds_returns_initial(self) -> None:
        assert generate_key_between(None, None) == "a0"

    def test_after_a_increments_last_char(self) -> None:
        assert generate_key_between("a0", None) == "a1"

    def test_before_b_decrements_first_char(self) -> None:
        assert generate_key_between(None, "a0") == "Z0"

    def test_between_with_room_uses_midpoint(self) -> None:
        assert generate_key_between("a0", "a2") == "a1"

    def test_between_adjacent_extends(self) -> None:
        result = generate_key_between("a0", "a1")
        assert "a0" < result < "a1"

    def test_a_must_be_less_than_b(self) -> None:
        with pytest.raises(ValueError):
            generate_key_between("a1", "a0")

    def test_a_equal_to_b_raises(self) -> None:
        with pytest.raises(ValueError):
            generate_key_between("a0", "a0")


class TestPrependZeroFallback:
    """Cases where b starts with the minimum char ('0') — exercises the
    recursive front-insertion branch."""

    def test_before_b_starting_with_zero(self) -> None:
        # b[0] = '0' can't decrement; recurse into b[1:]
        result = generate_key_between(None, "0A")
        assert result < "0A"
        assert result.startswith("0")

    def test_before_b_starting_with_two_zeros(self) -> None:
        result = generate_key_between(None, "00A")
        assert result < "00A"

    def test_before_lone_min_char_raises(self) -> None:
        with pytest.raises(ValueError, match="cannot generate key before minimum"):
            generate_key_between(None, "0")

    def test_repeated_front_insertion_stays_ordered(self) -> None:
        """Simulate front insertions within alphabet headroom; each new key < previous."""
        prev = generate_key_between(None, None)  # "a0"
        for _ in range(30):
            key = generate_key_between(None, prev)
            assert key < prev, f"{key!r} not < {prev!r}"
            prev = key

    def test_front_insertion_eventually_exhausts(self) -> None:
        """After enough front insertions, alphabet headroom runs out and raises."""
        prev = generate_key_between(None, None)
        with pytest.raises(ValueError, match="cannot generate key before minimum"):
            for _ in range(200):
                prev = generate_key_between(None, prev)


class TestAppendMaxFallback:
    def test_after_a_ending_with_max(self) -> None:
        max_char = ALPHABET[-1]  # 'z'
        result = generate_key_between("a" + max_char, None)
        assert result > "a" + max_char

    def test_repeated_back_insertion_stays_ordered(self) -> None:
        key = generate_key_between(None, None)
        prev = key
        for _ in range(50):
            key = generate_key_between(prev, None)
            assert key > prev
            prev = key


class TestNKeys:
    def test_n_keys_strictly_increasing(self) -> None:
        keys = generate_n_keys_between("a0", "a9", 5)
        assert len(keys) == 5
        assert keys == sorted(keys)
        assert all(keys[i] < keys[i + 1] for i in range(len(keys) - 1))
        assert all("a0" < k < "a9" for k in keys)

    def test_n_keys_no_bounds(self) -> None:
        keys = generate_n_keys_between(None, None, 3)
        assert len(keys) == 3
        assert keys == sorted(keys)

    def test_n_must_be_at_least_one(self) -> None:
        with pytest.raises(ValueError):
            generate_n_keys_between(None, None, 0)
