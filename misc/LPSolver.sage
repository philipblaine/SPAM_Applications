def primal_solver(m,n,A,base_ring=None):
    r"""
    Solves the primal LP for the optimal probabilities p for strategies of a user-inputted two-player game.

    Returns the optimal maxmin strategy for one player as a list of probabilities with which he/she should take the corresponding actions.

   
    EXAMPLES::

        sage: m = 2; n = 2; A = [[-2, 3],[3,-4]]
        sage: primal_solver(m,n,A)
        [7/12, 5/12]

        sage: m = 2; n = 2; A = [[3, 1],[1, 6]]
        sage: primal_solver(m,n,A)
        [5/7, 2/7]

        sage: m = 2; n = 2; A = [[-1, -2],[-1, -3]]
        sage: primal_solver(m,n,A)
        MIPSolverException: PPL : There is no feasible solution


    """

    if base_ring is None:
        base_ring = A[0][0].parent()
        
    primal = MixedIntegerLinearProgram(maximization=True, base_ring=base_ring)
    
    p = primal.new_variable(integer=False, nonnegative=True)

    unity_cons = sum([p[i] for i in range(m)])
    primal.add_constraint(unity_cons == 1)

    for k in range(m):
        primal.add_constraint(p[k]>=0)

    primal_list = []

    for f in range(n):
        primal_payoff = sum([p[e]*A[e][f] for e in range(m)])
        primal_list.append(primal_payoff)

    for ele in primal_list:
        primal.add_constraint(p[m] <= ele)

    primal.set_objective(p[m])

    primal.solve()

    psol_list = []
    for o in range(m):
        psol_list.append(primal.get_values(p[o]))

    return psol_list, primal



def dual_solver(m,n,A,base_ring=None):
    r"""
    Solves the primal LP for the optimal probabilities p for strategies of a user-inputted two-player game.

    EXAMPLES::

        sage: m = 2; n = 2; A = [[-2, 3],[3,-4]]
        sage: dual_solver(m,n,A)
        {0: 7/12, 1: 5/12, 2: 1/12}

        sage: m = 2; n = 2; A = [[3,1],1,6]]
        sage: dual_solver(m,n,A)
        {0: 5/7, 1: 2/7, 2: 17/7}

        sage: m = 2; n = 3; A = [[1,2,3],[3,2,1]]
        sage: dual_solver(m,n,A)
        {0: 1/2, 1: 0, 2: 1/2, 3: 2
        

    """

    if base_ring is None:
        base_ring = A[0][0].parent()

    dual = MixedIntegerLinearProgram(maximization=False, base_ring=base_ring)
    
    q = dual.new_variable(integer=False, nonnegative=True)

    dual_unity = sum([q[z] for z in range(n)])
    dual.add_constraint(dual_unity == 1)

    for v in range(n):
        dual.add_constraint(q[v]>=0)

    dual_list = []

    for g in range(m):
        dual_payoff = sum([q[h]*A[g][h] for h in range(n)])
        dual_list.append(dual_payoff)

    for elem in dual_list:
        dual.add_constraint(q[n] >= elem)

    dual.set_objective(q[n])

    dual.solve()

    qsol_list = []
    for u in range(n):
        qsol_list.append(dual.get_values(q[u]))

    return qsol_list




