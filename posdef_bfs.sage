complex = SemialgebraicComplex(test_posdef, ['a', 'b'], find_region_type=return_result, default_var_bound=(-2,2))
complex.bfs_completion(var_value=[1,1], wall_crossing_method="heuristic", goto_lower_dim=False)
sorted(c.region_type for c in complex.components)
for i in complex.components:
    print(i)
for j in range(len(complex.components)):
    print(sorted(complex.components[j].bsa.lt_poly()))