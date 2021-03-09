def setup_portfolio_lp(hist_data, mu):
    n = len(hist_data)
    T = len(hist_data[0])
    lp = MixedIntegerLinearProgram(solver=("GLPK", "InteractiveLP"),
                                   maximization=True, base_ring=mu.parent())
    x_var = lp.new_variable(nonnegative=True)
    x = [x_var[j] for j in range(n - 1)]
    x.append(1 - sum(x))
    lp.add_constraint(x[-1] >= 0)
    y = lp.new_variable(nonnegative=True)
    exp_return = [sum(r) / T for r in hist_data]
    for t in range(T):
        dev = sum(x[j] * (hist_data[j][t] - exp_return[j]) for j in range(n))
        lp.add_constraint(dev <= y[t])
        lp.add_constraint(dev >= -y[t])
    reward = sum([x[j] * exp_return[j] for j in range(n)])
    risk = sum([y[t] for t in range(T)]) / T
    obj = mu * reward - risk
    # lp.set_objective(obj)
    # workaround as mip.pyx L1545 records unnecessary ineqs.
    f = obj.dict()
    h = lp.get_backend()
    d = f.pop(-1, h.zero())
    values = [f.get(i, h.zero()) for i in range(h.ncols())] 
    h.set_objective(values, d)
    return lp


