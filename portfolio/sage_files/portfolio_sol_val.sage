def portfolio_sol_val(lp):

    h = lp.get_backend()
    optsol = h.get_variable_value()
    val = optsol._val
    return val