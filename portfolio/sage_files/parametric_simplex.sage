def parametric_simplex_method(hist_data):



    #how to setup InteractiveLPProblem using hist_data? 
    #previously I displayed 


    # use interactiveLP for first phase, mu = infty


    K.<mu> = ParametricRealField([any concrete value])

    P = setup_portfolio_lp(hist_data)
    b = P.get_backend()

    lp = b.interactiveLp
    interactivelpproblem
    standardofmr
    finalreviseddictionary

    objcoeffs
    sym
    poly in mu
    list of ^ 
    solve for mu, take max
    entering corresponds to index of ^
    D.ente
    D.possible_leaving, take min
    record threshold

    #once setup...

    while threshold >= 0:
        
        1. with basic_vars from FD, look at objective function with nonbasic_vars
        2. check coefficients with mu in objective function
        3. coefficient that becomes 0 first from incrementally decresing mu corresponds to entering var
        4. find leaving variable by ratio test
        5. use .enter and .leave to pivot once
        6. mu value at which coefficient from above changed signs is the mu value endpoint of interval
        7. add mu value interval to list
        8. retrieve optimal solution from dictionary #how?
        9. retrieve objective value from dictionary
        10. optimal solution and obj value to list

        11. repeat 1-10 until mu=0

    12. return list 

    
        
        


    
    


      