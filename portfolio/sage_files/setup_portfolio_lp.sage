def setup_portfolio_lp(hist_data, mu, solver=None):
    n = len(hist_data)
    T = len(hist_data[0])
    if mu == +Infinity or mu == -Infinity or not hasattr(mu, 'parent'):
        base_ring = None
    else:
        base_ring = mu.parent()
    lp = MixedIntegerLinearProgram(solver=solver, maximization=True, base_ring=base_ring)
    x = lp.new_variable(nonnegative=True)
    lp.add_constraint(sum(x[i] for i in range(n)) == 1)
    y = lp.new_variable(nonnegative=True)
    exp_return = [sum(r) / T for r in hist_data]
    for t in range(T):
        dev = sum(x[j] * (hist_data[j][t] - exp_return[j]) for j in range(n))
        lp.add_constraint(dev <= y[t])
        lp.add_constraint(dev >= -y[t])
    reward = sum([x[j] * exp_return[j] for j in range(n)])
    risk = sum([y[t] for t in range(T)]) / T
    if mu == +Infinity:
        obj = reward
    elif mu == -Infinity:
        obj = - reward
    else:
        obj = mu * reward - risk
    lp.set_objective(obj)
    return lp

