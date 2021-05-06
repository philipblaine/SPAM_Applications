def portfolio_risk_and_reward(hist_data, weights):

    n = len(hist_data)
    x = weights
    T = len(hist_data[0])
    exp_return = [sum(r) / T for r in hist_data]
    reward = sum([x[j] * exp_return[j] for j in range(n)])

    sum_abs_dev = 0
    for t in range(T):
        dev = sum(x[j] * (hist_data[j][t] - exp_return[j]) for j in range(n))
        abs_dev = abs(dev)
        sum_abs_dev += abs_dev

    risk = sum_abs_dev / T

    return reward, risk


def ef(hist_data, combined_list):

    num_portfolios = len(combined_list)
    points = []

    for i in range(num_portfolios):
    
        reward, risk = portfolio_risk_and_reward(hist_data, combined_list[i][1])
        points.append((reward, risk))

    return points
    



