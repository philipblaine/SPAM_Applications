def exact_optsol_poly(LP):
    r"""

    INPUT:  MILP object with solver="GLPK"
    OUTPUT: exact rational solution (found using ppl_poly) to LP
    
    EXAMPLES::
        sage: from cutgeneratingfunctionology.igp import *
        sage: lp = MixedIntegerLinearProgram(solver = 'GLPK', maximization = False)
        sage: x = lp.new_variable()
        sage: lp.add_constraint(-2*x[0] + x[1] <= 1)
        sage: lp.add_constraint(x[0] - x[1] <= 1)
        sage: lp.add_constraint(x[0] + x[1] >= 2)
        sage: lp.set_objective(x[0]+x[1])
        sage: exact_optsol2(lp)
        sage: (3/2, 1/2)

        
        sage: p = MixedIntegerLinearProgram(maximization=True, solver="GLPK")
        sage: x = p.new_variable(nonnegative=True)
        sage: p.add_constraint(-x[0] + x[1] <= 2)
        sage: p.add_constraint(1.5 * x[0] + 2.5 * x[1] <= 17)
        sage: p.set_objective(5.5 * x[0] - 3 * x[1])
        sage: exact_optsol2(p)
        sage: (17/8, 0)
    
    """

    LP.solver_parameter("simplex_or_intopt", "simplex_only")
    LP.solve()

    b = LP.get_backend()

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

    polysol = ppl_poly_solve(A,Y)

    return polysol[0:ncol]

    

