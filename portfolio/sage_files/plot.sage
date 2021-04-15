def plot_portfolio(info_list):
    from sage.plot.polygon import Polygon

    poly_list = []

    colors = ['red', 'blue', 'green', 'purple', 'magenta', 'orange', 'yellow', 'gray', 'cyan']


    for ele in info_list:
        height_sum = 0
        if ele[0][1] == Infinity:
            left = ele[0][0]
            right = 10
        else:
            left = ele[0][0]
            right = ele[0][1]
        for i in range(len(ele[1])):
            poly_list.append(polygon2d([[left, 0], [right, 0], [right, ele[1][i]+height_sum], [left, ele[1][i]+height_sum]], color=colors[i]))
            height_sum  += ele[1][i]
    
    return poly_list
        
        
        