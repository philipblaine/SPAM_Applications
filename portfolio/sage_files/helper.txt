for c in complex.components:
    c.bsa.tighten_upstairs_by_mccormick(max_iter=1)
    c.interval = (c.bsa._bounds[0])
    info_list.append([c.interval, c.region_type])