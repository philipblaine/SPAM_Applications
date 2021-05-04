def plot_portfolio(info_list):
    from sage.plot.polygon import Polygon

    poly_list = []

    colors = ['red', 'green', 'blue', 'purple', 'gray', 'yellow', 'cyan', 'orange', 'magenta']


    for ele in info_list:
        height_sum = 0
        if ele[0][1] == Infinity:
            left = ele[0][0]
            right = 10
        else:
            left = ele[0][0]
            right = ele[0][1]
        for i in range(len(ele[1])):
            if left != Infinity:
                poly_list.append(polygon2d([[left, height_sum], [right, height_sum], [right, ele[1][i]+height_sum], [left, ele[1][i]+height_sum]], rgbcolor=colors[i], thickness=0, alpha=0.5))
                height_sum  += ele[1][i]

    
    
    return poly_list
        
        
        