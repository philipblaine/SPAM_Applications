def ineqex3(a,b,A,B,g):
    r"""
    Checks to see if values given for 5 parameters satisfy the system of inequalities below.

    These parameters correspond to usual parameters for Cournot games representing duopoly interactions.

    Returns False once an inequality is violated. Otherwise returns True.

    EXAMPLES::

        sage: ineqex3(2,1,1,1/2,10)
        True
        
        sage: ineqex3(1,1,1,1,1)
        False


    """

    adif = (a-A)
    b1sum = (1+B)
    b1sum2 = (1+B)*(1+B)
    bg4 = 4*b*g

    if not((0<A) and (A<a)):
        return False

    elif not((0<B) and (B<1)):
        return False

    elif not(((adif*b1sum)/(bg4-(b1sum2)))>0):
        return False

    elif not(((adif)/(2*b))*(bg4/(bg4-(b1sum2)))>0):
        return False

    elif not((adif*b1sum2)/(bg4-(b1sum2))<A):
        return False

    elif not(((1/4)*(b1sum2))<(b*g)):
        return False

    else:
        return True
        
        
        