with(RegularChains):

R := PolynomialRing([x, y, z]);
F := [5*y^6-15*y^5+15*y^4+2*x*z^2-5*y^3+5*x^2+5*z^2];
RealTriangularize(F, R, output = record);
