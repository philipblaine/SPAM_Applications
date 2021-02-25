from sage.numerical.interactive_simplex_method import *
from sage.numerical.backends.generic_backend import get_solver

def exact_optsol_intLP(LP):

    """

    INPUT:  MILP object with an inexact solver
    OUTPUT: exact rational solution to LP (found using LP's backend basis functions)

    EXAMPLE::

    
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

    b = LP.get_backend()                                #wrong, uses inexact GLPK backend
    

    num_cons = LP.number_of_constraints()

    num_vars = LP.number_of_variables()

    A = matrix(QQ,num_cons, num_vars) 
    Y = matrix(QQ,num_cons,1)

    #print(A)
    #print(Y)
    
    j = 0

    for l in LP.constraints():
        for (i, r) in zip(l[1][0], l[1][1]):
            A[j, i]=QQ(r)
        j += 1

    #print(A)

    for i in range(LP.number_of_variables()):
        if Rational(LP.constraints()[i][2])!= 0:
            Y[i] = QQ(LP.constraints()[i][2])

    #print(Y)
    
    c = []


    for j in range(LP.number_of_variables()):
        if b.objective_coefficient(j) != []:             #uses b (inexact backend)
            c.append(QQ(b.objective_coefficient(j)))     #uses b again

    #print(c)

    P = InteractiveLPProblemStandardForm(A, Y, c)

    final_dictionary = P.final_revised_dictionary()

    solution = final_dictionary.basic_solution()

    return solution