# ---------------------------------------------------------------------------- #
# Source: An explicit solution to the matrix equation AX - XF=BY. Zhou, B.,    #
# Duan, G.R.                                                                   #
# ---------------------------------------------------------------------------- #
libname := libname, "../ParametricMatrixTools/";

with(ParametricMatrixTools);
with(RegularChains);
with(ConstructibleSetTools);
with(LinearAlgebra);

# Matrix to compute rank of
A := Matrix([[-4*z[1, 1]-4*z[1, 2], -4*z[1, 2]-4*z[1, 3], 20*z[1, 3]+24*z[1, 1]+44*z[1, 2]], [-7*z[1, 1]-6*z[1, 2]+z[1, 3], -18*z[1, 2]-12*z[1, 3]-6*z[1, 1], 54*z[1, 3]+72*z[1, 1]+126*z[1, 2]], [-z[2, 1]+z[2, 3], -12*z[2, 2]-6*z[2, 1]-6*z[2, 3], 24*z[2, 3]+60*z[2, 2]+36*z[2, 1]]]);

R := PolynomialRing([z[1, 1], z[1, 2], z[1, 3], z[2, 1], z[2, 2], z[2, 3]]);

cs := GeneralConstruct([], [], R);

rank := ComprehensiveRank(A, cs, R);

# Matrix has rank 2 for:
Display(rank[1], R);

# Matrix has rank 1 for
Display(rank[2], R);

# Matrix has rank 0 for
Display(rank[3], R);
