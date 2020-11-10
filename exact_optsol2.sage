def exact_optsol2(b):
    r"""
    Want to use InteractiveLP and GLPK solvers.
    QUESTION:
    Reconstruct exact rational basic solution. (solver = ("GLPK", "InteractiveLP"))
    EXAMPLES::
        sage: from cutgeneratingfunctionology.igp import *
        sage: lp = MixedIntegerLinearProgram(solver = ('GLPK', 'InteractiveLP'), maximization = False)
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

    """
    Integrating InteractiveLP steps to extract basic variables from GLPK-solved LP.

        EXAMPLES::
        sage: p = MixedIntegerLinearProgram(maximization=True, solver="GLPK")
        sage: x = p.new_variable(nonnegative=True)
        sage: p.add_constraint(-x[0] + x[1] <= 2)
        sage: p.add_constraint(8 * x[0] + 2 * x[1] <= 17)
        sage: p.set_objective(5.5 * x[0] - 3 * x[1])
        sage: b = p.get_backend()
        sage: b.solver_parameter("simplex_or_intopt", "simplex_only")
        sage: b.solve()
        0
        sage: exact_optsol2(b)
        #OUTPUT
    
    """

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

    """
    Y = zero_vector(QQ, ncol + nrow)
    
    n = nrow
    for i in range(ncol):
        flag = b.is_variable_basic()
        if flag == False:
            A[n, i] = 1
            

    """
    for i in range(nrow):
        status =  b.get_row_stat(i)
        if status > 1:
            A[n, ncol + i] = 1
            if status == 2:
                Y[n] = b.row_bounds(i)[0]
            else:
                Y[n] = b.row_bounds(i)[1]
            n += 1

    eqnlist = []
    alist = [ele for ele in A]
    
    for i in range(len(Y)):
        eqnlist.append([-Y[i]])

    for j in range(ncol+nrow):
        for k in range(ncol+nrow):
            eqnlist[j].append(alist[j][k])
    #normaliz backend MUCH slower than default backend
    poly = Polyhedron(eqns=eqnlist, backend="normaliz")
    #polyv = poly.Vrepresentation()
    X = poly.vertices_list()
    lenx = len(X)
    for s in range(lenx):
        X[s] = tuple(X[s])
        
    tupleX = tuple(X)

    for l in range(lenx):
        return tupleX[l][0:ncol]
    #return polyv

