def exact_speed_test(m, n):

    A = Matrix(np.random.randint(100,size=(m, n)))
    Y = Matrix(np.random.randint(100,size=(m, 1)))

    #print(A, Y)
    X1 = A.solve_right(Y)

    Y1 = vector(Y)
    #print(Y1)
    
    eqnlist = []
    alist = [ele for ele in A]
    #print(len(Y1))
    for i in range(len(Y1)):
        eqnlist.append([-Y1[i]])
    #print("hi")
    for j in range(m):
        for k in range(m):
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

    print(X1[0])

    for l in range(lenxn):
        print(tupleXn[l][0])

    for u in range(lenxd):
        print(tupleXd[u][0])

    