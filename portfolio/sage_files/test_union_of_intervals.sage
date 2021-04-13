def merge_info_list(info_list):
    r"""
    Returns the total interval covered by some list of intervals.

    EXAMPLES::

        sage: int_list = [(0,1), (2,4), (1,3)]
        sage: test_union_of_intervals(int_list)
        sage: (0,4)

    """
    sorted_info = sorted(info_list)
    merged_list= []
    for i in range(len(sorted_info)-1):
        intervals = (sorted_info[i][0], sorted_info[i+1][0])
        if info_list[i][1] == info_list[i+1][1]:
            #for some union_of_intervals method
            intervals = union_of_intervals(sorted_info[i][0], sorted_info[i+1][0])
        if len(intervals) == 1:
            merged_list.append([intervals, info_list[i][1]])
        else:
            merged_list.append([intervals[0], info_list[i][1]])
            merged_list.append([intervals[1], info_list[i+1][1]])
            
    return merged_list