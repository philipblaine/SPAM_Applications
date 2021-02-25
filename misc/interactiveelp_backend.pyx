r"""
InteractiveLP Backend
AUTHORS:
- Nathann Cohen (2010-10)      : generic_backend template
- Matthias Koeppe (2016-03)    : this backend
"""

# ****************************************************************************
#       Copyright (C) 2010 Nathann Cohen <nathann.cohen@gmail.com>
#       Copyright (C) 2016 Matthias Koeppe <mkoeppe@math.ucdavis.edu>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************

from sage.numerical.mip import MIPSolverException
from sage.numerical.interactive_simplex_method import InteractiveLPProblem, default_variable_name
from sage.modules.all import vector
from copy import copy


cdef class InteractiveLPBackend:
    """
    MIP Backend that works with :class:`InteractiveLPProblem`.
    This backend should be used only for linear programs over general fields,
    or for educational purposes.  For fast computations with floating point
    arithmetic, use one of the numerical backends. For exact computations
    with rational numbers, use backend 'PPL'.
    There is no support for integer variables.
    EXAMPLES::
        sage: from sage.numerical.backends.generic_backend import get_solver
        sage: p = get_solver(solver = "InteractiveLP")
    TESTS:
    General backend testsuite::
        sage: p = MixedIntegerLinearProgram(solver="InteractiveLP")
        sage: TestSuite(p.get_backend()).run(skip="_test_pickling")
    """

    def __cinit__(self, maximization = True, base_ring = None):
        """
        Cython constructor
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
        This backend can work with irrational algebraic numbers::
            sage: poly = polytopes.dodecahedron(base_ring=AA)
            sage: lp, x = poly.to_linear_program(solver='InteractiveLP', return_variable=True)
            sage: lp.set_objective(x[0] + x[1] + x[2])
            sage: lp.solve()
            2.291796067500631?
            sage: lp.get_values(x[0], x[1], x[2])
            [0.763932022500211?, 0.763932022500211?, 0.763932022500211?]
            sage: lp.set_objective(x[0] - x[1] - x[2])
            sage: lp.solve()
            2.291796067500631?
            sage: lp.get_values(x[0], x[1], x[2])
            [0.763932022500211?, -0.763932022500211?, -0.763932022500211?]
        """

        if base_ring is None:
            from sage.rings.all import QQ
            base_ring = QQ

        self.lp = InteractiveLPProblem([], [], [], base_ring=base_ring)
        self.set_verbosity(0)

        if maximization:
            self.set_sense(+1)
        else:
            self.set_sense(-1)

        self.row_names = []

    cpdef __copy__(self):
        """
        Returns a copy of self.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = MixedIntegerLinearProgram(solver = "InteractiveLP")
            sage: b = p.new_variable()
            sage: p.add_constraint(b[1] + b[2] <= 6)
            sage: p.set_objective(b[1] + b[2])
            sage: cp = copy(p.get_backend())
            sage: cp.solve()
            0
            sage: cp.get_objective_value()
            6
        """
        cdef InteractiveLPBackend cp = type(self)(base_ring=self.base_ring())
        cp.lp = self.lp                   # it's considered immutable; so no need to copy.
        cp.row_names = copy(self.row_names)
        cp.prob_name = self.prob_name
        return cp

    cpdef base_ring(self):
        """
        Return the base ring.
        OUTPUT:
        A ring. The coefficients that the chosen solver supports.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.base_ring()
            Rational Field
        """
        return self.lp.base_ring()

    def _variable_type_from_bounds(self, lower_bound, upper_bound):
        """
        Return a string designating a variable type in `InteractiveLPProblem`.
        INPUT:
        - ``lower_bound`` - the lower bound of the variable
        - ``upper_bound`` - the upper bound of the variable
        OUTPUT:
        - a string, one of "", "<=", ">="
        The function raises an error if this pair of bounds cannot be
        represented by an `InteractiveLPProblem` variable type.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p._variable_type_from_bounds(0, None)
            '>='
            sage: p._variable_type_from_bounds(None, 0)
            '<='
            sage: p._variable_type_from_bounds(None, None)
            ''
            sage: p._variable_type_from_bounds(None, 5)
            Traceback (most recent call last):
            ...
            NotImplementedError: General variable bounds not supported
        """
        if lower_bound is None:
            if upper_bound is None:
                return ""
            elif upper_bound == 0:
                return "<="
            else:
                raise NotImplementedError("General variable bounds not supported")
        elif lower_bound == 0:
            if upper_bound is None:
                return ">="
            else:
                raise NotImplementedError("General variable bounds not supported")
        else:
            raise NotImplementedError("General variable bounds not supported")

    cpdef int add_variable(self, lower_bound=0, upper_bound=None,
                           binary=False, continuous=True, integer=False,
                           obj=None, name=None, coefficients=None) except -1:
        ## coefficients is an extension in this backend,
        ## and a proposed addition to the interface, to unify this with add_col.
        """
        Add a variable.
        This amounts to adding a new column to the matrix. By default,
        the variable is both nonnegative and real.
        In this backend, variables are always continuous (real).
        If integer variables are requested via the parameters
        ``binary`` and ``integer``, an error will be raised.
        INPUT:
        - ``lower_bound`` - the lower bound of the variable (default: 0)
        - ``upper_bound`` - the upper bound of the variable (default: ``None``)
        - ``binary`` - ``True`` if the variable is binary (default: ``False``).
        - ``continuous`` - ``True`` if the variable is binary (default: ``True``).
        - ``integer`` - ``True`` if the variable is binary (default: ``False``).
        - ``obj`` - (optional) coefficient of this variable in the objective function (default: 0)
        - ``name`` - an optional name for the newly added variable (default: ``None``).
        - ``coefficients`` -- (optional) an iterable of pairs ``(i, v)``. In each
          pair, ``i`` is a variable index (integer) and ``v`` is a
          value (element of :meth:`base_ring`).
        OUTPUT: The index of the newly created variable
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.ncols()
            0
            sage: p.add_variable()
            0
            sage: p.ncols()
            1
            sage: p.add_variable(continuous=True, integer=True)
            Traceback (most recent call last):
            ...
            ValueError: ...
            sage: p.add_variable(name='x',obj=1)
            1
            sage: p.col_name(1)
            'x'
            sage: p.objective_coefficient(1)
            1
        """
        A, b, c, x, constraint_types, variable_types, problem_type, ring, d = self._AbcxCVPRd()
        cdef int vtype = int(binary) + int(continuous) + int(integer)
        if  vtype == 0:
            continuous = True
        elif vtype != 1:
            raise ValueError("Exactly one parameter of 'binary', 'integer' and 'continuous' must be 'True'.")
        if not continuous:
            raise NotImplementedError("Integer variables are not supported")
        variable_types = variable_types + (self._variable_type_from_bounds(lower_bound, upper_bound),)
        col = vector(ring, self.nrows())
        if coefficients is not None:
            for (i, v) in coefficients:
                col[i] = v
        A = A.augment(col)
        if obj is None:
            obj = 0
        c = tuple(c) + (obj,)
        if name is None:
            var_names = default_variable_name("primal decision")
            name = "{}{:d}".format(var_names, self.ncols() + 1)
        x = tuple(x) + (name,)
        self.lp = InteractiveLPProblem(A, b, c, x,
                                       constraint_types, variable_types,
                                       problem_type, ring, objective_constant_term=d)
        return self.ncols() - 1

    cpdef  set_variable_type(self, int variable, int vtype):
        """
        Set the type of a variable.
        In this backend, variables are always continuous (real).
        If integer or binary variables are requested via the parameter
        ``vtype``, an error will be raised.
        INPUT:
        - ``variable`` (integer) -- the variable's id
        - ``vtype`` (integer) :
            *  1  Integer
            *  0  Binary
            *  -1  Continuous
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.ncols()
            0
            sage: p.add_variable()
            0
            sage: p.set_variable_type(0,-1)
            sage: p.is_variable_continuous(0)
            True
        """
        if vtype == -1:
            pass
        else:
            raise NotImplementedError()

    def _AbcxCVPRd(self):
        """
        Retrieve all problem data from the LP.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p._AbcxCVPRd()
            ([], (), (), (), (), (), 'max', Rational Field, 0)
        """
        A, b, c, x = self.lp.Abcx()
        constraint_types = self.lp.constraint_types()
        variable_types = self.lp.variable_types()
        problem_type = self.lp.problem_type()
        base_ring = self.lp.base_ring()
        d = self.lp.objective_constant_term()
        return A, b, c, x, constraint_types, variable_types, problem_type, base_ring, d

    cpdef set_sense(self, int sense):
        """
        Set the direction (maximization/minimization).
        INPUT:
        - ``sense`` (integer) :
            * +1 => Maximization
            * -1 => Minimization
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.is_maximization()
            True
            sage: p.set_sense(-1)
            sage: p.is_maximization()
            False
        """
        A, b, c, x, constraint_types, variable_types, problem_type, ring, d = self._AbcxCVPRd()
        if sense == +1:
            problem_type = "max"
        else:
            problem_type = "min"
        self.lp = InteractiveLPProblem(A, b, c, x,
                                       constraint_types, variable_types,
                                       problem_type, ring, objective_constant_term=d)

    cpdef objective_coefficient(self, int variable, coeff=None):
        """
        Set or get the coefficient of a variable in the objective
        function
        INPUT:
        - ``variable`` (integer) -- the variable's id
        - ``coeff`` (double) -- its coefficient
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.add_variable()
            0
            sage: p.objective_coefficient(0)
            0
            sage: p.objective_coefficient(0,2)
            sage: p.objective_coefficient(0)
            2
        """
        if coeff is None:
            return self.lp.objective_coefficients()[variable]
        else:
            A, b, c, x, constraint_types, variable_types, problem_type, ring, d = self._AbcxCVPRd()
            c = list(c)
            c[variable] = coeff
            self.lp = InteractiveLPProblem(A, b, c, x,
                                           constraint_types, variable_types,
                                           problem_type, ring, objective_constant_term=d)

    cpdef objective_constant_term(self, d=None):
        """
        Set or get the constant term in the objective function
        INPUT:
        - ``d`` (double) -- its coefficient.  If `None` (default), return the current value.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.objective_constant_term()
            0
            sage: p.objective_constant_term(42)
            sage: p.objective_constant_term()
            42
        """
        if d is None:
            return self.lp.objective_constant_term()
        else:
            A, b, c, x, constraint_types, variable_types, problem_type, ring, _ = self._AbcxCVPRd()
            self.lp = InteractiveLPProblem(A, b, c, x,
                                           constraint_types, variable_types,
                                           problem_type, ring, objective_constant_term=d)

    cpdef set_objective(self, list coeff, d = 0):
        """
        Set the objective function.
        INPUT:
        - ``coeff`` -- a list of real values, whose i-th element is the
          coefficient of the i-th variable in the objective function.
        - ``d`` (real) -- the constant term in the linear function (set to `0` by default)
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.add_variables(5)
            4
            sage: p.set_objective([1, 1, 2, 1, 3])
            sage: [p.objective_coefficient(x) for x in range(5)]
            [1, 1, 2, 1, 3]
        Constants in the objective function are respected::
            sage: p = MixedIntegerLinearProgram(solver='InteractiveLP')
            sage: x,y = p[0], p[1]
            sage: p.add_constraint(2*x + 3*y, max = 6)
            sage: p.add_constraint(3*x + 2*y, max = 6)
            sage: p.set_objective(x + y + 7)
            sage: p.solve()
            47/5
        TESTS:
        Constants also work the right way for min::
            sage: p = MixedIntegerLinearProgram(solver='InteractiveLP', maximization=False)
            sage: x,y = p[0], p[1]
            sage: p.add_constraint(2*x + 3*y, max = 6)
            sage: p.add_constraint(3*x + 2*y, max = 6)
            sage: p.set_objective(-x - y - 7)
            sage: p.solve()
            -47/5
        """
        A, b, _, x, constraint_types, variable_types, problem_type, ring, _ = self._AbcxCVPRd()
        c = coeff
        self.lp = InteractiveLPProblem(A, b, c, x,
                                       constraint_types, variable_types,
                                       problem_type, ring, objective_constant_term=d)

    cpdef set_verbosity(self, int level):
        """
        Set the log (verbosity) level
        INPUT:
        - ``level`` (integer) -- From 0 (no verbosity) to 3.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.set_verbosity(2)
        """
        self.verbosity = level

    cpdef remove_constraint(self, int i):
        r"""
        Remove a constraint.
        INPUT:
        - ``i`` -- index of the constraint to remove.
        EXAMPLES::
            sage: p = MixedIntegerLinearProgram(solver="InteractiveLP")
            sage: v = p.new_variable(nonnegative=True)
            sage: x,y = v[0], v[1]
            sage: p.add_constraint(2*x + 3*y, max = 6)
            sage: p.add_constraint(3*x + 2*y, max = 6)
            sage: p.set_objective(x + y + 7)
            sage: p.solve()
            47/5
            sage: p.remove_constraint(0)
            sage: p.solve()
            10
            sage: p.get_values([x,y])
            [0, 3]
        """
        A, b, c, x, constraint_types, variable_types, problem_type, ring, d = self._AbcxCVPRd()
        A = A.delete_rows((i,))
        b = list(b); del b[i]
        constraint_types=list(constraint_types); del constraint_types[i]
        self.lp = InteractiveLPProblem(A, b, c, x,
                                       constraint_types, variable_types,
                                       problem_type, ring, objective_constant_term=d)

    cpdef add_linear_constraint(self, coefficients, lower_bound, upper_bound, name=None):
        """
        Add a linear constraint.
        INPUT:
        - ``coefficients`` -- an iterable of pairs ``(i, v)``. In each
          pair, ``i`` is a variable index (integer) and ``v`` is a
          value (element of :meth:`base_ring`).
        - ``lower_bound`` -- element of :meth:`base_ring` or
          ``None``. The lower bound.
        - ``upper_bound`` -- element of :meth:`base_ring` or
          ``None``. The upper bound.
        - ``name`` -- string or ``None``. Optional name for this row.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.add_variables(5)
            4
            sage: p.add_linear_constraint( zip(range(5), range(5)), 2, 2)
            sage: p.row(0)
            ([1, 2, 3, 4], [1, 2, 3, 4])
            sage: p.row_bounds(0)
            (2, 2)
            sage: p.add_linear_constraint( zip(range(5), range(5)), 1, 1, name='foo')
            sage: p.row_name(1)
            'foo'
        """
        A, b, c, x, constraint_types, variable_types, problem_type, ring, d = self._AbcxCVPRd()
        if lower_bound is None:
           if upper_bound is None:
               raise ValueError("At least one of lower_bound and upper_bound must be provided")
           else:
               constraint_types = constraint_types + ("<=",)
               b = tuple(b) + (upper_bound,)
        else:
            if upper_bound is None:
                constraint_types = constraint_types + (">=",)
                b = tuple(b) + (lower_bound,)
            elif lower_bound == upper_bound:
                constraint_types = constraint_types + ("==",)
                b = tuple(b) + (lower_bound,)
            else:
                raise NotImplementedError("Ranged constraints are not supported")

        row = vector(ring, self.ncols())
        for (i, v) in coefficients:
            row[i] = v
        A = A.stack(row)

        self.row_names.append(name)

        self.lp = InteractiveLPProblem(A, b, c, x,
                                       constraint_types, variable_types,
                                       problem_type, ring, objective_constant_term=d)


    cpdef add_col(self, indices, coeffs):
        """
        Add a column.
        INPUT:
        - ``indices`` (list of integers) -- this list contains the
          indices of the constraints in which the variable's
          coefficient is nonzero
        - ``coeffs`` (list of real values) -- associates a coefficient
          to the variable in each of the constraints in which it
          appears. Namely, the i-th entry of ``coeffs`` corresponds to
          the coefficient of the variable in the constraint
          represented by the i-th entry in ``indices``.
        .. NOTE::
            ``indices`` and ``coeffs`` are expected to be of the same
            length.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.ncols()
            0
            sage: p.nrows()
            0
            sage: p.add_linear_constraints(5, 0, None)
            sage: p.add_col(list(range(5)), list(range(5)))
            sage: p.nrows()
            5
        """
        self.add_variable(coefficients=zip(indices, coeffs))

    cpdef int solve(self) except -1:
        """
        Solve the problem.
        .. NOTE::
            This method raises ``MIPSolverException`` exceptions when
            the solution can not be computed for any reason (none
            exists, or the LP solver was not able to find it, etc...)
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.add_linear_constraints(5, 0, None)
            sage: p.add_col(list(range(5)), list(range(5)))
            sage: p.solve()
            0
            sage: p.objective_coefficient(0,1)
            sage: p.solve()
            Traceback (most recent call last):
            ...
            MIPSolverException: ...
        """
        ## FIXME: standard_form should allow to pass slack names (which we would take from row_names).
        ## FIXME: Perhaps also pass the problem name as objective name
        lp_std_form, transformation = self.lp.standard_form(transformation=True)
        self.lp_std_form, self.std_form_transformation = lp_std_form, transformation
        output = lp_std_form.run_revised_simplex_method()
        ## FIXME: Display output as a side effect if verbosity is high enough
        d = self.final_dictionary = lp_std_form.final_revised_dictionary()
        if d.is_optimal():
            if lp_std_form.auxiliary_variable() in d.basic_variables():
                raise MIPSolverException("InteractiveLP: Problem has no feasible solution")
            else:
                return 0
        else:
            raise MIPSolverException("InteractiveLP: Problem is unbounded")

    cpdef get_objective_value(self):
        """
        Return the value of the objective function.
        .. NOTE::
           Behavior is undefined unless ``solve`` has been called before.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.add_variables(2)
            1
            sage: p.add_linear_constraint([(0,1), (1,2)], None, 3)
            sage: p.set_objective([2, 5])
            sage: p.solve()
            0
            sage: p.get_objective_value()
            15/2
            sage: p.get_variable_value(0)
            0
            sage: p.get_variable_value(1)
            3/2
        """
        d = self.final_dictionary
        v = d.objective_value()
        if self.lp_std_form.is_negative():
            v = - v
        return v

    cpdef get_variable_value(self, int variable):
        """
        Return the value of a variable given by the solver.
        .. NOTE::
           Behavior is undefined unless ``solve`` has been called before.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.add_variables(2)
            1
            sage: p.add_linear_constraint([(0,1), (1, 2)], None, 3)
            sage: p.set_objective([2, 5])
            sage: p.solve()
            0
            sage: p.get_objective_value()
            15/2
            sage: p.get_variable_value(0)
            0
            sage: p.get_variable_value(1)
            3/2
        """
        solution = self.std_form_transformation(self.final_dictionary.basic_solution())
        return solution[variable]

    cpdef int ncols(self):
        """
        Return the number of columns/variables.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.ncols()
            0
            sage: p.add_variables(2)
            1
            sage: p.ncols()
            2
        """
        return self.lp.n_variables()

    cpdef int nrows(self):
        """
        Return the number of rows/constraints.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.nrows()
            0
            sage: p.add_linear_constraints(2, 0, None)
            sage: p.nrows()
            2
        """
        return self.lp.n_constraints()

    cpdef bint is_maximization(self):
        """
        Test whether the problem is a maximization
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.is_maximization()
            True
            sage: p.set_sense(-1)
            sage: p.is_maximization()
            False
        """
        return self.lp.problem_type() == "max"

    cpdef problem_name(self, name=None):
        """
        Return or define the problem's name
        INPUT:
        - ``name`` (``str``) -- the problem's name. When set to
          ``None`` (default), the method returns the problem's name.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.problem_name("There_once_was_a_french_fry")
            sage: print(p.problem_name())
            There_once_was_a_french_fry
        """
        if name is None:
            if self.prob_name is not None:
                return self.prob_name
            else:
                return ""
        else:
            self.prob_name = str(name)

    cpdef row(self, int i):
        """
        Return a row
        INPUT:
        - ``index`` (integer) -- the constraint's id.
        OUTPUT:
        A pair ``(indices, coeffs)`` where ``indices`` lists the
        entries whose coefficient is nonzero, and to which ``coeffs``
        associates their coefficient on the model of the
        ``add_linear_constraint`` method.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.add_variables(5)
            4
            sage: p.add_linear_constraint(zip(range(5), range(5)), 0, None)
            sage: p.row(0)
            ([1, 2, 3, 4], [1, 2, 3, 4])
        """
        A, b, c, x = self.lp.Abcx()
        indices = []
        coeffs = []
        for j in range(self.ncols()):
            if A[i][j] != 0:
                indices.append(j)
                coeffs.append(A[i][j])
        return (indices, coeffs)

    cpdef row_bounds(self, int index):
        """
        Return the bounds of a specific constraint.
        INPUT:
        - ``index`` (integer) -- the constraint's id.
        OUTPUT:
        A pair ``(lower_bound, upper_bound)``. Each of them can be set
        to ``None`` if the constraint is not bounded in the
        corresponding direction, and is a real value otherwise.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.add_variables(5)
            4
            sage: p.add_linear_constraint(zip(range(5), range(5)), 2, 2)
            sage: p.row_bounds(0)
            (2, 2)
        """
        A, b, c, x = self.lp.Abcx()
        constraint_types = self.lp.constraint_types()
        if constraint_types[index] == '>=':
            return (b[index], None)
        elif constraint_types[index] == '<=':
            return (None, b[index])
        elif constraint_types[index] == '==':
            return (b[index], b[index])
        else:
            raise ValueError("Bad constraint_type")

    cpdef col_bounds(self, int index):
        """
        Return the bounds of a specific variable.
        INPUT:
        - ``index`` (integer) -- the variable's id.
        OUTPUT:
        A pair ``(lower_bound, upper_bound)``. Each of them can be set
        to ``None`` if the variable is not bounded in the
        corresponding direction, and is a real value otherwise.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.add_variable(lower_bound=None)
            0
            sage: p.col_bounds(0)
            (None, None)
            sage: p.variable_lower_bound(0, 0)
            sage: p.col_bounds(0)
            (0, None)
        """
        t = self.lp.variable_types()[index]
        if t == ">=":
            return (0, None)
        elif t == "<=":
            return (None, 0)
        elif t == "":
            return (None, None)
        else:
            raise ValueError("Bad _variable_types")

    cpdef bint is_variable_binary(self, int index):
        """
        Test whether the given variable is of binary type.
        INPUT:
        - ``index`` (integer) -- the variable's id
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.ncols()
            0
            sage: p.add_variable()
            0
            sage: p.is_variable_binary(0)
            False
        """
        return False

    cpdef bint is_variable_integer(self, int index):
        """
        Test whether the given variable is of integer type.
        INPUT:
        - ``index`` (integer) -- the variable's id
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.ncols()
            0
            sage: p.add_variable()
            0
            sage: p.is_variable_integer(0)
            False
        """
        return False

    cpdef bint is_variable_continuous(self, int index):
        """
        Test whether the given variable is of continuous/real type.
        INPUT:
        - ``index`` (integer) -- the variable's id
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.ncols()
            0
            sage: p.add_variable()
            0
            sage: p.is_variable_continuous(0)
            True
        """
        return True

    cpdef row_name(self, int index):
        """
        Return the ``index`` th row name
        INPUT:
        - ``index`` (integer) -- the row's id
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.add_linear_constraints(1, 2, None, names=['Empty constraint 1'])
            sage: p.row_name(0)
            'Empty constraint 1'
        """
        return self.row_names[index]

    cpdef col_name(self, int index):
        """
        Return the ``index``-th column name
        INPUT:
        - ``index`` (integer) -- the column id
        - ``name`` (``char *``) -- its name. When set to ``NULL``
          (default), the method returns the current name.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.add_variable(name="I_am_a_variable")
            0
            sage: p.col_name(0)
            'I_am_a_variable'
        """
        return str(self.lp.decision_variables()[index])

    cpdef variable_upper_bound(self, int index, value = False):
        """
        Return or define the upper bound on a variable
        INPUT:
        - ``index`` (integer) -- the variable's id
        - ``value`` -- real value, or ``None`` to mean that the
          variable has not upper bound. When set to ``None``
          (default), the method returns the current value.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.add_variable(lower_bound=None)
            0
            sage: p.col_bounds(0)
            (None, None)
            sage: p.variable_upper_bound(0) is None
            True
            sage: p.variable_upper_bound(0, 0)
            sage: p.col_bounds(0)
            (None, 0)
            sage: p.variable_upper_bound(0)
            0
            sage: p.variable_upper_bound(0, None)
            sage: p.variable_upper_bound(0) is None
            True
        """
        bounds = self.col_bounds(index)
        if value is False:
            return bounds[1]
        else:
            if value != bounds[1]:
                bounds = (bounds[0], value)
                A, b, c, x, constraint_types, variable_types, problem_type, ring, d = self._AbcxCVPRd()
                variable_types = list(variable_types)
                variable_types[index] = self._variable_type_from_bounds(*bounds)
                self.lp = InteractiveLPProblem(A, b, c, x,
                                               constraint_types, variable_types,
                                               problem_type, ring, objective_constant_term=d)

    cpdef variable_lower_bound(self, int index, value = False):
        """
        Return or define the lower bound on a variable
        INPUT:
        - ``index`` (integer) -- the variable's id
        - ``value`` -- real value, or ``None`` to mean that the
          variable has no lower bound. When set to ``None``
          (default), the method returns the current value.
        EXAMPLES::
            sage: from sage.numerical.backends.generic_backend import get_solver
            sage: p = get_solver(solver = "InteractiveLP")
            sage: p.add_variable(lower_bound=None)
            0
            sage: p.col_bounds(0)
            (None, None)
            sage: p.variable_lower_bound(0) is None
            True
            sage: p.variable_lower_bound(0, 0)
            sage: p.col_bounds(0)
            (0, None)
            sage: p.variable_lower_bound(0)
            0
            sage: p.variable_lower_bound(0, None)
            sage: p.variable_lower_bound(0) is None
            True
        """
        bounds = self.col_bounds(index)
        if value is False:
            return bounds[0]
        else:
            if value != bounds[0]:
                bounds = (value, bounds[1])
                A, b, c, x, constraint_types, variable_types, problem_type, ring, d = self._AbcxCVPRd()
                variable_types = list(variable_types)
                variable_types[index] = self._variable_type_from_bounds(*bounds)
                self.lp = InteractiveLPProblem(A, b, c, x,
                                               constraint_types, variable_types,
                                               problem_type, ring, objective_constant_term=d)

    cpdef bint is_variable_basic(self, int index):
        """
        Test whether the given variable is basic.
        This assumes that the problem has been solved with the simplex method
        and a basis is available.  Otherwise an exception will be raised.
        INPUT:
        - ``index`` (integer) -- the variable's id
        EXAMPLES::
            sage: p = MixedIntegerLinearProgram(maximization=True,\
                                                solver="InteractiveLP")
            sage: x = p.new_variable(nonnegative=True)
            sage: p.add_constraint(-x[0] + x[1] <= 2)
            sage: p.add_constraint(8 * x[0] + 2 * x[1] <= 17)
            sage: p.set_objective(11/2 * x[0] - 3 * x[1])
            sage: b = p.get_backend()
            sage: # Backend-specific commands to instruct solver to use simplex method here
            sage: b.solve()
            0
            sage: b.is_variable_basic(0)
            True
            sage: b.is_variable_basic(1)
            False
        """
        return self.lp_std_form.decision_variables()[index] in self.final_dictionary.basic_variables()

    cpdef bint is_variable_nonbasic_at_lower_bound(self, int index):
        """
        Test whether the given variable is nonbasic at lower bound.
        This assumes that the problem has been solved with the simplex method
        and a basis is available.  Otherwise an exception will be raised.
        INPUT:
        - ``index`` (integer) -- the variable's id
        EXAMPLES::
            sage: p = MixedIntegerLinearProgram(maximization=True,\
                                                solver="InteractiveLP")
            sage: x = p.new_variable(nonnegative=True)
            sage: p.add_constraint(-x[0] + x[1] <= 2)
            sage: p.add_constraint(8 * x[0] + 2 * x[1] <= 17)
            sage: p.set_objective(11/2 * x[0] - 3 * x[1])
            sage: b = p.get_backend()
            sage: # Backend-specific commands to instruct solver to use simplex method here
            sage: b.solve()
            0
            sage: b.is_variable_nonbasic_at_lower_bound(0)
            False
            sage: b.is_variable_nonbasic_at_lower_bound(1)
            True
        """
        return self.lp_std_form.decision_variables()[index] in self.final_dictionary.nonbasic_variables()

    cpdef bint is_slack_variable_basic(self, int index):
        """
        Test whether the slack variable of the given row is basic.
        This assumes that the problem has been solved with the simplex method
        and a basis is available.  Otherwise an exception will be raised.
        INPUT:
        - ``index`` (integer) -- the variable's id
        EXAMPLES::
            sage: p = MixedIntegerLinearProgram(maximization=True,\
                                                solver="InteractiveLP")
            sage: x = p.new_variable(nonnegative=True)
            sage: p.add_constraint(-x[0] + x[1] <= 2)
            sage: p.add_constraint(8 * x[0] + 2 * x[1] <= 17)
            sage: p.set_objective(11/2 * x[0] - 3 * x[1])
            sage: b = p.get_backend()
            sage: # Backend-specific commands to instruct solver to use simplex method here
            sage: b.solve()
            0
            sage: b.is_slack_variable_basic(0)
            True
            sage: b.is_slack_variable_basic(1)
            False
        """
        return self.lp_std_form.slack_variables()[index] in self.final_dictionary.basic_variables()

    cpdef bint is_slack_variable_nonbasic_at_lower_bound(self, int index):
        """
        Test whether the given variable is nonbasic at lower bound.
        This assumes that the problem has been solved with the simplex method
        and a basis is available.  Otherwise an exception will be raised.
        INPUT:
        - ``index`` (integer) -- the variable's id
        EXAMPLES::
            sage: p = MixedIntegerLinearProgram(maximization=True,\
                                                solver="InteractiveLP")
            sage: x = p.new_variable(nonnegative=True)
            sage: p.add_constraint(-x[0] + x[1] <= 2)
            sage: p.add_constraint(8 * x[0] + 2 * x[1] <= 17)
            sage: p.set_objective(11/2 * x[0] - 3 * x[1])
            sage: b = p.get_backend()
            sage: # Backend-specific commands to instruct solver to use simplex method here
            sage: b.solve()
            0
            sage: b.is_slack_variable_nonbasic_at_lower_bound(0)
            False
            sage: b.is_slack_variable_nonbasic_at_lower_bound(1)
            True
        """
        return self.lp_std_form.slack_variables()[index] in self.final_dictionary.nonbasic_variables()

    cpdef dictionary(self):
        # Proposed addition to the general interface,
        # which would for other solvers return backend dictionaries (#18804)
        """
        Return a dictionary representing the current basis.
        EXAMPLES::
            sage: p = MixedIntegerLinearProgram(maximization=True,\
                                                solver="InteractiveLP")
            sage: x = p.new_variable(nonnegative=True)
            sage: p.add_constraint(-x[0] + x[1] <= 2)
            sage: p.add_constraint(8 * x[0] + 2 * x[1] <= 17)
            sage: p.set_objective(11/2 * x[0] - 3 * x[1])
            sage: b = p.get_backend()
            sage: # Backend-specific commands to instruct solver to use simplex method here
            sage: b.solve()
            0
            sage: d = b.dictionary(); d
            LP problem dictionary ...
            sage: set(d.basic_variables())
            {x1, x3}
            sage: d.basic_solution()
            (17/8, 0)
        TESTS:
        Compare with a dictionary obtained in another way::
            sage: lp, basis = p.interactive_lp_problem()
            sage: lp.dictionary(*basis).basic_solution()
            (17/8, 0)
        """
        return self.final_dictionary

    cpdef interactive_lp_problem(self):

        """
        Return the :class:`InteractiveLPProblem` object associated with this backend.
        EXAMPLES::
            sage: p = MixedIntegerLinearProgram(maximization=True,\
                                                solver="InteractiveLP")
            sage: x = p.new_variable(nonnegative=True)
            sage: p.add_constraint(-x[0] + x[1] <= 2)
            sage: p.add_constraint(8 * x[0] + 2 * x[1] <= 17)
            sage: p.set_objective(11/2 * x[0] - 3 * x[1])
            sage: b = p.get_backend()
            sage: b.interactive_lp_problem()
            LP problem ...
        """
        return self.lp

