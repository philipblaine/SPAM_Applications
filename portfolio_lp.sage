def portfolio_lp(num_sec, periods, hist_data, mu):


    lp = MixedIntegerLinearProgram(solver = ("GLPK", "InteractiveLP"), maximization=True, base_ring=K)
    x = lp.new_variable(nonnegative=True)

    cols = []

    for ele in hist_data:
        cols.append(ele)

    print(cols)

    colsums = []
    colsum = 0

    for ele in cols:
        colsum = 0
        for i in ele:
            colsum += i
        colsums.append(colsum)

    print(colsums)

    for i in range(len(colsums)):
        colsums[i] = colsums[i]/periods

    xsum = sum(x[i] for i in range(1,num_sec))

    x0 = 1 - xsum

    lp.add_constraint(x0 >= 0)

    #for t in range(num_sec, num_sec+periods):
        #for i in range(len(cols)):
            #lp.add_constraint((-x[t] <= (x0*cols[i][t-num_sec]-rsums[i]) + (x


    lp.set_objective(mu*(x0*colsums[0]+sum([x[i]*colsums[i] for i in range(1,num_sec)])) - ((1/periods)*sum([x[o] for o in range(num_sec,num_sec+periods)])))

    print(x0)

    print(colsums)

    return lp