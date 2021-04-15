def parametric_simplex_method(hist_data):

    K.<mu> = ParametricRealField([10])
    P = setup_portfolio_lp(hist_data)
    b = P.get_backend()
    lp = b.InteractiveLPProblem()
    interactivelpproblem
    lp_st = lp.standard_form()
    FD = lp_st.final_revised_dictionary()

    threshold = Infinity
    while threshold >= 0
        obj_coeffs = FD.objective_coefficients()
        mu = var('mu')
        coeff_list = []
        #how to record indices along with objective coefficients?
        for ele in obj_coeffs:
            coeff_list.append(ele)
        numerator_list = []
        for ele in coeff_list:
            numerator_list.append(ele.numerator())
        mu_sol_list = []
        for ele in numerator_list:
            mu_sol_list.append(numer.roots()[0][0])
        max = 0
        for ele in mu_sol_list:
            if ele >= max:
                max = ele
        D.enter(index_of_max)
        leaving_var = min(D.possible_leaving)
        D.leave(leaving_var)
        
        threshold = max
    

steps in loop
    symbolic mu 
    poly in mu
    list of ^ 
    solve for mu, take max
    entering corresponds to index of ^
    D.ente
    D.possible_leaving, take min
    record threshold

    
        
        


    
    


      