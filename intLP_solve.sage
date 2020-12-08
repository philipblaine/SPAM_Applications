import sys
import cProfile
import numpy as np
sys.path.append("/mnt/c/users/phili/cutgeneratingfunctionology")
import cutgeneratingfunctionology.igp as igp; from cutgeneratingfunctionology.igp import *
from sage.numerical.interactive_simplex_method import *
#%display latex

### attempting to extract basic variables from GLPK-solved LP 
### then use those basic variables to perform one iteration of the simplex method
### on exact InteractiveLP-solved LP to get exact solutions




def main():

    # inexact LP setup
    p2 = MixedIntegerLinearProgram(maximization=True, solver="GLPK")
    w = p2.new_variable(nonnegative=True)
    p2.add_constraint(0.5*w[1]+1.5*w[2] <= 100)
    p2.add_constraint(3*w[1]+w[2] <= 150)
    p2.set_objective(10*w[1]+5*w[2])

    p2.solver_parameter("simplex_or_intopt", "simplex_only")
    sol = p2.solve()
    #print(sol)
    #print(p2.get_values(w))

    b = p2.get_backend()
    #b.solver_parameter("simplex_or_intopt", "simplex_only")
    b.solve()
    #print(b.is_variable_basic(3))

    basic_vars = []
    #print(p2.number_of_variables())

    for i in range(p2.number_of_variables()):
        if b.get_col_stat(i) == 1:
            basic_vars.append(i)
        
    #print(basic_vars)

    # exact LP setup
    A = ([1/2, 3/2], [3, 1])
    b = (100, 150)
    c = (10, 5)
    P = InteractiveLPProblemStandardForm(A, b, c)
    #P.run_revised_simplex_method()

    D = P.revised_dictionary(basic_vars[0],basic_vars[1])

    return D.is_optimal()

