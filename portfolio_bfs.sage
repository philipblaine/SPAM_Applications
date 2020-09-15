complex = SemialgebraicComplex(portfolio, ['mu'], find_region_type=result_concrete_value, default_var_bound=(0,100))
complex.bfs_completion(var_value=[1/2], check_completion=False,wall_crossing_method="heuristic", goto_lower_dim=False)
#sorted(c.region_type for c in complex.components)
#for i in complex.components:
    #print(i)