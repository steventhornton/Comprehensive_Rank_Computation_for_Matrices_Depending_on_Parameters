from pathlib import Path

def get_file_contents(A_str, corp_num, iteration_num):

    return """with(RegularChains):
with(LinearAlgebra):
libname := libname, \"../../../ParametricMatrixTools\":
with(ParametricMatrixTools):

{}

vars := convert(indets(A), list):
if nops(vars) = 0 then
    vars := ['x']
end if:
R := PolynomialRing(vars):

t_real := time[real]():
t_cpu := time():
ComprehensiveRank(A, R):
t_real := time[real]() - t_real:
t_cpu := time() - t_cpu:

# Save to a file
fd := fopen(\"Results/Results_corp_{}_iteration_{}.csv\", WRITE):
fprintf(fd, \"corp_num, iteration_num, time_real, time_cpu\\n\"):
fprintf(fd, \"{}, {}, %f, %f\\n\", t_real, t_cpu):
fclose(fd):

quit:
""".format(A_str, corp_num, iteration_num, corp_num, iteration_num)


def get_maple_code(f):
    # Read only the second line
    lines = f.readlines()[1]

    # Select characters 22-(end-1)
    lines = lines[22:-2]

    lines = lines.replace("],", "],\n" + " "*12)

    # Prepend with "A := Matrix(
    # Append with "):"
    lines = "A := Matrix([" + lines + "]):"

    return lines

NUM_ITER = 50

# Iterate over all *.input files
for path in Path().glob('../../corpus-of-parametric-linear-systems/Axiom/*.input'):

    for j in range(1, NUM_ITER+1):

        # Get the file index
        i = str(path)[50:-6]

        fname = "scripts/test_corp_{}_iteration_{}.mpl".format(i, j)

        # Read file
        with open(str(path), 'r') as f:
            A_maple_code = get_maple_code(f)

            maple_code_str = get_file_contents(A_maple_code, i, j)

            # Save
            with open(fname, 'w') as fw:
                fw.writelines(maple_code_str)

# Write the bash file
with open('run_all.sh', 'w') as f:
    for j in range(1, NUM_ITER+1):
        for i in range(1, 540+1):
           f.write("timeout --kill-after=60s --signal=9 10m maple -q scripts/test_corp_{}_iteration_{}.mpl\n".format(i, j))
           f.write("ps aux | grep -i '/opt/maple2017/bin.X86_64_LINUX/mserver -kpipe 4 -I /opt/maple2017/lib/include -q scripts/test_corp_" + str(i) + "_iteration_" + str(j) + ".mpl --env-setup' | awk {'print $2'} | xargs kill -9\n")
