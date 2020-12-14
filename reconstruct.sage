def reconstruct(LP):

    num_cons_coeffs = 0
    Tcounter = 0
   
    for i in range(len(LP.constraints())):
        for ele in p.constraints()[i][1][1]:
            num_cons_coeffs += 1
            if ele == int(ele):
                Tcounter += 1

    if num_cons_coeffs == Tcounter:
        return True

    else:
        return False
                