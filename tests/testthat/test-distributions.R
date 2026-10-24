test_that("NormalDistribution basic properties N(0, 1)", {
  d <- NormalDistribution$new(0, 1)
  expect_equal(d$pdf(0), 0.3989422804014327)
  expect_equal(d$pdf(1), 0.2419707245191434, tolerance = 1e-12)
  expect_equal(d$pdf(2), 0.0539909665131880, tolerance = 1e-12)
  expect_equal(d$cdf(0), 0.5)
  expect_equal(d$cdf(1.96), 0.9750021, tolerance = 1e-6)
  expect_equal(d$mean(), 0)
  expect_equal(d$variance(), 1)
})

test_that("NormalDistribution honours mu and sigma", {
  d <- NormalDistribution$new(mu = 5, sigma = 2)
  expect_equal(d$pdf(5), 1 / (2 * sqrt(2 * pi)))
  expect_equal(d$cdf(5), 0.5)
  expect_equal(d$mean(), 5)
  expect_equal(d$variance(), 4)
})

test_that("NormalDistribution validates sigma", {
  expect_error(NormalDistribution$new(0, 0), "sigma must be > 0")
  expect_error(NormalDistribution$new(0, -1), "sigma must be > 0")
})

test_that("NormalDistribution$sample uses Box-Muller", {
  set.seed(42)
  d <- NormalDistribution$new(0, 1)
  s <- d$sample(1000)
  expect_length(s, 1000)
  expect_lt(abs(si_mean(s)), 0.2)
  expect_lt(abs(si_std_dev(s) - 1), 0.15)
  expect_length(d$sample(1), 1)
})

test_that("Normal cdf and si_normal_ppf are inverses", {
  d <- NormalDistribution$new(0, 1)
  expect_equal(d$cdf(si_normal_ppf(0.8)), 0.8, tolerance = 1e-5)
})

test_that("BinomialDistribution B(10, 0.5)", {
  d <- BinomialDistribution$new(10, 0.5)
  expect_equal(d$pmf(0), 1 / 1024)
  expect_equal(d$pmf(5), 252 / 1024)
  expect_equal(d$cdf(0), 1 / 1024)
  expect_equal(d$cdf(5), 638 / 1024)
  expect_equal(d$cdf(10), 1)
  expect_equal(d$cdf(-1), 0)
  expect_equal(d$mean(), 5)
  expect_equal(d$variance(), 2.5)
})

test_that("BinomialDistribution B(10, 0.3)", {
  d <- BinomialDistribution$new(10, 0.3)
  expect_equal(d$mean(), 3)
  expect_equal(d$variance(), 2.1)
  expect_equal(d$pmf(3), 120 * 0.3^3 * 0.7^7)
})

test_that("BinomialDistribution validation", {
  expect_error(BinomialDistribution$new(0, 0.5), "n must be >= 1")
  expect_error(BinomialDistribution$new(10, -0.1), "p must be in")
  expect_error(BinomialDistribution$new(10, 1.1), "p must be in")
  d <- BinomialDistribution$new(10, 0.5)
  expect_error(d$pmf(11), "0, n")
  expect_error(d$pmf(-1), "0, n")
  expect_error(d$pmf(2.5), "integer")
})

test_that("BinomialDistribution$sample stays in [0, n]", {
  set.seed(42)
  d <- BinomialDistribution$new(10, 0.5)
  s <- d$sample(1000)
  expect_length(s, 1000)
  expect_true(all(s >= 0 & s <= 10))
  expect_true(all(s == floor(s)))
  expect_lt(abs(si_mean(s) - 5), 0.3)
})

test_that("PoissonDistribution Pois(3)", {
  d <- PoissonDistribution$new(3)
  expect_equal(d$pmf(0), exp(-3))
  expect_equal(d$pmf(3), 27 * exp(-3) / 6)
  expect_equal(d$cdf(3), 13 * exp(-3))   # e^-3 (1 + 3 + 9/2 + 27/6)
  expect_equal(d$cdf(-0.5), 0)
  expect_equal(d$mean(), 3)
  expect_equal(d$variance(), 3)
})

test_that("PoissonDistribution validation", {
  expect_error(PoissonDistribution$new(0), "lam must be > 0")
  expect_error(PoissonDistribution$new(-1), "lam must be > 0")
  d <- PoissonDistribution$new(3)
  expect_error(d$pmf(-1), "non-negative integer")
  expect_error(d$pmf(2.5), "non-negative integer")
})

test_that("PoissonDistribution$sample draws counts via inverse transform", {
  set.seed(42)
  d <- PoissonDistribution$new(3)
  s <- d$sample(1000)
  expect_length(s, 1000)
  expect_true(all(s >= 0))
  expect_true(all(s == floor(s)))
  expect_lt(abs(si_mean(s) - 3), 0.3)
})
