complex = SemialgebraicComplex(test_posdef, ['x', 'y'], find_region_type=return_result, default_var_bound=(-2,2))
complex.bfs_completion(var_value=[-1,1], check_completion=False, goto_lower_dim=False)
sorted(c.region_type for c in complex.components)
for i in complex.components:
    print(i)