""" solve_exact? """

    def solve_exact(self):
        ncol = b.ncols()
        nrow = b.nrows()
        A = matrix(QQ, ncol + nrow, ncol + nrow, sparse = True)
        for i in range(nrow):
            r = b.row(i)
            for (j, c) in zip(r[0], r[1]):
                A[i, j] = QQ(c)
            A[i, ncol + i] = -1
        n = nrow
        Y = zero_vector(QQ, ncol + nrow)
        for i in range(ncol):
            status =  b.get_col_stat(i)
            if status > 1:
                A[n, i] = 1
                if status == 2:
                    Y[n] = b.col_bounds(i)[0]
                else:
                    Y[n] = b.col_bounds(i)[1]
                n += 1

         for i in range(nrow):
            status =  b.get_row_stat(i)
            if status > 1:
                A[n, ncol + i] = 1
                if status == 2:
                    Y[n] = b.row_bounds(i)[0]
                else:
                    Y[n] = b.row_bounds(i)[1]
                n += 1

        #Polyhedral construction and computation

        eqnlist = []
        alist = [ele for ele in A]
    
        for i in range(len(Y)):
            eqnlist.append([-Y[i]])

        for j in range(ncol+nrow):
            for k in range(ncol+nrow):
                eqnlist[j].append(alist[j][k])

        poly = Polyhedron(eqns=eqnlist)

        X = poly.vertices_list()
        lenx = len(X)

        for s in range(lenx):
            X[s] = tuple(X[s])
        
        tupleX = tuple(X)

        for l in range(lenx):
            return tupleX[l][0:ncol]


