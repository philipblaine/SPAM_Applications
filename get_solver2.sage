def get_solver2(constraint_generation = False, solver = None, base_ring = None):
    """
    Return a solver according to the given preferences

    INPUT:

    - ``solver`` -- one of the following:

        - a string indicating one of the available solvers
          (see :class:`MixedIntegerLinearProgram`);

        - ``None`` (default), in which case the default solver is used
          (see :func:`default_mip_solver`);

        - or a callable (such as a class), in which case it is called,
          and its result is returned.

    - ``base_ring`` -- If not ``None``, request a solver that works over this
        (ordered) field.  If ``base_ring`` is not a field, its fraction field
        is used.

        For example, is ``base_ring=ZZ`` is provided, the solver will work over
        the rational numbers.  This is unrelated to whether variables are
        constrained to be integers or not.

    - ``constraint_generation`` -- Only used when ``solver=None``.

      - When set to ``True``, after solving the ``MixedIntegerLinearProgram``,
        it is possible to add a constraint, and then solve it again.
        The effect is that solvers that do not support this feature will not be
        used.

      - Defaults to ``False``.

    .. SEEALSO::

        - :func:`default_mip_solver` -- Returns/Sets the default MIP solver.

    EXAMPLES::

        sage: from sage.numerical.backends.generic_backend import get_solver
        sage: p = get_solver()
        sage: p = get_solver(base_ring=RDF)
        sage: p.base_ring()
        Real Double Field
        sage: p = get_solver(base_ring=QQ); p
        <...sage.numerical.backends.ppl_backend.PPLBackend...>
        sage: p = get_solver(base_ring=ZZ); p
        <...sage.numerical.backends.ppl_backend.PPLBackend...>
        sage: p.base_ring()
        Rational Field
        sage: p = get_solver(base_ring=AA); p
        <...sage.numerical.backends.interactivelp_backend.InteractiveLPBackend...>
        sage: p.base_ring()
        Algebraic Real Field
        sage: d = polytopes.dodecahedron()
        sage: p = get_solver(base_ring=d.base_ring()); p
        <...sage.numerical.backends.interactivelp_backend.InteractiveLPBackend...>
        sage: p.base_ring()
        Number Field in sqrt5 with defining polynomial x^2 - 5 with sqrt5 = 2.236067977499790?
        sage: p = get_solver(solver='InteractiveLP', base_ring=QQ); p
        <...sage.numerical.backends.interactivelp_backend.InteractiveLPBackend...>
        sage: p.base_ring()
        Rational Field

    Passing a callable as the 'solver'::

        sage: from sage.numerical.backends.glpk_backend import GLPKBackend
        sage: p = get_solver(solver=GLPKBackend); p
        <...sage.numerical.backends.glpk_backend.GLPKBackend...>

    Passing a callable that customizes a backend::

        sage: def glpk_exact_solver():
        ....:     from sage.numerical.backends.generic_backend import get_solver
        ....:     b = get_solver(solver="GLPK")
        ....:     b.solver_parameter("simplex_or_intopt", "exact_simplex_only")
        ....:     return b
        sage: codes.bounds.delsarte_bound_additive_hamming_space(11,3,4,solver=glpk_exact_solver) # long time
        8

    TESTS:

    Test that it works when the default solver is a callable, see :trac:`28914`::

        sage: old_default = default_mip_solver()
        sage: from sage.numerical.backends.glpk_backend import GLPKBackend
        sage: default_mip_solver(GLPKBackend)
        sage: M = MixedIntegerLinearProgram()   # indirect doctest
        sage: M.get_backend()
        <...GLPKBackend...>
        sage: default_mip_solver(old_default)

    """
    if solver is None:

        solver = default_mip_solver()

        if base_ring is not None:
            base_ring = base_ring.fraction_field()
            from sage.rings.all import QQ, RDF
            if base_ring is QQ:
                solver = "Ppl"
            elif solver in ["Interactivelp", "Ppl"] and not base_ring.is_exact():
                solver = "Glpk"
            elif base_ring is not RDF:
                solver = "Interactivelp"

        # We do not want to use Coin for constraint_generation. It just does not
        # work
        if solver == "Coin" and constraint_generation:
            solver = "Glpk"

    if callable(solver):
        kwds = {}
        if base_ring is not None:
            kwds['base_ring']=base_ring
        return solver(**kwds)

    else:
        if type(solver) == str:
            solver = solver.capitalize()
        #elif type(solver) == tuple:
            #solver_list = ["",""]
            #print("tuple1")
            #for ele in solver:
                #ele = ele.capitalize()
                #print(ele)

    if type(solver) == str:

        if solver == "Coin":
            from sage_numerical_backends_coin.coin_backend import CoinBackend
            return CoinBackend()

        elif solver == "Glpk":
            print("hello")
            from sage.numerical.backends.glpk_backend import GLPKBackend
            return GLPKBackend()

        elif solver == "Glpk/exact":
            from sage.numerical.backends.glpk_exact_backend import GLPKExactBackend
            return GLPKExactBackend()

        elif solver == "Cplex":
            from sage_numerical_backends_cplex.cplex_backend import CPLEXBackend
            return CPLEXBackend()

        elif solver == "Cvxopt":
            from sage.numerical.backends.cvxopt_backend import CVXOPTBackend
            return CVXOPTBackend()

        elif solver == "Gurobi":
            from sage_numerical_backends_gurobi.gurobi_backend import GurobiBackend
            return GurobiBackend()

        elif solver == "Ppl":
            from sage.numerical.backends.ppl_backend import PPLBackend
            return PPLBackend(base_ring=base_ring)

        elif solver == "Interactivelp":
            from sage.numerical.backends.interactivelp_backend import InteractiveLPBackend
            return InteractiveLPBackend(base_ring=base_ring)

    elif type(solver) == tuple:
        solver_list = ["",""]
        
        for i in range(len(solver)):
            if solver[i].upper() == "COIN":
                from sage_numerical_backends_coin.coin_backend import CoinBackend
                solver_list[i] = CoinBackend()

            elif solver[i].upper() == "GLPK":
                from sage.numerical.backends.glpk_backend import GLPKBackend
                solver_list[i] = GLPKBackend()

            elif solver[i].upper() == "GLPK/EXACT":
                from sage.numerical.backends.glpk_exact_backend import GLPKExactBackend
                solver_list[i] = GLPKExactBackend()

            elif solver[i].upper() == "CPLEX":
                from sage_numerical_backends_cplex.cplex_backend import CPLEXBackend
                solver_list[i] = CPLEXBackend()

            elif solver[i].upper() == "CVXOPT":
                from sage.numerical.backends.cvxopt_backend import CVXOPTBackend
                solver_list[i] = CVXOPTBackend()

            elif solver[i].upper() == "GUROBI":
                from sage_numerical_backends_gurobi.gurobi_backend import GurobiBackend
                solver_list[i] = GurobiBackend()

            elif solver[i].upper() == "PPL":
                from sage.numerical.backends.ppl_backend import PPLBackend
                solver_list[i] = PPLBackend(base_ring=base_ring)

            elif solver[i].upper() == "INTERACTIVELP":
                from sage.numerical.backends.interactivelp_backend import InteractiveLPBackend
                solver_list[i] = InteractiveLPBackend(base_ring=base_ring)

        return solver_list
    


    

    else:
        raise ValueError("'solver' should be set to 'GLPK', 'GLPK/exact', 'Coin', 'CPLEX', 'CVXOPT', 'Gurobi', 'PPL', 'InteractiveLP', None (in which case the default one is used), or a callable.")

    