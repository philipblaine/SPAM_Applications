def setup_portfolio_lp(hist_data, mu, base_ring=None):

    if base_ring is None:
        base_ring = mu.parent()
    
    n = len(hist_data)
    print("n ", n)
    T = len(hist_data[0])
    print("T ", T)
    
    lp = MixedIntegerLinearProgram(solver=("GLPK","InteractiveLP"),maximization=True,base_ring=mu.parent())
    
    x_var = lp.new_variable(nonnegative=True)
    
    x = [x_var[j] for j in range(n-1)]
    print("X ", x)
    
    x.append(1-sum(x))
    print("X ", x)
    
    lp.add_constraint(x[-1]>=0)

    y = lp.new_variable(nonnegative=True)

    exp_return = [sum(r)/T for r in hist_data]
    print("exp_return ", exp_return)

    for t in range(T):

        dev = sum(x[j]*hist_data[j][t] - exp_return[j] for j in range(n))
        print("dev ", dev)

        lp.add_constraint(dev <= y[t])
    
        lp.add_constraint(dev >= -y[t])
   
    reward = sum([x[j]*exp_return[j] for j in range(n)])
    print("reward ", reward)
 
    risk = sum([y[t] for t in range(T)])/T
    print("risk ", risk)

    obj_fun = mu*reward-risk
    print("obj ", obj_fun)

    lp.set_objective(obj_fun)

    return lp


def portfolio_bsa(portfolio_lp):

    c = K.make_proof_cell()
    bsa = c.bsa
    return bsa

def find_portfolio_complex(hist_data, mu_value):

    K.<mu> = ParametricRealField(mu_value)
    lp = setup_portfolio_lp(hist_data, mu)
    bsa = portfolio_bsa(lp)
    

    