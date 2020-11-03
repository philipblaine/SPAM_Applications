def exact_optsol2(b):
    r"""
    Reconstruct exact rational basic solution. (solver = ``glp_simplex``)
    EXAMPLES::
        sage: from cutgeneratingfunctionology.igp import *
        sage: lp = MixedIntegerLinearProgram(solver = 'GLPK', maximization = False)
        sage: x, y = lp[0], lp[1]
        sage: lp.add_constraint(-2*x + y <= 1)
        sage: lp.add_constraint(x - y <= 1)
        sage: lp.add_constraint(x + y >= 2)
        sage: lp.set_objective(x + y)
        sage: lp.solver_parameter("simplex_or_intopt", "simplex_only")
        sage: lp.solve()
        2.0
        sage: lp.get_values(x)
        1.5
        sage: lp.get_values(y)
        0.5
        sage: b = lp.get_backend()
        sage: exact_optsol(b)
        (3/2, 1/2)
    """
    #sage_input(b)
    ncol = b.ncols()
    nrow = b.nrows()
    A = matrix(QQ, ncol + nrow, ncol + nrow, sparse = True)
    for i in range(nrow):
        r = b.row(i)
        for (j, c) in zip(r[0], r[1]):
            A[i, j] = QQ(c)
        A[i, ncol + i] = -1
    n = nrow
    Y = zero_vector(QQ, ncol + nrow)
    for i in range(ncol):
        status =  b.get_col_stat(i)
        if status > 1:
            A[n, i] = 1
            if status == 2:
                Y[n] = b.col_bounds(i)[0]
            else:
                Y[n] = b.col_bounds(i)[1]
            n += 1
    for i in range(nrow):
        status =  b.get_row_stat(i)
        if status > 1:
            A[n, ncol + i] = 1
            if status == 2:
                Y[n] = b.row_bounds(i)[0]
            else:
                Y[n] = b.row_bounds(i)[1]
            n += 1

    #filename = open(dir_math+"profiler/solveAXisY", "w")
    #print >> filename, "A =",
    #print >> filename, sage_input(A)
    #print >> filename
    #print >> filename, "Y =",
    #print >> filename, sage_input(Y)
    #filename.close()

    #X = A \ Y
    #y_list = []
    #eqn_list = [[]]
    #for i in range(len(Y)):
        #eqn_list.append(-Y[i])

    #for ele in A:
        #for j in ele:
    eqnlist = []
    alist = [ele for ele in A]
    
    for i in range(len(Y)):
        
        eqnlist.append([-Y[i]])

    
    for j in range(ncol+nrow):
        for k in range(ncol+nrow):
            eqnlist[j].append(alist[j][k])

    poly = Polyhedron(eqns=eqnlist, backend='normaliz')
    X = poly.vertices_list()

    for s in range(len(X)):
        X[s] = tuple(X[s])
        
    tupleX = tuple(X)

    #X = A.solve_right(Y, check=False)
    return tupleX[0][0:ncol] 

