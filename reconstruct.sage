def reconstruct(LP):

    """
    INPUT:  LP object of MILP type
    OUTPUT: exact rational solution to LP



    """


    # testing the integrality of constraint coefficients in LP

    num_cons_coeffs = 0
    int_counter = 0

    IP = True
   
    for i in range(len(LP.constraints())):
        for ele in LP.constraints()[i][1][1]:
            num_cons_coeffs += 1
            if ele == int(ele):
                int_counter += 1

    if num_cons_coeffs == int_counter:
        IP = True

    else:
        IP = False

    print(IP)

    if IP:
        return exact_optsol(LP)

    else:
        return exact_optsol2(LP)
                