def portfolio(mu):

    p = MixedIntegerLinearProgram(maximization=True)
    
    x = p.new_variable(integer=False, nonnegative=True)
    y = p.new_variable(integer=False, nonnegative=True)

    col1 = [3/4,7/10,8/11,1/2]
    col2 = [6/5,5/4,1,11/10]
    col3 = [9/7,8/7,1,8/7]

    r1 = (col1[0] + col1[1] + col1[2] + col1[3])/4
    r2 = (col2[0] + col2[1] + col2[2] + col2[3])/4
    r3 = (col3[0] + col3[1] + col3[2] + col3[3])/4

    obj = mu * (x[1]*r1 + x[2]*r2 + x[3]*r3) - (1/len(col1) * (y[1] + y[2] + y[3] + y[4]))

    p.add_constraint(x[0]>=0)
    p.add_constraint(x[1]>=0)
    p.add_constraint(x[2]>=0)
    p.add_constraint(x[3]>=0)

    p.add_constraint(x[1]+x[2]+x[3]+x[0]==1)

    p.add_constraint(-y[0] <= x[1]*(col1[0]-r1) + x[2]*(col2[0]-r2) + x[3]*(col3[0]-r3))
    p.add_constraint(y[0] >= x[1]*(col1[0]-r1) + x[2]*(col2[0]-r2) + x[3]*(col3[0]-r3))
    p.add_constraint(-y[1] <= x[1]*(col1[1]-r1) + x[2]*(col2[1]-r2) + x[3]*(col3[1]-r3))
    p.add_constraint(y[1] >= x[1]*(col1[1]-r1) + x[2]*(col2[1]-r2) + x[3]*(col3[1]-r3))
    p.add_constraint(-y[2] <= x[1]*(col1[2]-r1) + x[2]*(col2[2]-r2) + x[3]*(col3[2]-r3))
    p.add_constraint(y[2] >= x[1]*(col1[2]-r1) + x[2]*(col2[2]-r2) + x[3]*(col3[2]-r3))
    p.add_constraint(-y[3] <= x[1]*(col1[3]-r1) + x[2]*(col2[3]-r2) + x[3]*(col3[3]-r3))
    p.add_constraint(y[3] >= x[1]*(col1[3]-r1) + x[2]*(col2[3]-r2) + x[3]*(col3[3]-r3))
   
    p.add_constraint(y[0]>=0)
    p.add_constraint(y[1]>=0)
    p.add_constraint(y[2]>=0)
    p.add_constraint(y[3]>=0)

    p.set_objective(mu * (x[1]*r1 + x[2]*r2 + x[3]*r3) - (1/len(col1) * (y[1] + y[2] + y[3] + y[4])))
  
    p.solve()

    psol_list = []
    for i in range(len(col1)):
        psol_list.append(p.get_values(x[i]))

    return psol_list
    
    


    
    