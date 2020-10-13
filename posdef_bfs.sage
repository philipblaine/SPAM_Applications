logging.disable(logging.WARN)
complex = SemialgebraicComplex(test_posdef, ['a', 'b'], find_region_type=result_symbolic_expression, default_var_bound=(-10,10))
complex.bfs_completion(var_value=[5,0], check_completion=False, wall_crossing_method="heuristic", goto_lower_dim=False)
sorted(c.region_type for c in complex.components)
for i in complex.components:
    print(i)
for j in range(len(complex.components)):
    print(sorted(complex.components[j].bsa.lt_poly()))