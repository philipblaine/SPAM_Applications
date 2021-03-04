def portfolio_lp(num_sec, periods, hist_data, mu_value, base_ring=None):

    """

    INPUT:  num_sec - number of securities/commodities in the problem
            periods - number of time periods, 
            hist_data - list of lists of historical data, 
            mu - risk aversion parameter

    OUTPUT: MILP defined by these inputs with hybrid_backend solver


    """
    
    if base_ring == None:
        base_ring = mu.parent()

    lp = MixedIntegerLinearProgram(solver = ("GLPK", "InteractiveLP"), maximization=True, base_ring=base_ring)
    x = lp.new_variable(nonnegative=True)

    cols = []

    for ele in hist_data:
        cols.append(ele)

    colsums = []
    colsum = 0

    for ele in cols:
        colsum = 0
        for i in ele:
            colsum += i
        colsums.append(colsum)

    for i in range(len(colsums)):
        colsums[i] = colsums[i]/periods

    xsum = sum(x[i] for i in range(1,num_sec))

    x0 = 1 - xsum

    lp.add_constraint(x0 >= 0)

    for t in range(num_sec, num_sec + periods):
        lp.add_constraint((-x[t] <= (x0*cols[0][t-num_sec]-colsums[0]) + sum([x[j]*(cols[j][t-num_sec]-colsums[j]) for j in range(1,num_sec)])))

    for t in range(num_sec, num_sec + periods):
        lp.add_constraint((x[t] >= (x0*cols[0][t-num_sec]-colsums[0]) + sum([x[j]*(cols[j][t-num_sec]-colsums[j]) for j in range(1,num_sec)])))


    lp.set_objective(mu*(x0*colsums[0]+sum([x[i]*colsums[i] for i in range(1,num_sec)])) - ((1/periods)*sum([x[o] for o in range(num_sec,num_sec+periods)])))


    return lp