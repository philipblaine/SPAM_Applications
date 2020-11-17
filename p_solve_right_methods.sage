def check_solve_and_poly(A, Y):

    
    poly = make_poly(A,Y)

    verts = get_poly_verts(poly)

    X = solve_right(Y)

    return verts == X