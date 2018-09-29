with(RegularChains):

R := PolynomialRing([y, x, t]);
F := [(x-1)*(x-2), (x-1)*(t^2+y^2)+(x-2)*(y^2-t)];
RealTriangularize(F, R, output = record);
