"""Helper functions for data cleaning scripts."""


def extract_code_number(code):
    """For natural sorting, extract (for example) '123' from '123 ABC'.

    Lexicographical sorting of code strings does not result in a natural ordering.
    Return a tuple of all numerical sections. E.g. "123.4 ABC" would return (123, 4)
    so that it naturally sorts before "123.10" and after "50.4".
    """
    current = ''
    parts = []
    for i, ch in enumerate(code):
        if ch.isdigit():
            current += ch
        elif ch == '.':
            if not current:
                # Break if we get something weird like '123...4'
                break
            parts.append(int(current))
            current = ''
        else:
            break
    if current:
        parts.append(int(current))
    return tuple(parts)
