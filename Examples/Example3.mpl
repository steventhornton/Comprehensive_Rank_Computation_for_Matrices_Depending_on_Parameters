# ---------------------------------------------------------------------------- #
# Source: Linear Parameter - Varying Controller Synthesis using Matrix         #
# Sum-of-Squares Relazations, Dietz, SG., Scherer, C.W., Huygen, W.            #
# ---------------------------------------------------------------------------- #
libname := libname, "../ParametricMatrixTools/";

with(ParametricMatrixTools);
with(RegularChains);
with(ConstructibleSetTools);
with(LinearAlgebra);

# Matrix to compute rank of
A := Matrix([[-1, 1, 1, 1, 1, 0, 1], [0, 0, 1, 0, 1, 0, 0], [0, 1/2, 0, 1/2, 0, 1, 0], [0, c*a, 0, a, 0, 0, 0], [0, 0, -c*a, 0, -a, 0, 1], [0, 0, 1, 0, 0, 0, 0], [1, 1, 0, 0, 0, 0, 0]]);

R := PolynomialRing([a, c]);

# Consider the case where 6/5 >= a >= 1/5, and c > 0
lrsas := RealTriangularize([], [a-1/5, 6/5-a], [c], [], R);
rank := RealComprehensiveRank(A, lrsas, R);

# Matrix has rank 7 for:
Display(rank[1], R);

# Matrix has rank 6 for:
Display(rank[2], R);
