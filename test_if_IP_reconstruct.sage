def reconstruct(LP):

    """
    INPUT:  LP object of MILP type
    OUTPUT: exact rational solution to LP, solved via solve_right if LP is IP, solved via ppl_poly if LP is MIP

    EXAMPLE::

        sage: lp = MixedIntegerLinearProgram(solver = 'GLPK', maximization = False)
        sage: x, y = lp[0], lp[1]
        sage: lp.add_constraint(-2*x + y <= 1)
        sage: lp.add_constraint(x - y <= 1)
        sage: lp.add_constraint(x + y >= 2)
        sage: lp.set_objective(x + y)
        sage: reconstruct(lp)
        sage: (3/2, 1/2)

    """


    # testing the integrality of constraint coefficients in LP

    num_cons_coeffs = 0
    int_counter = 0

    IP = True
   
    for i in range(len(LP.constraints())):
        for ele in LP.constraints()[i][1][1]:
            num_cons_coeffs += 1
            if ele == int(ele): #try type instead
                int_counter += 1

    if num_cons_coeffs == int_counter:
        IP = True

    else:
        IP = False

    #print(IP)

    if IP:
        return exact_optsol(LP)

    else:
        return exact_optsol2(LP)
                