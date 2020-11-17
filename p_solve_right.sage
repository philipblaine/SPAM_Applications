def p_solve_right(A, Y):

    """ solves Ax = Y with solve_right and returns solution as tuple
 
    """

    X = A.solve_right(Y)

    vx = vector(X)
    return tuple(vx)