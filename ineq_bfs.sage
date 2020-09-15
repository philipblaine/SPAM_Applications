logging.disable(logging.WARN)
complex = SemialgebraicComplex(ineq, ['a','b','A','B','g'], find_region_type=result_concrete_value,default_var_bound=(-1000,1000))
complex.bfs_completion(var_value=[2,1,1,1/2,10], check_completion=False, wall_crossing_method='heuristic', goto_lower_dim=False)
sorted(c.region_type for c in complex.components)
for i in complex.components:
    print(i)