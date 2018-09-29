# ---------------------------------------------------------------------------- #
# Load packages                                                                #
# ---------------------------------------------------------------------------- #
libname := libname, "../ParametricMatrixTools":
with(RegularChains):
with(ConstructibleSetTools):
with(LinearAlgebra):
with(ParametricMatrixTools):

# ---------------------------------------------------------------------------- #
# Set Parameters                                                               #
# ---------------------------------------------------------------------------- #
num_iter := 100:    # Number of iterations for each combination of number of
                    # rows, number of columns and number of parameters
num_rep := 10:      # Number of times to run computation on fixed matrix,
                    # minimum time to execute of the num_rep iterations is
                    # recorded as the time
max_rows := 20:
max_cols := 20:
min_entry := -10:
max_entry := 10:
max_num_param := 5:

# ---------------------------------------------------------------------------- #
# Run timing                                                                   #
# ---------------------------------------------------------------------------- #

# Open CSV file
fd := fopen("results.csv", WRITE):

# Write header
fprintf(fd, "num_rows, num_cols, num_param, iteration, time_A, time_A_transpose\n"):

for num_rows from 2 to max_rows do
    for num_cols from num_rows+1 to max_cols do
        for num_param to max_num_param do
            printf("%dx%d matrix with %d parameters\n", num_rows, num_cols, num_param):

            A_rank_times := Array(1..num_iter):
            A_transpose_rank_times := Array(1..num_iter):
            A_num_params := Array(1..num_iter):

            for i to num_iter do

                param_row_rng := rand(2..num_rows):
                param_col_rng := rand(2..num_cols):

                A := RandomMatrix(num_rows, num_cols, generator=min_entry..max_entry):

                params := [seq(a[k], k = 1..num_param)]:

                for k to num_param do
                    row := param_row_rng():
                    col := param_col_rng():
                    A[row, col] := params[k]:
                end do:

                A_T := Transpose(A):

                R := PolynomialRing(params):

                rep_A_times := Array(1..num_rep):
                rep_A_transpose_times := Array(1..num_rep):
                for k to num_rep do
                    rep_A_times[k] := time(ComprehensiveRank(A, R)):
                    rep_A_transpose_times[k] := time(ComprehensiveRank(A_T, R)):
                end do:
                A_rank_times[i] := min(rep_A_times):
                A_transpose_rank_times[i] := min(rep_A_transpose_times):
            end do:

            # Save
            for i to num_iter do
                fprintf(fd, "%d, %d, %d, %d, %f, %f\n", num_rows, num_cols, num_param, i, A_rank_times[i], A_transpose_rank_times[i]):
            end do:
        end do:
    end do:
end do:

# Close CSV file
fclose(fd):
