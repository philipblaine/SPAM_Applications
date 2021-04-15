def merge_info_list(info_list):
    r"""
    Returns the total interval covered by some list of intervals.

    EXAMPLES::
 
    need to redo once done

        

    """

    #info_list contains [(lowbound, upbound), (optsol tuple)]

    info_list.sort(key = lambda x: x[0][0])

    sorted_info = sorted(info_list)

    merged_list= []
    for i in range(len(sorted_info)-1):
        intervals = (sorted_info[i][0], sorted_info[i+1][0])
        #info_list[i][1] is the optsol tuple
        if info_list[i][1] == info_list[i+1][1]:
            #for some existing union_of_intervals method??
            intervals = union_of_intervals(sorted_info[i][0], sorted_info[i+1][0])
        if len(intervals) == 1:
            merged_list.append([intervals, info_list[i][1]])
        else:
            merged_list.append([intervals[0], info_list[i][1]])
            merged_list.append([intervals[1], info_list[i+1][1]])
            
    return merged_list