def portfolio2(mu,base_ring=None):

    p2 = MixedIntegerLinearProgram(solver="GLPK",maximization=True, base_ring=K)  

    #if base_ring is None:
        #base_ring = mu.parent()

    x = p2.new_variable(integer=False, nonnegative=True)
    #x0, x1, x2, x3, x4, x5, x6, x7, x8 are portfolio weights
    #x9-x32 are constraint variables

    col1 = [1,1003/1000,1005/1000,1007/1000,1002/1000,1001/1000,1005/1000,1004/1000,1004/1000,1008/1000,1007/1000,1002/1000,1002/1000,1002/1000,1002/1000,1,1002/1000,1004/1000,1004/1000,999/1000,997/1000,1007/1000,996/1000,1002/1000]; col2 = [1044/1000,1015/1000,1024/1000,1027/1000,1040/1000,995/1000,1044/1000,1060/1000,1,1030/1000,963/1000,1005/1000,960/1000,1035/1000,1047/1000,978/1000,1048/1000,1029/1000,1076/1000,1002/1000,1008/1000,958/1000,1056/1000,980/1000]; col3 = [1068/1000,1051/1000,1062/1000,980/1000,991/1000,969/1000,1086/1000,1043/1000,963/1000,949/1000,1034/1000,1022/1000,972/1000,1050/1000,1042/1000,908/1000,1146/1000,1018/1000,1015/1000,909/1000,1063/1000,1064/1000,1071/1000,1070/1000]; col4 = [1016/1000,1039/1000,994/1000,971/1000,1009/1000,1030/1000,1007/1000,1023/1000,1040/1000,1012/1000,1023/1000,995/1000,962/1000,1043/1000,1003/1000,1021/1000,1009/1000,1,1048/1000,1030/1000,1009/1000,983/1000,1016/1000,1012/1000]; col5 = [1035/1000,1046/1000,1008/1000,989/1000,1021/1000,997/1000,1024/1000,1028/1000,1038/1000,1011/1000,943/1000,999/1000,983/1000,1021/1000,1044/1000,1031/1000,1003/1000,1005/1000,1058/1000,986/1000,1017/1000,976/1000,1038/1000,974/1000]; col6 = [1032/1000,1047/1000,1010/1000,973/1000,1020/1000,989/1000,1028/1000,1040/1000,1040/1000,1070/1000,974/1000,995/1000,935/1000,987/1000,1023/1000,1002/1000,1034/1000,969/1000,1063/1000,977/1000,1002/1000,991/1000,1057/1000,987/1000]; col7 = [1004/1000,1028/1000,1021/1000,985/1000,1020/1000,1020/1000,991/1000,1018/1000,999/1000,1039/1000,1016/1000,1018/1000,1002/1000,1010/1000,1008/1000,1008/1000,1002/1000,1001/1000,1009/1000,996/1000,1014/1000,983/1000,1032/1000,981/1000]; col8 = [987/1000,1049/1000,1036/1000,1053/1000,996/1000,999/1000,1026/1000,1053/1000,985/1000,1028/1000,1048/1000,1023/1000,1016/1000,1016/1000,954/1000,1013/1000,1024/1000,1009/1000,999/1000,936/1000,1042/1000,1006/1000,1023/1000,1059/1000]; col9 = [1014/1000,1073/1000,1002/1000,977/1000,1030/1000,1007/1000,999/1000,1003/1000,1015/1000,1029/1000,1055/1000,1,979/1000,969/1000,987/1000,1012/1000,1013/1000,1035/1000,1012/1000,969/1000,995/1000,996/1000,1023/1000,994/1000]

    r1sum = 0; r2sum = 0; r3sum = 0; r4sum = 0; r5sum = 0; r6sum = 0; r7sum = 0; r8sum = 0; r9sum = 0

    for i in range(len(col1)):
        r1sum += col1[i]

    for j in range(len(col2)):
        r2sum += col2[j]

    for k in range(len(col3)):
        r3sum += col3[k]

    for ii in range(len(col4)):
        r4sum += col4[ii]

    for iii in range(len(col5)):
        r5sum += col5[iii]

    for jj in range(len(col6)):
        r6sum += col6[jj]

    for jjj in range(len(col7)):
        r7sum += col7[jjj]

    for kk in range(len(col8)):
        r8sum += col8[kk]

    for iiii in range(len(col9)):
        r9sum += col9[iiii]
        

    r1 = r1sum/24; r2 = r2sum/24; r3 = r3sum/24; r4 = r4sum/24; r5 = r5sum/24; r6 = r6sum/24; r7 = r7sum/24; r8 = r8sum/24; r9 = r9sum/24

    p2.add_constraint(x[0]+x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]+x[8] == 1)

    #print("hi")
    for t in range(9,33):
        p2.add_constraint(-x[t] <= x[0]*(col1[t-9]-r1) + x[1]*(col2[t-9]-r2) + x[2]*(col3[t-9]-r3) + x[3]*(col4[t-9]-r4)+ x[4]*(col5[t-9]-r5)+ x[5]*(col6[t-9]-r6)+ x[6]*(col7[t-9]-r7)+ x[7]*(col8[t-9]-r8)+ x[8]*(col9[t-9]-r9))

    for tt in range(9,33):
        p2.add_constraint(x[tt] >= x[0]*(col1[tt-9]-r1) + x[1]*(col2[tt-9]-r2) + x[2]*(col3[tt-9]-r3) + x[3]*(col4[tt-9]-r4)+ x[4]*(col5[tt-9]-r5)+ x[5]*(col6[tt-9]-r6)+ x[6]*(col7[tt-9]-r7)+ x[7]*(col8[tt-9]-r8)+ x[8]*(col9[tt-9]-r9))

    """
    for t in range(9,33):
        p2.add_constraint((-x[t] - (x[0]*(col1[t-9]-r1) + x[1]*(col2[t-9]-r2) + x[2]*(col3[t-9]-r3) + x[3]*(col4[t-9]-r4)+ x[4]*(col5[t-9]-r5)+ x[5]*(col6[t-9]-r6)+ x[6]*(col7[t-9]-r7)+ x[7]*(col8[t-9]-r8)+ x[8]*(col9[t-9]-r9) + x[t+24])) <= 0)

    for t in range(9,33):
        p2.add_constraint((-x[t] - (x[0]*(col1[t-9]-r1) + x[1]*(col2[t-9]-r2) + x[2]*(col3[t-9]-r3) + x[3]*(col4[t-9]-r4)+ x[4]*(col5[t-9]-r5)+ x[5]*(col6[t-9]-r6)+ x[6]*(col7[t-9]-r7)+ x[7]*(col8[t-9]-r8)+ x[8]*(col9[t-9]-r9) + x[t+24])) >= 0)
        
    for t in range(9,33):
        p2.add_constraint((-x[t] + (x[0]*(col1[t-9]-r1) + x[1]*(col2[t-9]-r2) + x[2]*(col3[t-9]-r3) + x[3]*(col4[t-9]-r4)+ x[4]*(col5[t-9]-r5)+ x[5]*(col6[t-9]-r6)+ x[6]*(col7[t-9]-r7)+ x[7]*(col8[t-9]-r8)+ x[8]*(col9[t-9]-r9) + x[t+48])) <= 0)

    for t in range(9,33):
        p2.add_constraint((-x[t] + (x[0]*(col1[t-9]-r1) + x[1]*(col2[t-9]-r2) + x[2]*(col3[t-9]-r3) + x[3]*(col4[t-9]-r4)+ x[4]*(col5[t-9]-r5)+ x[5]*(col6[t-9]-r6)+ x[6]*(col7[t-9]-r7)+ x[7]*(col8[t-9]-r8)+ x[8]*(col9[t-9]-r9) + x[t+48])) >= 0)
    """

    for ttt in range(81):
        p2.add_constraint(x[ttt]>=0)

    p2.set_objective(mu*(x[0]*r1 + x[1]*r2 + x[2]*r3 + x[3]*r4 + x[4]*r5 + x[5]*r6 + x[6]*r7 + x[7]*r8 + x[8]*r9) - ((1/24) * sum([x[o] for o in range(9,33)])))
    
    #p2.show()
    p2.solve()
    #p2sol = exact_optsol_intLP(p2)

    p2sol_list = []
    for i in range(0,9):
        p2sol_list.append(p2.get_values(x[i]))

    p2sol_tuple = tuple(p2sol_list)

    return p2sol_tuple

    #return p2sol
    
    

		