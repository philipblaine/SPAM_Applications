def portfolio(mu,base_ring=None):

    if base_ring is None:
        base_ring = mu.parent()

    p = MixedIntegerLinearProgram(maximization=True, base_ring=K)  
    x = p.new_variable(integer=False, nonnegative=True)
    #x0, x1, x2 are portfolio weights
    #x3-x27 are constraint variables

    col1 = [1,1003/1000,1005/1000,1007/1000,1002/1000,1001/1000,1005/1000,1004/1000,1004/1000,1008/1000,1007/1000,1002/1000,1002/1000,1002/1000,1002/1000,1,1002/1000,1004/1000,1004/1000,999/1000,997/1000,1007/1000,996/1000,1002/1000]
    col2 = [1044/1000,1015/1000,1024/1000,1027/1000,1040/1000,995/1000,1044/1000,1060/1000,1,1030/1000,963/1000,1005/1000,960/1000,1035/1000,1047/1000,978/1000,1048/1000,1029/1000,1076/1000,1002/1000,1008/1000,958/1000,1056/1000,980/1000]
    col3 = [1068/1000,1051/1000,1062/1000,980/1000,991/1000,969/1000,1086/1000,1043/1000,963/1000,949/1000,1034/1000,1022/1000,972/1000,1050/1000,1042/1000,908/1000,1146/1000,1018/1000,1015/1000,909/1000,1063/1000,1064/1000,1071/1000,1070/1000]
    #col4 = [1016/1000,1039/1000,994/1000,971/1000,1009/1000,1030/1000,1007/1000]

    r1sum = 0
    r2sum = 0
    r3sum = 0

    for i in range(len(col1)):
        r1sum += col1[i]

    for j in range(len(col2)):
        r2sum += col2[j]

    for k in range(len(col3)):
        r3sum += col3[k]
        

    r1 = r1sum/24
    #print(r1)
    r2 = r2sum/24
    #print(r2)
    r3 = r2sum/24
    #print(r3)

    p.add_constraint(x[0]>=0)
    p.add_constraint(x[1]>=0)
    p.add_constraint(x[2]>=0)

    p.add_constraint(x[0]+x[1]+x[2] == 1)

   
    for t in range(3,27):
        p.add_constraint(-x[t] <= x[0]*(col1[t-3]-r1) + x[1]*(col2[t-3]-r2) + x[2]*(col3[t-3]-r3))

    for tt in range(3,27):
        p.add_constraint(x[tt] >= x[0]*(col1[tt-3]-r1) + x[1]*(col2[tt-3]-r2) + x[2]*(col3[tt-3]-r3))

    #p.add_constraint(-y[0] <= x[1]*(col1[0]-r1) + x[2]*(col2[0]-r2) + x[3]*(col3[0]-r3))
    #p.add_constraint(y[0] >= x[1]*(col1[0]-r1) + x[2]*(col2[0]-r2) + x[3]*(col3[0]-r3))
    #p.add_constraint(-y[1] <= x[1]*(col1[1]-r1) + x[2]*(col2[1]-r2) + x[3]*(col3[1]-r3))
    #p.add_constraint(y[1] >= x[1]*(col1[1]-r1) + x[2]*(col2[1]-r2) + x[3]*(col3[1]-r3))
    #p.add_constraint(-y[2] <= x[1]*(col1[2]-r1) + x[2]*(col2[2]-r2) + x[3]*(col3[2]-r3))
    #p.add_constraint(y[2] >= x[1]*(col1[2]-r1) + x[2]*(col2[2]-r2) + x[3]*(col3[2]-r3))
    #p.add_constraint(-y[3] <= x[1]*(col1[3]-r1) + x[2]*(col2[3]-r2) + x[3]*(col3[3]-r3))
    #p.add_constraint(y[3] >= x[1]*(col1[3]-r1) + x[2]*(col2[3]-r2) + x[3]*(col3[3]-r3))
   

    for ttt in range(3,27):
        p.add_constraint(x[ttt]>=0)

    p.set_objective(mu * (x[0]*r1 + x[1]*r2 + x[2]*r3) - ((1/24) * sum([x[o] for o in range(3,27)])))
    
    #p.show()
    p.solve()

    psol_list = []
    for i in range(0,3):
        psol_list.append(p.get_values(x[i]))

    psol_tuple = tuple(psol_list)

    return psol_tuple
    
    

					

    
    