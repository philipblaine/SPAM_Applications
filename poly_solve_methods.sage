

def make_full_matrix(nrows, ncols):

    r = min(nrows,ncols)

    A = random_matrix(QQ, nrows, ncols, algorithm="echelonizable", rank=r)

    return A


def make_poly(A, Y):

    ncol = A.ncols()
    nrow = A.nrows()
    Y = vector(Y)

    eqnlist = []
    alist = [ele for ele in A]

    for i in range(len(Y)):
        eqnlist.append([-Y[i]])

    for j in range(ncol):
        for k in range(ncol):
            eqnlist[j].append(alist[j][k])

    poly = Polyhedron(eqns=eqnlist)

    return poly

def get_poly_verts(poly):

    X = poly.vertices_list()
    
    for s in range(len(X)):
        X[s] = tuple(X[s])

    for l in range(len(X)):
        return tuple(X)[l]