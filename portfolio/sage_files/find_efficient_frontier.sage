def find_efficient_frontier(hist_data, combined_list):
    expected_returns = []

    #computes expected returns for each asset and adds to a list
    for i in range(len(hist_data)):
        sum = 0
        mean = 0
        for j in range(len(hist_data[i])):
            h3i = hist_data[i][j]
            sum += h3i
        mean = sum/len(hist_data[i])
        expected_returns.append(mean)

    portfolio_expected_returns = []

    #using returns for each asset, computes expected return for each optimal portfolio with different asset weights
    for i in range(len(combined_list)):
        sum = 0
        for j in range(len(hist_data)):
            sum += combined_list[i][1][j]*expected_returns[j]
        portfolio_expected_returns.append(sum)

    MAD_list = []

    #computer the MAD for each portfolio and adds to a list
    for i in range(len(combined_list)):
        #resets portfolio MAD for each portfolio
        port_mad = 0
        #computes MAD for each portfolio
        for j in range(len(hist_data)):
            #reset MAD and absolute weighted difference from mean for each asset
            asset_mad = 0
            awdiff_sum = 0
            for k in range(len(hist_data[j])):
                diff = hist_data[j][k] - expected_returns[j]
                wdiff = combined_list[i][1][j]*diff
                awdiff = abs(wdiff)
                awdiff_sum += awdiff
            asset_mad = awdiff_sum/len(hist_data[j])
            port_mad += asset_mad
        MAD_list.append(port_mad)

    portfolio_reward_and_risk = []

    #combines expected return (reward) with MAD (risk) for each portfolio and adds these tuples (reward, risk) to a list
    for i in range(len(combined_list)):
        portfolio_reward_and_risk.append((portfolio_expected_returns[i], MAD_list[i]))

    #efficient_frontier_points.append(portfolio_reward_and_risk)

    #creates Polyhedron with vertices=tuples from list of (reward,risk) for each portfolio
    P = Polyhedron(vertices=portfolio_reward_and_risk)

    P_plot = plot(P)
        

    return P_plot




    
    