def exact_speed_test(m, n):

    A = Matrix(np.random.randint(100,size=(m, n)))
    Y = Matrix(np.random.randint(100,size=(m, 1)))

    X1 = A.solve_right(Y)

    Y1 = vector(Y)
    
    eqnlist = []
    alist = [ele for ele in A]

    for i in range(len(Y1)):
        eqnlist.append([-Y1[i]])

    for j in range(m+n):
        for k in range(m+n):
            eqnlist[j].append(alist[j][k])

    npoly = Polyhedron(eqns=eqnlist, backend="normaliz")

    dpoly = Polyhedron(eqns=eqnlist)

    Xn = npoly.vertices_list()
    Xd = dpoly.vertices_list()

    lenxn = len(Xn)
    lenxd = len(Xd)
 
    for s in range(lenxn):
        Xn[s] = tuple(Xn[s])

    for t in range(lenxd):
        Xd[t] = tuple(Xd[t])

    tupleXn = tuple(Xn)
    tupleXd = tuple(Xd)

    for l in range(lenxn):
        print(tupleXn[l][0:n])

    for u in range(lenxd):
        print(tupleXd[u][0:n])

    