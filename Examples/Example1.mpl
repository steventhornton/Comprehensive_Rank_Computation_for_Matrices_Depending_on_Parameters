# ---------------------------------------------------------------------------- #
# Source: Analyzing the set of Uncontrollable Second Order Generalized Linear  #
# Systems, M. Isabel Garcia-Planas, J. Clotet.                                 #
# ---------------------------------------------------------------------------- #
libname := libname, "../ParametricMatrixTools/";

with(ParametricMatrixTools);
with(RegularChains);
with(ConstructibleSetTools);
with(LinearAlgebra);

# Matrix to compute rank of
z3 := ZeroMatrix(3):
z1 := ZeroMatrix(3, 1):
E := Matrix([[1, 3, 1], [3, 1, 1], [0, 0, 0]]):
A1 := Matrix([[1, 1, 3], [1, 3, 1], [0, 0, 0]]):
A2 := Matrix([[lambda, 3*lambda, lambda], [3*lambda+mu, lambda+mu, lambda+3*mu], [0, 0, 0]]):
B := Matrix([[0], [0], [1]]):
A := Matrix([[-E, z3, z3, z3, B, z1, z1, z1, z1, z1], [-A1, -E, z3, z3, z1, B, z1, z1, z1, z1], [A2, A1, -E, z3, z1, z1, B, z1, z1, z1], [z3, A2, -A1, -E, z1, z1, z1, B, z1, z1], [z3, z3, A2, -A1, z1, z1, z1, z1, B, z1], [z3, z3, z3, A2, z1, z1, z1, z1, z1, B]]);

R := PolynomialRing([mu, lambda]):


# Consider the case when lambda <> 0.
cs := GeneralConstruct([], [lambda], R);
rank := ComprehensiveRank(A, cs, R);

# Matrix has rank 18 (full rank) for:
Display(rank[1], R);

# Matrix has rank 17 for:
Display(rank[2], R);


# Consider the case where lambda = 0.
rank := ComprehensiveRank(A, [lambda], [], R);

# Matrix has rank 16 for:
Display(rank[1], R);

# Matrix has rank 15 for:
Display(rank[2], R);


# Consider the case where mu > 0.
lrsas := RealTriangularize([], [], [mu], [], R);
rank := RealComprehensiveRank(A, lrsas, R);

# Matrix has rank 18 for:
Display(rank[1], R);

# Matrix has rank 17 for:
Display(rank[2], R);

# Matrix has rank 16 for:
Display(rank[3], R);


# Consider the cases where mu <= 1 and lambda^2 > 2
rank := RealComprehensiveRank(A, [], [1-mu], [lambda^2-2], [], R);

# Matrix has rank 18 (full rank) for:
Display(rank[1], R);

# Matrix has rank 17 for
Display(rank[2], R);
