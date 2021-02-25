def ineqex2check():
    r'''
    Checks to see if Adib's set of inequalities describes the same cell as my generated inequalities from SPAM.
    
    For 100,000 random tuples (a,b,A,B,g) if they satisfy Adib's inequalities then my inequalities are checked. If both sets of inequalities hold, checker appends True1.

    If a tuple fails to satisfy Adib's inequalities, I then check to see if my set of inequalities also fails. If this is the case, checker appends True2.

    In EITHER of these cases, a version of True is returned since this is a desired result: satisfying or failing to satisfy BOTH sets of inequalities.

    If neither of these cases hold (i.e. if Adib's set is satisfied and mine is not, or vice versa) checker appends False.

    Once 100,000 tuples are tested, checker is examined. If checker contains any "False" from the previous steps, ineqcheck returns False.

    If no instances of "False" in checker can be found, ineqcheck returns True. This confirms that for 100,000 points, they all lie either inside both cells of outside of both cells.


        EXAMPLES::
        
            sage: ineqex2check()
            True

    '''

    checker = []

    for i in range(0,100000):

        a = randint(0,100)
        b = randint(0,100)
        A = randint(0,100)
        B = random()
        g = randint(0,100)
        
        adif = (a-A)
        b1sum = (1+B)
        b1sum2 = (1+B)*(1+B)
        bg45 = ((9/2)*b*g)

        boolcheck = False

        if ((0<A) and (A<a) and (0<B) and (B<1) and (((adif*b1sum)/(bg45-(b1sum2)))>0) and (((2*adif)/(3*b))*(bg45/(bg45-(b1sum2)))>0) and ((adif*b1sum2)/(bg45-(b1sum2))<A) and (((2/9)*(b1sum2))<(b*g))):
            boolcheck = True

        if boolcheck == True:
            if (((-a+A)<0) and ((B-1)<0) and (-b<0) and (-B<0) and (-A<0) and (-g<0) and ((2*B*B - 9*b*g + 4*B + 2)<0) and ((2*a*B*B - 9*b*A*g + 4*a*B + 2*a)<0)):
                boolcheck = True
                checker.append("True1")
                #print("True1")

        elif boolcheck == False:
            if not((((-a+A)<0) and ((B-1)<0) and (-b<0) and (-B<0) and (-A<0) and (-g<0) and ((2*B*B - 9*b*g + 4*B + 2)<0) and ((2*a*B*B - 9*b*A*g + 4*a*B + 2*a)<0))):
                boolcheck = True
                checker.append("True2")
                #print("True2")

        else:
            boolcheck = False
            checker.append("False")
            #print("False")


    for ele in checker:
        if ele == "False":
            return False
    return True

        

    
        