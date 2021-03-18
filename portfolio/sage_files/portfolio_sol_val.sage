#def portfolio_sol_val(K, lp):

    #solution = lp.solve()
    #h = lp.get_backend()
    #for i in range(lp.number_of_var
    #optsol = h.get_variable_value()
    #val = optsol._val
    #return val

def solve_for_optimal_portfolio(K, lp):
    opt_value = lp.solve()
    n_var = lp.number_of_variables() - (lp.number_of_constraints() - 1) / 2
    h = lp.get_backend()
    opt_sol = tuple(h.get_variable_value(i).val() for i in range(n_var))  # workaround of lp.get_values(x_var)
    return opt_sol
