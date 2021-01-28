def portfolio(mu,base_ring=None):

    #if base_ring is None:
        #base_ring = mu.parent()

    p = MixedIntegerLinearProgram(solver="InteractiveLP",maximization=True, base_ring=K)  
    x = p.new_variable(integer=False, nonnegative=True)
    w = p.new_variable(integer=False, nonnegative=True)
    #x0, x1, x2 are portfolio weights
    #x3-x26 are constraint variables
    #x27-75 are slack variables

    col1 = [1,1003/1000,1005/1000,1007/1000,1002/1000,1001/1000,1005/1000,1004/1000,1004/1000,1008/1000,1007/1000,1002/1000,1002/1000,1002/1000,1002/1000,1,1002/1000,1004/1000,1004/1000,999/1000,997/1000,1007/1000,996/1000,1002/1000]; col2 = [1044/1000,1015/1000,1024/1000,1027/1000,1040/1000,995/1000,1044/1000,1060/1000,1,1030/1000,963/1000,1005/1000,960/1000,1035/1000,1047/1000,978/1000,1048/1000,1029/1000,1076/1000,1002/1000,1008/1000,958/1000,1056/1000,980/1000]; col3 = [1068/1000,1051/1000,1062/1000,980/1000,991/1000,969/1000,1086/1000,1043/1000,963/1000,949/1000,1034/1000,1022/1000,972/1000,1050/1000,1042/1000,908/1000,1146/1000,1018/1000,1015/1000,909/1000,1063/1000,1064/1000,1071/1000,1070/1000]


    r1sum = 0; r2sum = 0; r3sum = 0

    for i in range(len(col1)):
        r1sum += col1[i]

    for j in range(len(col2)):
        r2sum += col2[j]

    for k in range(len(col3)):
        r3sum += col3[k]
        

    r1 = r1sum/24; r2 = r2sum/24; r3 = r3sum/24

    p.add_constraint(x[0]+x[1]+x[2] <= 1); p.add_constraint(x[0]+x[1]+x[2] >= 1)

   
    for t in range(3,27,1):
        p.add_constraint((-x[t] - (x[0]*(col1[t-3]-r1) + x[1]*(col2[t-3]-r2) + x[2]*(col3[t-3]-r3)) + x[t+24]) <= 0)

    for t in range(3,27,1):
        p.add_constraint((-x[t] - (x[0]*(col1[t-3]-r1) + x[1]*(col2[t-3]-r2) + x[2]*(col3[t-3]-r3)) + x[t+24]) >= 0)
        
    for t in range(3,27,1):
        p.add_constraint((-x[t] + (x[0]*(col1[t-3]-r1) + x[1]*(col2[t-3]-r2) + x[2]*(col3[t-3]-r3)) + x[t+48]) <= 0)

    for t in range(3,27,1):
        p.add_constraint((-x[t] + (x[0]*(col1[t-3]-r1) + x[1]*(col2[t-3]-r2) + x[2]*(col3[t-3]-r3)) + x[t+48]) >= 0)

    #for tt in range(3,27,1):
        #p.add_constraint(x[tt] >= x[0]*(col1[tt-3]-r1) + x[1]*(col2[tt-3]-r2) + x[2]*(col3[tt-3]-r3))
   

    for ttt in range(75):
        p.add_constraint(x[ttt]>=0)

    c = [0] * 75
    c[0] = mu*x[0]*r1
    c[1] = mu*x[1]*r2
    c[2] = mu*x[2]*r3
    for j in range(3,27):
        c[j] = (1/24)*x[j]
  
    p.set_objective(mu*(x[0]*r1 + x[1]*r2 + x[2]*r3) - ((1/24) * sum([x[o] for o in range(3,27,1)])))
    #p.set_objective(mu*(x[0]*r1 + x[1]*r2 + x[2]*r3) - ((1/24) * sum([x[o] for o in range(3,27,1)])) + sum([0*x[j] for j in range(28,75)]))
    
    #p.set_objective(c)

    #p.show()
    p.solve()
    #psol = exact_optsol_intLP(p)
    #psol = exact_optsol_poly(p)

    psol_list = []
    for i in range(0,3):
        psol_list.append(p.get_values(x[i]))

    psol_tuple = tuple(psol_list)

    return psol_tuple
    #return psol
    
    

					

    
    