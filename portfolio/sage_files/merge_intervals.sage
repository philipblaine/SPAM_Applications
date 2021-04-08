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

    for i in range(len(closed_list)):
        
        try:
            intersection = closed_list[i].intersection(closed_list[i+1])
            if intersection != RealSet.closed(0,0)[0]:
                print(i, " nonempty ", intersection)
                hull = closed_list[i].convex_hull(closed_list[i+1])
                hull_list.append(hull)
        except:
            print("empty")
            hull_list.append(closed_list[i])

    return hull_list