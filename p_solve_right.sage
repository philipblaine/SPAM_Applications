def p_solve_right(A, Y):

    X = A.solve_right(Y)

    vx = vector(X)
    return tuple(vx)