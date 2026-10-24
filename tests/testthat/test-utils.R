test_that("si_factorial computes n! iteratively", {
  expect_equal(si_factorial(0), 1)
  expect_equal(si_factorial(1), 1)
  expect_equal(si_factorial(5), 120)
  expect_equal(si_factorial(10), 3628800)
  expect_error(si_factorial(-1), "non-negative")
})

test_that("si_combinations computes C(n, k) exactly", {
  expect_equal(si_combinations(0, 0), 1)
  expect_equal(si_combinations(5, 2), 10)
  expect_equal(si_combinations(10, 0), 1)
  expect_equal(si_combinations(10, 3), 120)     # regression: %/% precedence
  expect_equal(si_combinations(10, 10), 1)
  expect_equal(si_combinations(20, 10), 184756)
  expect_error(si_combinations(5, 6), "0 <= k <= n")
  expect_error(si_combinations(5, -1), "0 <= k <= n")
})

test_that("si_mean computes the arithmetic mean", {
  expect_equal(si_mean(c(1, 2, 3, 4, 5)), 3)
  expect_equal(si_mean(c(2.5, 3.5)), 3)
  expect_equal(si_mean(rep(7, 10)), 7)
  expect_error(si_mean(numeric(0)), "empty")
})

test_that("si_variance supports population and sample conventions", {
  d <- c(2, 4, 4, 4, 5, 5, 7, 9)
  expect_equal(si_variance(d), 4)               # population
  expect_equal(si_variance(d, ddof = 1), 32 / 7) # sample (Bessel)
  expect_error(si_variance(c(1), ddof = 1), "not enough")
  expect_error(si_variance(numeric(0)), "empty")
})

test_that("si_std_dev is the square root of si_variance", {
  d <- c(2, 4, 4, 4, 5, 5, 7, 9)
  expect_equal(si_std_dev(d), 2)
  expect_equal(si_std_dev(d, ddof = 1), sqrt(32 / 7))
})

test_that("si_covariance handles sample and population ddof", {
  expect_equal(si_covariance(c(1, 2, 3), c(4, 5, 6)), 1)
  expect_equal(si_covariance(c(1, 2, 3), c(4, 5, 6), ddof = 0), 2 / 3)
  expect_error(si_covariance(c(1, 2), c(1, 2, 3)), "same length")
  expect_error(si_covariance(c(1), c(1)), "not enough")
})

test_that("si_correlation is symmetric and bounded", {
  expect_equal(si_correlation(c(1, 2, 3), c(4, 5, 6)), 1)
  expect_equal(si_correlation(c(1, 2, 3), c(6, 5, 4)), -1)
  expect_equal(si_correlation(c(1, 2, 3, 4), c(1, 4, 9, 16)),
               0.9843740, tolerance = 1e-5)
  expect_error(si_correlation(c(1, 1, 1), c(1, 2, 3)), "zero variance")
})

test_that("si_erf matches Abramowitz & Stegun 7.1.26", {
  expect_equal(si_erf(0), 0)                     # exact at zero by design
  expect_equal(si_erf(1), 0.8427008, tolerance = 1e-6)
  expect_equal(si_erf(0.5), 0.5205000, tolerance = 1e-6)
  expect_equal(si_erf(2), 0.9953221, tolerance = 1e-6)
  expect_equal(si_erf(-1), -si_erf(1))           # odd function
  expect_equal(si_erf(-2), -si_erf(2))
})

test_that("si_gamma matches the Lanczos g=7 approximation", {
  expect_equal(si_gamma(1), 1)
  expect_equal(si_gamma(2), 1)
  expect_equal(si_gamma(3), 2)
  expect_equal(si_gamma(5), 24)
  expect_equal(si_gamma(6), 120)
  expect_equal(si_gamma(0.5), sqrt(pi), tolerance = 1e-12)
  expect_equal(si_gamma(0.1), 9.5135076986687, tolerance = 1e-9)
  expect_equal(si_gamma(-1.5), 2.3632718012073, tolerance = 1e-8)  # reflection
  expect_error(si_gamma(0), "non-positive integer")
  expect_error(si_gamma(-3), "non-positive integer")
})

test_that("si_normal_ppf inverts the standard Normal CDF", {
  expect_equal(si_normal_ppf(0.5), 0, tolerance = 1e-8)
  expect_equal(si_normal_ppf(0.975), 1.959963, tolerance = 1e-5)
  expect_equal(si_normal_ppf(0.025), -1.959963, tolerance = 1e-5)
  expect_equal(si_normal_ppf(0.975), -si_normal_ppf(0.025))  # symmetric
  expect_error(si_normal_ppf(0), "p must be in")
  expect_error(si_normal_ppf(1), "p must be in")
})
