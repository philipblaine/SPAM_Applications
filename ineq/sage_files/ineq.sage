def ineq(a,b,A,B,g):
    r"""
    Checks to see if values given for 5 parameters satisfy the system of inequalities below.

    These parameters correspond to usual parameters for Cournot games representing duopoly interactions.

    Returns True if satisfied, False if not.

    EXAMPLES::

        sage: ineq(2,1,1,1/2,10)
        True
        
        sage: ineq(1,1,1,1,1)
        False


    """

    checker = []

    adif = (a-A)
    b2dif = (2-B)
    b1sum = (1+B)
    bg45 = ((9/2)*b*g)

    if not((0<A) and (A<a)):
        #print("ie1 bad")
        checker.append("")

    if not((0<B) and (B<1)):
        #print("ie2 bad")
        checker.append("")

    if not(((adif*b2dif)/(bg45-(b2dif*b1sum)))>0):
        #print("ie3 bad")
        checker.append("")

    if not(((2*adif)/(3*b))*(bg45/(bg45-(b2dif*b1sum)))>0):
        #print("ie4 bad")
        checker.append("")

    if not(((adif*b2dif)/(bg45-(b2dif*b1sum))*b1sum)<A):
        print("ie5 bad")
        checker.append("")

    if not(((2/9)*(b2dif*b2dif))<(b*g)):
        #print("ie6 bad")
        checker.append("")

    #print(f"ie3: {(adif*b2dif)/(bg45-(b2dif*b1sum))}")
    #print(f"ie4: {((2*adif)/(3*b))*(bg45/(bg45-(b2dif*b1sum)))}")
    #print(f"ie5: {((adif*b2dif)/(bg45-(b2dif*b1sum))*b1sum)}")
    #print(f"ie6: {((2/9)*(b2dif*b2dif))}")

    if checker == []:
        iesol = True
    else:
        iesol = False
    
    return iesol
        
        
        