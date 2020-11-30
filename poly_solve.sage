def poly_solve(A, Y):
   
    poly = make_poly(A, Y)

    verts = get_poly_verts(poly)

    return verts


def ppl_poly_solve(A,Y):

    poly = make_ppl_poly(A,Y)

    verts = get_poly_verts(poly)

    return verts
