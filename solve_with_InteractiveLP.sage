def solve_with_InteractiveLP(InteractiveLP_lp):

    """
    takes LP with "InteractiveLP" solver and outputs the exact rational solution using InteractiveLP the whole way

    """

    int_sol = InteractiveLP_lp.solve()

    int_sol_list = InteractiveLP_lp.get_values(w)

    return int_sol_list