""" functions to wrap from InteractiveLPProblem into InteractiveLP Backend """

    def __eq__(self, other):
        r"""
        Check if two LP problems are equal.
        INPUT:
        - ``other`` -- anything
        OUTPUT:
        - ``True`` if ``other`` is an :class:`InteractiveLPProblem` with all details the
          same as ``self``, ``False`` otherwise.
        TESTS::
            sage: A = ([1, 1], [3, 1])
            sage: b = (1000, 1500)
            sage: c = (10, 5)
            sage: P = InteractiveLPProblem(A, b, c, ["C", "B"], variable_type=">=")
            sage: P2 = InteractiveLPProblem(A, b, c, ["C", "B"], variable_type=">=")
            sage: P == P2
            True
            sage: P3 = InteractiveLPProblem(A, c, b, ["C", "B"], variable_type=">=")
            sage: P == P3
            False
        """
        return (isinstance(other, InteractiveLPProblem) and
                self.Abcx() == other.Abcx() and
                self._constant_term == other._constant_term and
                self._problem_type == other._problem_type and
                self._is_negative == other._is_negative and
                self._constraint_types == other._constraint_types and
                self._variable_types == other._variable_types)


def add_constraint(self, coefficients, constant_term, constraint_type="<="):
        r"""
        Return a new LP problem by adding a constraint to``self``.
        INPUT:
        - ``coefficients`` -- coefficients of the new constraint
        - ``constant_term`` -- a constant term of the new constraint
        - ``constraint_type`` -- (default: ``"<="``) a string indicating
          the constraint type of the new constraint
        OUTPUT:
        - an :class:`LP problem <InteractiveLPProblem>`
        EXAMPLES::
            sage: A = ([1, 1], [3, 1])
            sage: b = (1000, 1500)
            sage: c = (10, 5)
            sage: P = InteractiveLPProblem(A, b, c)
            sage: P1 = P.add_constraint(([2, 4]), 2000, "<=")
            sage: P1.Abcx()
            (
            [1 1]
            [3 1]
            [2 4], (1000, 1500, 2000), (10, 5), (x1, x2)
            )
            sage: P1.constraint_types()
            ('<=', '<=', '<=')
            sage: P.Abcx()
            (
            [1 1]
            [3 1], (1000, 1500), (10, 5), (x1, x2)
            )
            sage: P.constraint_types()
            ('<=', '<=')
            sage: P2 = P.add_constraint(([2, 4, 6]), 2000, "<=")
            Traceback (most recent call last):
            ...
            TypeError: number of columns must be the same, not 2 and 3
            sage: P3 = P.add_constraint(([2, 4]), 2000, "<")
            Traceback (most recent call last):
            ...
            ValueError: unknown constraint type
        """
        A, b, c, x = self.Abcx()
        A = A.stack(matrix(coefficients))
        b = tuple(b) + (constant_term,)
        if self._is_negative:
            problem_type = "-" + self.problem_type()
        else:
            problem_type = self.problem_type()
        return InteractiveLPProblem(A, b, c, x,
                    constraint_type=self._constraint_types + (constraint_type,),
                    variable_type=self.variable_types(),
                    problem_type=problem_type,
                    base_ring=self.base_ring(),
                    is_primal=self._is_primal,
                    objective_constant_term=self.objective_constant_term())


    def constant_terms(self):
        r"""
        Return constant terms of constraints of ``self``, i.e. `b`.
        OUTPUT:
        - a vector
        EXAMPLES::
            sage: A = ([1, 1], [3, 1])
            sage: b = (1000, 1500)
            sage: c = (10, 5)
            sage: P = InteractiveLPProblem(A, b, c, ["C", "B"], variable_type=">=")
            sage: P.constant_terms()
            (1000, 1500)
            sage: P.b()
            (1000, 1500)
        """
        return self._Abcx[1]

