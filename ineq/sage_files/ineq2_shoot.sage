complex = SemialgebraicComplex(ineq2, ['a','b','A','B','g'], find_region_type=result_concrete_value,default_var_bound=(-1000,1000))
complex.shoot_random_points(1000)
sorted(c.region_type for c in complex.components)
for i in complex.components:
    print(i)
#for j in range(len(complex.components)):
    #print(sorted(complex.components[j].bsa.lt_poly()))