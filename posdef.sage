def posdef(x,y):

    A = matrix(QQ, [[x,y],[y,1/4]])
    
    return A.is_positive_definite()