def constraint_types(self):
        r"""
        Return a tuple listing the constraint types of all rows.
        OUTPUT:
        - a tuple of strings
        EXAMPLES::
            sage: A = ([1, 1], [3, 1])
            sage: b = (1000, 1500)
            sage: c = (10, 5)
            sage: P = InteractiveLPProblem(A, b, c, ["C", "B"], variable_type=">=", constraint_type=["<=", "=="])
            sage: P.constraint_types()
            ('<=', '==')
        """
        return self._constraint_types

def decision_variables(self):
        r"""
        Return decision variables of ``self``, i.e. `x`.
        OUTPUT:
        - a vector
        EXAMPLES::
            sage: A = ([1, 1], [3, 1])
            sage: b = (1000, 1500)
            sage: c = (10, 5)
            sage: P = InteractiveLPProblem(A, b, c, ["C", "B"], variable_type=">=")
            sage: P.decision_variables()
            (C, B)
            sage: P.x()
            (C, B)
        """
        return self._Abcx[3]

def dual(self, y=None):
        r"""
        Construct the dual LP problem for ``self``.
        INPUT:
        - ``y`` -- (default: depends on :func:`style`)
          a vector of dual decision variables or a string giving the base name
        OUTPUT:
        - an :class:`InteractiveLPProblem`
        EXAMPLES::
            sage: A = ([1, 1], [3, 1])
            sage: b = (1000, 1500)
            sage: c = (10, 5)
            sage: P = InteractiveLPProblem(A, b, c, ["C", "B"], variable_type=">=")
            sage: DP = P.dual()
            sage: DP.b() == P.c()
            True
            sage: DP.dual(["C", "B"]) == P
            True
        TESTS::
            sage: DP.standard_form().objective_name()
            -z
            sage: sage.numerical.interactive_simplex_method.style("Vanderbei")
            'Vanderbei'
            sage: P.dual().standard_form().objective_name()
            -xi
            sage: sage.numerical.interactive_simplex_method.style("UAlberta")
            'UAlberta'
            sage: P.dual().standard_form().objective_name()
            -z
        """
        A, c, b, x = self.Abcx()
        A = A.transpose()
        if y is None:
            y = default_variable_name(
                "dual decision" if self.is_primal() else "primal decision")
        problem_type = "min" if self._problem_type == "max" else "max"
        constraint_type = []
        for vt in self._variable_types:
            if (vt == ">=" and problem_type == "min" or
                vt == "<=" and problem_type == "max"):
                constraint_type.append(">=")
            elif (vt == "<=" and problem_type == "min" or
                vt == ">=" and problem_type == "max"):
                constraint_type.append("<=")
            else:
                constraint_type.append("==")
        variable_type = []
        for ct in self._constraint_types:
            if (ct == ">=" and problem_type == "min" or
                ct == "<=" and problem_type == "max"):
                variable_type.append("<=")
            elif (ct == "<=" and problem_type == "min" or
                ct == ">=" and problem_type == "max"):
                variable_type.append(">=")
            else:
                variable_type.append("")
        if self._is_negative:
            problem_type = "-" + problem_type
        return InteractiveLPProblem(A, b, c, y,
            constraint_type, variable_type, problem_type,
            is_primal=not self.is_primal(),
            objective_constant_term=self._constant_term)

