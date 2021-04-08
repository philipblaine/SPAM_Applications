def merge_intervals(int_list):

    sorted_list = sorted(int_list)
    closed_list = []
    for ele in sorted_list:
        try:
            ele = RealSet.closed(ele[0],ele[1])[0]
            closed_list.append(ele)
        except:
            ele = RealSet.closed_open(ele[0],ele[1])[0]
            closed_list.append(ele)

    hull_list = []

    for i in range(len(closed_list)-1):
        intersection = closed_list[i].intersection(closed_list[i+1])
        if intersection != RealSet.closed(0,0)[0]:
            hull = closed_list[i].convex_hull(closed_list[i+1])
        else:
            hull = closed_list[i]
        hull_list.append(hull)
    
    return hull_list