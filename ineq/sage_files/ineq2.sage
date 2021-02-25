def ineq2(a,b,A,B,g):
    r"""
    Checks to see if values given for 5 parameters satisfy the system of inequalities below.

    These parameters correspond to usual parameters for Cournot games representing duopoly interactions.

    Returns False once an inequality is violated. Otherwise returns True.

    EXAMPLES::

        sage: ineq2(2,1,1,1/2,10)
        True
        
        sage: ineq2(1,1,1,1,1)
        False


    """

    adif = (a-A)
    b2dif = (2-B)
    b1sum = (1+B)
    bg45 = ((9/2)*b*g)

    if not((0<A) and (A<a)):
        return False

    elif not((0<B) and (B<1)):
        return False

    elif not(((adif*b2dif)/(bg45-(b2dif*b1sum)))>0):
        return False

    elif not(((2*adif)/(3*b))*(bg45/(bg45-(b2dif*b1sum)))>0):
        return False

    elif not(((adif*b2dif)/(bg45-(b2dif*b1sum))*b1sum)<A):
        return False

    elif not(((2/9)*(b2dif*b2dif))<(b*g)):
        return False

    #print(f"ie3: {(adif*b2dif)/(bg45-(b2dif*b1sum))}")
    #print(f"ie4: {((2*adif)/(3*b))*(bg45/(bg45-(b2dif*b1sum)))}")
    #print(f"ie5: {((adif*b2dif)/(bg45-(b2dif*b1sum))*b1sum)}")
    #print(f"ie6: {((2/9)*(b2dif*b2dif))}")

    else:
        return True
        
        
        