def is_negative(self):
        r"""
        Return `True` when the problem is of type ``"-max"`` or ``"-min"``.
        EXAMPLES::
            sage: A = ([1, 1], [3, 1])
            sage: b = (1000, 1500)
            sage: c = (10, 5)
            sage: P = InteractiveLPProblem(A, b, c, ["C", "B"], variable_type=">=")
            sage: P.is_negative()
            False
            sage: P = InteractiveLPProblem(A, b, c, ["C", "B"], variable_type=">=", problem_type="-min")
            sage: P.is_negative()
            True
        """
        return self._is_negative

def is_primal(self):
        r"""
        Check if we consider this problem to be primal or dual.
        This distinction affects only some automatically chosen variable names.
        OUTPUT:
        - boolean
        EXAMPLES::
            sage: A = ([1, 1], [3, 1])
            sage: b = (1000, 1500)
            sage: c = (10, 5)
            sage: P = InteractiveLPProblem(A, b, c, ["C", "B"], variable_type=">=")
            sage: P.is_primal()
            True
            sage: P.dual().is_primal()
            False
        """
        return self._is_primal

def is_optimal(self, *x):
        r"""
        Check if given solution is feasible.
        INPUT:
        - anything that can be interpreted as a valid solution for
          this problem, i.e. a sequence of values for all decision variables
        OUTPUT:
        - ``True`` is the given solution is optimal, ``False`` otherwise
        EXAMPLES::
            sage: A = ([1, 1], [3, 1])
            sage: b = (1000, 1500)
            sage: c = (15, 5)
            sage: P = InteractiveLPProblem(A, b, c, variable_type=">=")
            sage: P.is_optimal(100, 200)
            False
            sage: P.is_optimal(500, 0)
            True
            sage: P.is_optimal(499, 3)
            True
            sage: P.is_optimal(501, -3)
            False
        """
        return (self.optimal_value() == self.objective_value(*x) and
                self.is_feasible(*x))

