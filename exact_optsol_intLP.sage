def exact_optsol_intLP(LP):

    """
    INPUT:  MILP object with an inexact solver
    OUTPUT: exact rational solution to LP (found using LP's backend basis functions)

    EXAMPLE::

    #works for this doctest, fails others
    sage: p = MixedIntegerLinearProgram(maximization=True, solver="GLPK")
    sage: w = p.new_variable(nonnegative=True)
    sage: A = Matrix([[1/2,3/2],[3,1]])
    sage: Y = vector(Matrix([[100,150]]))
    sage: c = vector(Matrix([[10,5]]))
    sage: p.add_constraint(A*w <= Y)
    sage: p.set_objective(c)
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
    
    
    """
    A = []
    Y = []
    
    for i in range(len(LP.constraints())):
        
        A_list = []

        for j in range(len(LP.constraints()[i][1][1])):
            
            A_list.append(Rational(LP.constraints()[i][1][1][j]))
            
        
        if A_list != []:
            A.append(A_list)
        
        
        #if Rational(LP.constraints()[i][2])!= 0:
        Y.append(Rational(LP.constraints()[i][2]))
    

    #A = Matrix(A)
    #Y = Matrix(Y)
    
    c = []

    for j in range(LP.number_of_variables()):
        #if b.objective_coefficient(j) != []:
        c.append(Rational(b.objective_coefficient(j)))
            #print(c)
    
    #print(A)
    #print(Y)
    """
    P = InteractiveLPProblemStandardForm(A, Y, c)

    #depending on test:
    #Arithmetic Error: self must be a square matrix
    #ValueError: inconsistent number of columns: should be 99 but got 97

    D = LPRevisedDictionary(P,basic_vars)
    
    
    return D.basic_solution()
    


