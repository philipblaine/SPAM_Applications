#methods for creating matrices A, Y; solving Ax = Y using poly

def make_full_matrix(nrows, ncols, nbound, dbound):
    
    """ constructs a random rational full-rank matrix 

            sage: A = make_full_matrix(3,3)
            sage: A
            [ -1  -3   1]
            [  2   5  -1]
            [ -5 -15   6]

            sage: Y = make_full_matrix(3,1)
            sage: Y
            [4]
            [2]
            [3]

    """



    #r = min(nrows,ncols)
    

    A = random_matrix(QQ, nrows, ncols, num_bound=nbound, den_bound=dbound)
    #A = random_matrix(QQ, nrows, ncols, algorithm="echelonizable", rank=r)

    return A



def make_poly(A, Y):

    """ constructs a polyhedron solving the equation Ax = Y for x

        sage: poly = make_poly(A, Y)
        sage: poly
        A 0-dimensional polyhedron in QQ^3 defined as the convex hull of 1 vertex

    """

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

    poly = Polyhedron(eqns=eqnlist, backend='normaliz')

    return poly

def make_ppl_poly(A,Y):

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

    """ retrieves the vertices of the polyhedron construced with make_poly
   
        sage: verts = get_poly_verts(poly)
        sage: verts
        (60, -27, -17)

    """

    X = poly.vertices_list()
    
    for s in range(len(X)):
        X[s] = tuple(X[s])

    
    for l in range(len(X)):
        return tuple(X)[l]

def check_sols(vertsol, solsol):

    return vertsol == solsol
