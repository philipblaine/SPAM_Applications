def test_union_of_intervals(int_list):
    r"""
    Returns the total interval covered by some list of intervals.

    EXAMPLES::

        sage: int_list = [(0,1), (2,4), (1,3)]
        sage: test_union_of_intervals(int_list)
        sage: (0,4)

    """

    sorted_intervals = sorted(int_list)
    if not sorted_intervals:
        return
    low, high = sorted_intervals[0]
    for interval in sorted_intervals[1:]:
        if interval[0] <= high:
            high = max(high, interval[1])
        else:
            low, high = interval

    return low, high