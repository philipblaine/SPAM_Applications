def ineqex3check():
    r'''
    Checks to see if Adib's set of inequalities describes the same cell as my generated inequalities from SPAM.
    
    For 100,000 random tuples (a,b,A,B,g) if they satisfy Adib's inequalities then my inequalities are checked. If both sets of inequalities hold, checker appends True1.

    If a tuple fails to satisfy Adib's inequalities, I then check to see if my set of inequalities also fails. If this is the case, checker appends True2.

    In EITHER of these cases, a version of True is returned since this is a desired result: satisfying or failing to satisfy BOTH sets of inequalities.

    If neither of these cases hold (i.e. if Adib's set is satisfied and mine is not, or vice versa) checker appends False.

    Once 100,000 tuples are tested, checker is examined. If checker contains any "False" from the previous steps, ineqcheck returns False.

    If no instances of "False" in checker can be found, ineqcheck returns True. This confirms that for 100,000 points, they all lie either inside both cells of outside of both cells.


        EXAMPLES::
        
            sage: ineqex3check()
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
        bg4 = 4*b*g

        boolcheck = False

        if ((0<A) and (A<a) and (0<B) and (B<1) and (((adif*b1sum)/(bg4-(b1sum2)))>0) and (((adif)/(2*b))*(bg4/(bg4-(b1sum2)))>0) and ((adif*b1sum2)/(bg4-(b1sum2))<A) and (((1/4)*(b1sum2))<(b*g))):
            boolcheck = True

        if boolcheck == True:
            if (((-a+A)<0) and ((B-1)<0) and (-b<0) and (-B<0) and (-A<0) and (-g<0) and ((B*B - 4*b*g + 2*B + 1)<0) and ((a*B*B - 4*b*A*g + 2*a*B + a)<0)):
                boolcheck = True
                checker.append("True1")
                #print("True1")

        elif boolcheck == False:
            if not((((-a+A)<0) and ((B-1)<0) and (-b<0) and (-B<0) and (-A<0) and (-g<0) and ((B*B - 4*b*g + 2*B + 1)<0) and ((a*B*B - 4*b*A*g + 2*a*B + a)<0))):
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

        

    
        