
### add input/output doctest
### use solve from InteractiveLP, don't replicate solve method
### take a single LP (possibly backend) as input, output optsol
### write generic function calls (e.g. remove RevisedLPDictionary) to accommodate future backend solvers 


def exact_optsol3(LP):

    """
    INPUT:  MILP object with at least one designated exact rational solver
    OUTPUT: exact rational solution to LP (found using LP's backend basis functions)

    EXAMPLE::


    #NOTE: simply testing the get_solver2 solver functionality for compatibility with tuple
    sage: p,q = get_solver2(solver=("glpk","interactivelp"))
    sage: p.add_variables(2)
    1
    sage: q.add_variables(2)
    1
    sage: p.add_linear_constraint([(0,1), (1,2)], None, 3)
    sage: q.add_linear_constraint([(0,1), (1,2)], None, 3)
    sage: p.set_objective([2,5])
    sage: q.set_objective([2,5])
    sage: p.solve()
    0
    sage: q.solve()
    0

    #FIXME: need support for MILP with tuple solvers, this doctest is incomplete
    sage: p = MixedIntegerLinearProgram(maximization=True, solver=("GLPK","InteractiveLP"))
    sage: w = p.new_variable(nonnegative=True)
    sage: p.add_constraint(1/2*w[0]+3/2*w[1] <= 100)
    sage: p.add_constraint(3*w[0]+w[1] <= 150)
    sage: p.set_objective(10*w[0]+5*w[1])
    sage: exact_optsol3(p)
    sage: 


    """

    #self.backends[0].solver_parameter("simplex_or_intopt", "simplex_only")
    #self.backends[0].solve()
    LP.solver_parameter("simplex_or_intopt","simplex_only")
    LP.solve()

    b = LP.get_backend()

    basic_vars = []

    #add basic variables to list
    for i in range(LP.number_of_variables()):
        if b.get_col_stat(i) == 1:
            basic_vars.append(i)
        
    for i in range(len(basic_vars)):
        basic_vars[i] += 1

    
    A = []
    Y = []

    
    
    

    for i in range(len(LP.constraints())):

        A_list = []

        for j in range(len(LP.constraints()[i][1][1])):
            LP.constraints()[i][1][1][j] = Rational(LP.constraints()[i][1][1][j])
            A_list.append(Rational(LP.constraints()[i][1][1][j]))
        
        A.append(list(A_list))
        
        Y.append(Rational(LP.constraints()[i][2]))

    A = Matrix(A)
    Y = Matrix(Y)

    c = (10, 5)

    P = InteractiveLPProblemStandardForm(A, Y, c)

    D = LPRevisedDictionary(P,basic_vars)

    return D.basic_solution()
    


