def setup_portfolio_lp(hist_data, mu):


    
    n = len(hist_data)

    T = len(hist_data[0])

    lp = MixedIntegerLinearProgram(solver=("GLPK","InteractiveLP"),maximization=True,base_ring=mu.parent())
    
    x_var = lp.new_variable(nonnegative=True)
    
    x = [x_var[j] for j in range(n-1)]
    
    x.append(1-sum(x))

    lp.add_constraint(x[-1]>=0)

    y = lp.new_variable(nonnegative=True)

    exp_return = [sum(r)/T for r in hist_data]

    for t in range(T):

        dev = sum(x[j]*(hist_data[j][t] - exp_return[j]) for j in range(n))

        lp.add_constraint(dev <= y[t])
    
        lp.add_constraint(dev >= -y[t])
   
    reward = sum([x[j]*exp_return[j] for j in range(n)])

    risk = sum([y[t] for t in range(T)])/T

    obj_fun = mu*reward-risk

    lp.set_objective(obj_fun)

    return lp


def portfolio_bsa(portfolio_lp):

    c = K.make_proof_cell()
    bsa = c.bsa
    return bsa

def find_portfolio_complex(hist_data, mu_value):

    while mu_value >= 0 and mu_value <= 10:
   
        K.<mu> = ParametricRealField(mu_value)
        lp = setup_portfolio_lp(hist_data, mu)
        obj_value = lp.solve()
        
        bsa = portfolio_bsa(lp)

        mu_master_list = []
        lt = list(bsa.lt_poly())
        if lt != []:
            for ele in lt:
                mu_master_list.append(ele)
        mu_value = mu_master_list[0]
        mu_master_list.remove(mu_value)

    


    