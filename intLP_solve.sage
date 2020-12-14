### attempting to extract basic variables from GLPK-solved LP 
### then use those basic variables to perform one iteration of the simplex method
### on exact InteractiveLP-solved LP to get exact solutions


###TO DO:
### add input/output doctest
### use solve from InteractiveLP, don't replicate solve method
### take a single LP (possibly backend) as input, output optsol
### write generic function calls (e.g. remove RevisedLPDictionary) to accommodate future backend solvers 

import sys
import cProfile
import numpy as np
sys.path.append("/mnt/c/users/phili/cutgeneratingfunctionology")
import cutgeneratingfunctionology.igp as igp; from cutgeneratingfunctionology.igp import *
from sage.numerical.interactive_simplex_method import *
load_attach_path("/mnt/c/users/phili/SPAM_Applications")
load("startup.sage")
#%display latex


def exact_optsol3(self):

    """
    INPUT:  MILP object with at least one designated exact rational solver
    OUTPUT: exact rational solution to LP

    EXAMPLE::
	
    sage: p = MixedIntegerLinearProgram(maximization=True, solver=("GLPK","InteractiveLP"))
    sage: w = p.new_variable(nonnegative=True)
    sage: p.add_constraint(0.5*w[0]+1.5*w[1] <= 100)
    sage: p.add_constraint(3*w[0]+w[1] <= 150)
    sage: p.set_objective(10*w[0]+5*w[1])
    sage: b.exact_optsol3()
    sage: 


            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = ("GLPK", "InteractiveLP"))
            sage: p.add_variables(2)
            1
            sage: p.add_linear_constraint([(0,1), (1,2)], None, 3)
            sage: p.set_objective([2, 5])
            sage: p.solve()
            0
            sage: p.get_objective_value()
            15/2
            sage: p.get_variable_value(0)
            0
            sage: p.get_variable_value(1)
            3/2

    """

    b = p.get_backend()
    b.solver_parameter("simplex_or_intopt", "simplex_only")
    b.solve()

    

 
    #p.solver_parameter("simplex_or_intopt", "simplex_only")
    #inexact_optsol = p.solve()

    #basic_vars = []
    #for i in range(self.backends[-1].ncols()):
        #if self.backends[-1].is_variable_basic(i):
            #basic_vars.append(i)

    dict = self.backends[-1].dictionary()

    basic_vars = dict.basic_variables()

    basic_sol = dict.basic_solution()

    return basic_sol
    

    

    
    

    
"""

#find exact_optsol2 to compare with exact_optsol3
bsol = exact_optsol2(b2)

#create list of basic indices

basic_vars = []

#add basic variables to list
for i in range(p2.number_of_variables()):
    if b2.get_col_stat(i) == 1:
        basic_vars.append(i)
        
for i in range(len(basic_vars)):
    basic_vars[i] += 1
        
#print(basic_vars)

# exact LP setup
#A = ([1/2, 3/2], [3, 1])
#b = (100, 150)
#c = (10, 5)
#P = InteractiveLPProblemStandardForm(A, b, c)
#P.run_revised_simplex_method()

# create revised dictionary with basic variables found from inexact LP
D = LPRevisedDictionary(P,basic_vars)

F = P.final_revised_dictionary()

D.is_optimal()

#final pivot computations, return exact_optsol3
Binv = D.B_inverse()

b = Matrix(b)
b = b.transpose()

Binvb = Binv * b

exact_optsol3 = tuple(Binvb.transpose())
exact_optsol3
exact_optsol3_value = 0

exact_optsol3 = exact_optsol3[0]
exact_optsol3
for i in range(len(exact_optsol3)):
    exact_optsol3_value += c[i]*Binvb[i]
    

print(exact_optsol3)
print(bsol)
print(exact_optsol3_value)
"""