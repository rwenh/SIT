library(statinfer)

print_result <- function(name, result) {
  cat(sprintf(
    "%-20s statistic = %9.4f      p_value = %10.4g        reject_h0 = %s\n",
    name, result$statistic, result$p_value, result$reject_h0
  ))
}

sample_a <- c(10, 11, 12, 13, 14, 12.5, 11.5, 13.5, 10.5, 12.2)
print_result("one_sample_t_test", one_sample_t_test(sample_a, mu0 = 20.0))

sample_c1 <- c(1, 2, 3, 4, 5)
sample_c2 <- c(10, 11, 12, 13, 14)
print_result("two_sample_t_test", two_sample_t_test(sample_c1, sample_c2))

observed <- c(18, 22, 20, 20)
expected <- c(20.0, 20.0, 20.0, 20.0)
print_result("chi_square_test", chi_square_test(observed, expected))
