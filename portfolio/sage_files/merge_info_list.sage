def combine_intervals_with_same_portfolio(intervals_and_weights):
    sorted_list = sorted(intervals_and_weights, key = lambda x: x[0][0])
    #sorted_list.sort(key = lambda x: x[0][0])
    combined_list = []
    cc = None
    bb = None
    for (a, b), c in sorted_list:
        assert(bb is None or bb >= a)
        if c == cc:
            if b > bb:
                bb = b
        else:
            if not cc is None:
                combined_list.append(((aa, bb), cc))
            aa = a
            bb = b
            cc = c
    combined_list.append(((aa, bb), cc))
    return combined_list