def optimal_solution(self):
        r"""
        Return **an** optimal solution of ``self``.
        OUTPUT:
        - a vector or ``None`` if there are no optimal solutions
        EXAMPLES::
            sage: A = ([1, 1], [3, 1])
            sage: b = (1000, 1500)
            sage: c = (10, 5)
            sage: P = InteractiveLPProblem(A, b, c, ["C", "B"], variable_type=">=")
            sage: P.optimal_solution()
            (250, 750)
        """
        return self._solve()[0]

 def plot(self, *args, **kwds):
        r"""
        Return a plot for solving ``self`` graphically.
        INPUT:
        - ``xmin``, ``xmax``, ``ymin``, ``ymax`` -- bounds for the axes, if
          not given, an attempt will be made to pick reasonable values
        - ``alpha`` -- (default: 0.2) determines how opaque are shadows
        OUTPUT:
        - a plot
        This only works for problems with two decision variables. On the plot
        the black arrow indicates the direction of growth of the objective. The
        lines perpendicular to it are level curves of the objective. If there
        are optimal solutions, the arrow originates in one of them and the
        corresponding level curve is solid: all points of the feasible set
        on it are optimal solutions. Otherwise the arrow is placed in the
        center. If the problem is infeasible or the objective is zero, a plot
        of the feasible set only is returned.
        EXAMPLES::
            sage: A = ([1, 1], [3, 1])
            sage: b = (1000, 1500)
            sage: c = (10, 5)
            sage: P = InteractiveLPProblem(A, b, c, ["C", "B"], variable_type=">=")
            sage: p = P.plot()
            sage: p.show()
        In this case the plot works better with the following axes ranges::
            sage: p = P.plot(0, 1000, 0, 1500)
            sage: p.show()
        TESTS:
        We check that zero objective can be dealt with::
            sage: InteractiveLPProblem(A, b, (0, 0), ["C", "B"], variable_type=">=").plot()
            Graphics object consisting of 8 graphics primitives
        """
        FP = self.plot_feasible_set(*args, **kwds)
        c = self.c().n().change_ring(QQ)
        if c.is_zero():
            return FP
        xmin = FP.xmin()
        xmax = FP.xmax()
        ymin = FP.ymin()
        ymax = FP.ymax()
        xmin, xmax, ymin, ymax = map(QQ, [xmin, xmax, ymin, ymax])
        start = self.optimal_solution()
        start = vector(QQ, start.n() if start is not None
                            else [xmin + (xmax-xmin)/2, ymin + (ymax-ymin)/2])
        length = min(xmax - xmin, ymax - ymin) / 5
        end = start + (c * length / c.norm()).n().change_ring(QQ)
        result = FP + point(start, color="black", size=50, zorder=10)
        result += arrow(start, end, color="black", zorder=10)
        ieqs = [(xmax, -1, 0), (- xmin, 1, 0),
                (ymax, 0, -1), (- ymin, 0, 1)]
        box = Polyhedron(ieqs=ieqs)
        d = vector([c[1], -c[0]])
        for i in range(-10, 11):
            level = Polyhedron(vertices=[start + i*(end-start)], lines=[d])
            level = box.intersection(level)
            if level.vertices():
                if i == 0 and self.is_bounded():
                    result += line(level.vertices(), color="black",
                                   thickness=2)
                else:
                    result += line(level.vertices(), color="black",
                                   linestyle="--")
        result.set_axes_range(xmin, xmax, ymin, ymax)
        result.axes_labels(FP.axes_labels())    #FIXME: should be preserved!
        return result


