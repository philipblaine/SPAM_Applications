def check_solve_and_poly(A, Y):
    
    poly = make_poly(A,Y)

    verts = get_poly_verts(poly)

    X = A.solve_right(Y)

    vx = vector(X)

    return verts == tuple(vx)