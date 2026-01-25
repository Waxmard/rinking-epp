"""Fractional indexing for ordered items using Base-62 lexicographic keys.

Keys consist of digits and letters: 0-9, A-Z, a-z (62 characters total).
This provides lexicographic ordering where "a0" < "a1" < "b0" etc.
"""

from typing import List, Optional

# Base-62 alphabet: 0-9, A-Z, a-z
ALPHABET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
BASE = len(ALPHABET)  # 62


def _char_to_index(c: str) -> int:
    """Convert a character to its index in the alphabet."""
    return ALPHABET.index(c)


def _index_to_char(i: int) -> str:
    """Convert an index to its character in the alphabet."""
    return ALPHABET[i]


def _midpoint_char(a: str, b: str) -> str:
    """Get the character midpoint between two characters."""
    a_idx = _char_to_index(a)
    b_idx = _char_to_index(b)
    mid_idx = (a_idx + b_idx) // 2
    return _index_to_char(mid_idx)


def _increment_char(c: str) -> Optional[str]:
    """Increment a character by one, returning None if at max."""
    idx = _char_to_index(c)
    if idx >= BASE - 1:
        return None
    return _index_to_char(idx + 1)


def _decrement_char(c: str) -> Optional[str]:
    """Decrement a character by one, returning None if at min."""
    idx = _char_to_index(c)
    if idx <= 0:
        return None
    return _index_to_char(idx - 1)


def generate_key_between(a: Optional[str], b: Optional[str]) -> str:
    """
    Generate a key that sorts between a and b.

    Args:
        a: The lower bound key (None means generate key before b)
        b: The upper bound key (None means generate key after a)

    Returns:
        A string key that sorts lexicographically between a and b

    Raises:
        ValueError: If a >= b when both are provided

    Examples:
        generate_key_between(None, None) -> "a0"
        generate_key_between(None, "a0") -> "Z0"
        generate_key_between("a0", None) -> "a1"
        generate_key_between("a0", "a2") -> "a1"
        generate_key_between("a0", "a1") -> "a0V"
    """
    # Case 1: No bounds - return initial key
    if a is None and b is None:
        return "a0"

    # Case 2: No lower bound - generate key before b
    if a is None:
        assert b is not None
        # Try to decrement the first character
        first_dec = _decrement_char(b[0])
        if first_dec is not None:
            return first_dec + b[1:]
        # Can't decrement first char, prepend with midpoint
        return ALPHABET[BASE // 2] + b

    # Case 3: No upper bound - generate key after a
    if b is None:
        assert a is not None
        # Try to increment the last character
        last_inc = _increment_char(a[-1])
        if last_inc is not None:
            return a[:-1] + last_inc
        # Can't increment last char, extend the key
        return a + ALPHABET[BASE // 2]

    # Case 4: Both bounds provided
    if a >= b:
        raise ValueError(f"a must be less than b: {a!r} >= {b!r}")

    # Find the common prefix and first differing position
    min_len = min(len(a), len(b))
    common_prefix_len = 0
    for i in range(min_len):
        if a[i] != b[i]:
            break
        common_prefix_len += 1

    # Get the differing characters (or virtual characters for shorter strings)
    a_char = a[common_prefix_len] if common_prefix_len < len(a) else ALPHABET[0]
    b_char = b[common_prefix_len] if common_prefix_len < len(b) else ALPHABET[0]

    a_idx = _char_to_index(a_char)
    b_idx = _char_to_index(b_char)

    # If there's room between the characters, use the midpoint
    if b_idx - a_idx > 1:
        mid_char = _index_to_char((a_idx + b_idx) // 2)
        return a[:common_prefix_len] + mid_char

    # Characters are adjacent or same - need to extend
    # Use the lower key's character and append a midpoint
    suffix = a[common_prefix_len + 1 :] if common_prefix_len + 1 < len(a) else ""

    # Find a character we can extend with
    if suffix:
        # Try to find midpoint between suffix's last char and max
        last_suffix_idx = _char_to_index(suffix[-1])
        if last_suffix_idx < BASE - 1:
            mid_idx = (last_suffix_idx + BASE - 1) // 2
            return a[:common_prefix_len] + a_char + suffix[:-1] + _index_to_char(mid_idx)

    # Extend with a midpoint character
    return a[:common_prefix_len] + a_char + suffix + ALPHABET[BASE // 2]


def generate_n_keys_between(
    a: Optional[str], b: Optional[str], n: int
) -> List[str]:
    """
    Generate n keys that sort between a and b.

    Args:
        a: The lower bound key (None means before all)
        b: The upper bound key (None means after all)
        n: Number of keys to generate

    Returns:
        List of n string keys in sorted order

    Raises:
        ValueError: If n < 1 or if a >= b when both are provided
    """
    if n < 1:
        raise ValueError("n must be at least 1")

    if n == 1:
        return [generate_key_between(a, b)]

    keys: List[str] = []
    prev = a
    for i in range(n):
        # For even distribution, we could be smarter here,
        # but iterative generation is simpler and works fine
        key = generate_key_between(prev, b)
        keys.append(key)
        prev = key

    return keys
