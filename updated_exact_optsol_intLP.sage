from sage.numerical.interactive_simplex_method import *
from sage.numerical.backends.generic_backend import get_solver

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

    LP.solver_parameter("simplex_or_intopt", "simplex_only")
    LP.solve()

    b = LP.get_backend()

    basic_vars = [(i+1) for i in range(b.ncols()) if b.is_variable_basic(i)]+[(b.nrows()+j+1) for j in range(b.nrows()) if b.is_slack_variable_basic(j)]

    num_cons = LP.number_of_constraints()

    A = matrix(QQ,num_cons)
    Y = matrix(QQ,num_cons,1)


    

    #same problem here with index = 99, not 99 elements to index through. 
    #list index out of range

    
    j = 0

    for l in LP.constraints():
        for (i, r) in zip(l[1][0], l[1][1]):
            A[j, i]=QQ(r)
        j += 1

    """

    

    j = 0

    for l in LP.constraints():
        #print(l)
        for i in l[1][0]:
            print(i)
            A[j,i]= Rational(l[1][1][-(i+1)])
            #print(A[j,i])
        j += 1

    

    for (l,j) in zip(LP.constraints(), range(LP.number_of_variables())):
        for i in l[1][0]:
            A[j,i]= Rational(l[1][1][-(i+1)])

    
    
    for j in range(LP.number_of_variables()):
        lst1 = LP.constraints()[j][1][1]
        for i in range(LP.number_of_variables()):
            if i in LP.constraints()[j][1][0]:
            
                A[j,i] = Rational(lst1[-(i+1)])
            
            else:
                lst1.insert(-i,0)
            
    """
    for i in range(LP.number_of_variables()):
        if Rational(LP.constraints()[i][2])!= 0:
            Y[i] = Rational(LP.constraints()[i][2])
    
    
    c = []

    for j in range(LP.number_of_variables()):
        if b.objective_coefficient(j) != []:
            c.append(Rational(b.objective_coefficient(j)))

    #print(A)
    #print(c)

    P = InteractiveLPProblemStandardForm(A, Y, c)

    D = P.dictionary(*basic_vars)

    return tuple(D.basic_solution())