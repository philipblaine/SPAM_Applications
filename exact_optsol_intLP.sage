

def exact_optsol_intLP(LP):

    """
    INPUT:  MILP object with at least one designated exact rational solver
    OUTPUT: exact rational solution to LP (found using LP's backend basis functions)

    EXAMPLE::


    sage: p = MixedIntegerLinearProgram(maximization=True, solver="GLPK")
    sage: w = p.new_variable(nonnegative=True)
    sage: p.add_constraint(1/2*w[0]+3/2*w[1] <= 100)
    sage: p.add_constraint(3*w[0]+w[1] <= 150)
    sage: p.set_objective(10*w[0]+5*w[1])
    sage: exact_optsol_intLP(p)
    (225/4, 125/4)


    """

    LP.solver_parameter("simplex_or_intopt","simplex_only")
    LP.solve()

    b = LP.get_backend()

    basic_vars = []

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
            
            A_list.append(Rational(LP.constraints()[i][1][1][j]))
            
        
        if A_list != []:
            A.append(A_list)
        
        
        if Rational(LP.constraints()[i][2])!= 0:
            Y.append(Rational(LP.constraints()[i][2]))
    
    A = Matrix(A)
    
    Y = Matrix(Y)

    c = []

    for j in range(LP.number_of_variables()):
        c.append(Rational(b.objective_coefficient(j)))

    

    P = InteractiveLPProblemStandardForm(A, Y, c)

    #Arithmetic Error: self must be a square matrix
    D = LPRevisedDictionary(P,basic_vars)
    

    return D.basic_solution()
    


