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
    #b.solve()
    
    #print(b.ncols())
    #print(b.nrows())

    basic_vars = []

    for i in range(LP.number_of_variables()):
        if b.get_col_stat(i) == 1:
            basic_vars.append(i)
       
    for i in range(len(basic_vars)):
        basic_vars[i] += 1

    #basic_vars = [(i+1) for i in range(b.ncols()) if b.is_variable_basic(i)]+[(b.nrows()+j+1) for j in range(b.nrows()) if b.is_slack_variable_basic(j)]
    

    #basic_vars = [(i+1) for i in range(b.ncols()) if b.is_variable_basic(i)]
    #print(basic_vars)
    num_cons = LP.number_of_constraints()

    num_vars = LP.number_of_variables()
    #print(num_cons)

    #print("hi")
    A = matrix(QQ,num_cons, num_vars)
    Y = matrix(QQ,num_cons,1)

    #print("hello")
    

    #same problem here with index = 99, not 99 elements to index through. 
    #list index out of range

    
    j = 0

    for l in LP.constraints():
        for (i, r) in zip(l[1][0], l[1][1]):
            A[j, i]=QQ(r)
        j += 1
    #print("test")
    
    """

    

    j = 0

    for l in LP.constraints():
        #print(l)
        for i in l[1][0]:
            print(i)
            A[j,i]= Rational(l[1][1][-(i+1)])
            #print(A[j,i])
        j += 1

    

    for (l,j) in zip(LP.constraints(), range(num_vars)):
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
    #print("after Y")
    
    c = []

    for j in range(LP.number_of_variables()):
        if b.objective_coefficient(j) != []:
            c.append(QQ(b.objective_coefficient(j)))
    #print("after c")

    #print(A)
    #print(c)

    P = InteractiveLPProblemStandardForm(A, Y, c)
    #print("after P")

    j = P.run_revised_simplex_method()

    final_dictionary = P.final_revised_dictionary()

    #D = P.dictionary(*basic_vars)
    #print("after d")

    #is feasible, is optimal needed
    #return tuple(D.basic_solution())

    solution = final_dictionary.basic_solution()
    #return j, P

    return solution