def plot_feasible_set(self, xmin=None, xmax=None, ymin=None, ymax=None,
                          alpha=0.2):
        r"""
        Return a plot of the feasible set of ``self``.
        INPUT:
        - ``xmin``, ``xmax``, ``ymin``, ``ymax`` -- bounds for the axes, if
          not given, an attempt will be made to pick reasonable values
        - ``alpha`` -- (default: 0.2) determines how opaque are shadows
        OUTPUT:
        - a plot
        This only works for a problem with two decision variables. The plot
        shows boundaries of constraints with a shadow on one side for
        inequalities. If the :meth:`feasible_set` is not empty and at least
        part of it is in the given boundaries, it will be shaded gray and `F`
        will be placed in its middle.
        EXAMPLES::
            sage: A = ([1, 1], [3, 1])
            sage: b = (1000, 1500)
            sage: c = (10, 5)
            sage: P = InteractiveLPProblem(A, b, c, ["C", "B"], variable_type=">=")
            sage: p = P.plot_feasible_set()
            sage: p.show()
        In this case the plot works better with the following axes ranges::
            sage: p = P.plot_feasible_set(0, 1000, 0, 1500)
            sage: p.show()
        """
        if self.n() != 2:
            raise ValueError("only problems with 2 variables can be plotted")
        A, b, c, x = self.Abcx()
        if self.base_ring() is not QQ:
            # Either we use QQ or crash
            A = A.n().change_ring(QQ)
            b = b.n().change_ring(QQ)
        F = self.feasible_set()
        if ymax is None:
            ymax = max([abs(bb) for bb in b] + [v[1] for v in F.vertices()])
        if ymin is None:
            ymin = min([-ymax/4.0] + [v[1] for v in F.vertices()])
        if xmax is None:
            xmax = max([1.5*ymax] + [v[0] for v in F.vertices()])
        if xmin is None:
            xmin = min([-xmax/4.0] + [v[0] for v in F.vertices()])
        xmin, xmax, ymin, ymax = map(QQ, [xmin, xmax, ymin, ymax])
        pad = max(xmax - xmin, ymax - ymin) / 20
        ieqs = [(xmax, -1, 0), (- xmin, 1, 0),
                (ymax, 0, -1), (- ymin, 0, 1)]
        box = Polyhedron(ieqs=ieqs)
        F = box.intersection(F)
        result = Graphics()
        colors = rainbow(self.m() + 2)
        for Ai, ri, bi, color in zip(A.rows(), self._constraint_types,
                                           b, colors[:-2]):
            border = box.intersection(Polyhedron(eqns=[[-bi] + list(Ai)]))
            vertices = border.vertices()
            if not vertices:
                continue
            label = r"${}$".format(_latex_product(Ai, x, " ", tail=[ri, bi]))
            result += line(vertices, color=color, legend_label=label)
            if ri == "<=":
                ieqs = [[bi] + list(-Ai), [-bi+pad*Ai.norm().n()] + list(Ai)]
            elif ri == ">=":
                ieqs = [[-bi] + list(Ai), [bi+pad*Ai.norm().n()] + list(-Ai)]
            else:
                continue
            ieqs = [ [QQ(_) for _ in ieq] for ieq in ieqs]
            halfplane = box.intersection(Polyhedron(ieqs=ieqs))
            result += halfplane.render_solid(alpha=alpha, color=color)
        # Same for variables, but no legend
        for ni, ri, color in zip((QQ**2).gens(), self._variable_types,
                                 colors[-2:]):
            border = box.intersection(Polyhedron(eqns=[[0] + list(ni)]))
            if not border.vertices():
                continue
            if ri == "<=":
                ieqs = [[0] + list(-ni), [pad] + list(ni)]
            elif ri == ">=":
                ieqs = [[0] + list(ni), [pad] + list(-ni)]
            else:
                continue
            ieqs = [ [QQ(_) for _ in ieq] for ieq in ieqs]
            halfplane = box.intersection(Polyhedron(ieqs=ieqs))
            result += halfplane.render_solid(alpha=alpha, color=color)
        if F.vertices():
            result += F.render_solid(alpha=alpha, color="gray")
            result += text("$F$", F.center(),
                           fontsize=20, color="black", zorder=5)
        result.set_axes_range(xmin, xmax, ymin, ymax)
        result.axes_labels(["${}$".format(latex(xi)) for xi in x])
        result.legend(True)
        result.set_legend_options(fancybox=True, handlelength=1.5, loc=1,
                                  shadow=True)
        result._extra_kwds["aspect_ratio"] = 1
        result.set_aspect_ratio(1)
        return result


