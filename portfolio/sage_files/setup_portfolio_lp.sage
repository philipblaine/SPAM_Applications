def setup_portfolio_lp(hist_data, mu, base_ring=None):

    if base_ring is None:
        base_ring = mu.parent()
    
    n = len(hist_data)
    #print("n ", n)
    T = len(hist_data[0])
    #print("T ", T)
    
    lp = MixedIntegerLinearProgram(solver=("GLPK","InteractiveLP"),maximization=True,base_ring=mu.parent())
    
    x_var = lp.new_variable(nonnegative=True)
    
    x = [x_var[j] for j in range(n-1)]
    #print("X ", x)
    
    x.append(1-sum(x))
    #print("X ", x)
    #print(x)
    
    lp.add_constraint(x[-1]>=0)

    y = lp.new_variable(nonnegative=True)

    exp_return = [sum(r)/T for r in hist_data]
    #print("exp_return ", exp_return)

    for t in range(T):

        dev = sum(x[j]*(hist_data[j][t] - exp_return[j]) for j in range(n))
        #dev = x_var[0]*(hist_data[0][t]-exp_return[0]) + x_var[1]*(hist_data[1][t]-exp_return[1]) + x_var[2]*(hist_data[2][t]-exp_return[2]) + x_var[3]*(hist_data[3][t]-exp_return[3])+ x_var[4]*(hist_data[4][t]-exp_return[4]) + x_var[5]*(hist_data[5][t]-exp_return[5]) + x_var[6]*(hist_data[6][t]-exp_return[6]) + x_var[7]*(hist_data[7][t]-exp_return[7]) + x[8]*(hist_data[8][t]-exp_return[8])
        
        #print("dev ", dev)

        lp.add_constraint(dev <= y[t])
    
        lp.add_constraint(dev >= -y[t])
   
    reward = sum([x[j]*exp_return[j] for j in range(n)])
    #print("reward ", reward)
 
    risk = sum([y[t] for t in range(T)])/T
    #print("risk ", risk)

    obj_fun = mu*reward-risk
    #print("obj ", obj_fun)

    lp.set_objective(obj_fun)

    return lp

