test_that("hypothesis_result is an S3 object with a print method", {
  r <- hypothesis_result(1.5, 0.1, TRUE)
  expect_s3_class(r, "hypothesis_result")
  expect_equal(r$statistic, 1.5)
  expect_equal(r$p_value, 0.1)
  expect_true(r$reject_h0)
  expect_output(print(r), "reject_h0")
})

test_that("z_test with known population sigma", {
  x <- c(10, 11, 12, 13, 14)
  r <- z_test(x, mu0 = 5.0, sigma = 2.0)
  expect_s3_class(r, "hypothesis_result")
  expect_equal(r$statistic, 7.8262379, tolerance = 1e-6)
  expect_lt(r$p_value, 0.001)
  expect_true(r$reject_h0)
  expect_error(z_test(x, 5, 0), "sigma must be > 0")
  expect_error(z_test(numeric(0), 5, 2), "empty")
})

test_that("z_test alternatives", {
  x <- c(10, 11, 12, 13, 14)
  r_less <- z_test(x, mu0 = 5.0, sigma = 2.0, alternative = "less")
  r_greater <- z_test(x, mu0 = 5.0, sigma = 2.0, alternative = "greater")
  expect_false(r_less$reject_h0)
  expect_gt(r_less$p_value, 0.99)
  expect_true(r_greater$reject_h0)
  expect_lt(r_greater$p_value, 0.001)
  expect_error(z_test(x, 5, 2, alternative = "both"), "alternative must be")
})

test_that("one_sample_t_test", {
  x <- c(20, 21, 22, 23, 24)
  r <- one_sample_t_test(x, mu0 = 10.0)
  expect_equal(r$statistic, 16.9705627, tolerance = 1e-6)
  expect_true(r$reject_h0)

  r_null <- one_sample_t_test(x, mu0 = 22.0)
  expect_equal(r_null$statistic, 0)
  expect_equal(r_null$p_value, 1)
  expect_false(r_null$reject_h0)

  r_pos <- one_sample_t_test(x, mu0 = 21.0)
  expect_equal(r_pos$statistic, sqrt(2), tolerance = 1e-12)
  expect_equal(r_pos$p_value, 0.15729931, tolerance = 1e-5)
  expect_false(r_pos$reject_h0)

  expect_error(one_sample_t_test(c(1), 0), "at least 2")
})

test_that("two_sample_t_test (Welch)", {
  r <- two_sample_t_test(c(1, 2, 3, 4, 5), c(10, 11, 12, 13, 14))
  expect_equal(r$statistic, -9)
  expect_lt(r$p_value, 0.001)
  expect_true(r$reject_h0)

  r_null <- two_sample_t_test(1:5, 1:5)
  expect_equal(r_null$statistic, 0)
  expect_false(r_null$reject_h0)

  expect_error(two_sample_t_test(c(1), c(1, 2)), "at least 2")
  expect_error(two_sample_t_test(c(1, 2), c(1)), "at least 2")
})

test_that("chi_square_test goodness of fit", {
  r <- chi_square_test(c(18, 22, 20, 20), rep(20, 4))
  expect_equal(r$statistic, 0.4)
  expect_equal(r$p_value, 0.9101437, tolerance = 1e-5)
  expect_false(r$reject_h0)

  r_rej <- chi_square_test(c(5, 35, 20, 20), rep(20, 4))
  expect_equal(r_rej$statistic, 22.5)
  expect_lt(r_rej$p_value, 0.001)
  expect_true(r_rej$reject_h0)

  expect_error(chi_square_test(c(18, 22, 20, 20), c(20, 20)), "same length")
  expect_error(chi_square_test(c(5), c(5)), "at least 2")
  expect_error(chi_square_test(c(18, 22), c(0, 0)), "non-zero")
})