def standard_form(self, transformation=False, **kwds):
        r"""
        Construct the LP problem in standard form equivalent to ``self``.
        INPUT:
        - ``transformation`` -- (default: ``False``) if ``True``, a map
          converting solutions of the problem in standard form to the original
          one will be returned as well
        - you can pass (as keywords only) ``slack_variables``,
          ``auxiliary_variable``,``objective_name`` to the constructor of
          :class:`InteractiveLPProblemStandardForm`
        OUTPUT:
        - an :class:`InteractiveLPProblemStandardForm` by itself or a tuple
          with variable transformation as the second component
        EXAMPLES::
            sage: A = ([1, 1], [3, 1])
            sage: b = (1000, 1500)
            sage: c = (10, 5)
            sage: P = InteractiveLPProblem(A, b, c, variable_type=">=")
            sage: DP = P.dual()
            sage: DPSF = DP.standard_form()
            sage: DPSF.b()
            (-10, -5)
            sage: DPSF.slack_variables()
            (y3, y4)
            sage: DPSF = DP.standard_form(slack_variables=["L", "F"])
            sage: DPSF.slack_variables()
            (L, F)
            sage: DPSF, f = DP.standard_form(True)
            sage: f
            Vector space morphism represented by the matrix:
            [1 0]
            [0 1]
            Domain: Vector space of dimension 2 over Rational Field
            Codomain: Vector space of dimension 2 over Rational Field
        A more complicated transformation map::
            sage: P = InteractiveLPProblem(A, b, c, variable_type=["<=", ""],
            ....:                          objective_constant_term=42)
            sage: PSF, f = P.standard_form(True)
            sage: f
            Vector space morphism represented by the matrix:
            [-1  0]
            [ 0  1]
            [ 0 -1]
            Domain: Vector space of dimension 3 over Rational Field
            Codomain: Vector space of dimension 2 over Rational Field
            sage: PSF.optimal_solution()
            (0, 1000, 0)
            sage: P.optimal_solution()
            (0, 1000)
            sage: P.is_optimal(PSF.optimal_solution())
            Traceback (most recent call last):
            ...
            TypeError: given input is not a solution for this problem
            sage: P.is_optimal(f(PSF.optimal_solution()))
            True
            sage: PSF.optimal_value()
            5042
            sage: P.optimal_value()
            5042
        TESTS:
        Above also works for the equivalent minimization problem::
            sage: c = (-10, -5)
            sage: P = InteractiveLPProblem(A, b, c, variable_type=["<=", ""],
            ....:                          objective_constant_term=-42,
            ....:                          problem_type="min")
            sage: PSF, f = P.standard_form(True)
            sage: PSF.optimal_solution()
            (0, 1000, 0)
            sage: P.optimal_solution()
            (0, 1000)
            sage: PSF.optimal_value()
            -5042
            sage: P.optimal_value()
            -5042
        """
        A, b, c, x = self.Abcx()
        f = identity_matrix(self.n()).columns()
        if not all(ct == "<=" for ct in self._constraint_types):
            newA = []
            newb = []
            for ct, Ai, bi in zip(self._constraint_types, A, b):
                if ct in ["<=", "=="]:
                    newA.append(Ai)
                    newb.append(bi)
                if ct in [">=", "=="]:
                    newA.append(-Ai)
                    newb.append(-bi)
            A = matrix(newA)
            b = vector(newb)
        if not all(vt == ">=" for vt in self._variable_types):
            newA = []
            newc = []
            newx = []
            newf = []
            for vt, Aj, cj, xj, fj in zip(
                                self._variable_types, A.columns(), c, x, f):
                xj = str(xj)
                if vt in [">=", ""]:
                    newA.append(Aj)
                    newc.append(cj)
                    newf.append(fj)
                if vt == ">=":
                    newx.append(xj)
                if vt == "":
                    newx.append(xj + "_p")
                if vt in ["<=", ""]:
                    newA.append(-Aj)
                    newc.append(-cj)
                    newx.append(xj + "_n")
                    newf.append(-fj)
            A = column_matrix(newA)
            c = vector(newc)
            x = newx
            f = newf

        objective_name = SR(kwds.get("objective_name", default_variable_name(
            "primal objective" if self.is_primal() else "dual objective")))
        is_negative = self._is_negative
        constant_term = self._constant_term
        if self._problem_type == "min":
            is_negative = not is_negative
            c = - c
            constant_term = - constant_term
            objective_name = - objective_name
        kwds["objective_name"] = objective_name
        kwds["problem_type"] = "-max" if is_negative else "max"
        kwds["is_primal"] = self.is_primal()
        kwds["objective_constant_term"] = constant_term
        P = InteractiveLPProblemStandardForm(A, b, c, x, **kwds)
        f = P.c().parent().hom(f, self.c().parent())
        return (P, f) if transformation else P


















