test_that("BetaBinomialModel prior and validation", {
  m <- BetaBinomialModel$new(alpha = 2, beta = 8)
  expect_equal(m$prior_mean(), 0.2)
  expect_error(BetaBinomialModel$new(0, 1), "must be > 0")
  expect_error(BetaBinomialModel$new(1, -1), "must be > 0")

  m1 <- BetaBinomialModel$new()
  expect_error(m1$posterior_mean(), "must call update")
  expect_error(m1$posterior_variance(), "must call update")
  expect_error(m1$credible_interval(), "must call update")
})

test_that("BetaBinomialModel posterior after one batch", {
  m <- BetaBinomialModel$new(alpha = 1, beta = 1)
  m$update(7, 10)
  expect_equal(m$posterior_mean(), 2 / 3)          # Beta(8, 4)
  expect_equal(m$posterior_variance(), 32 / 1872)
})

test_that("BetaBinomialModel sequential updating", {
  m <- BetaBinomialModel$new(1, 1)
  m$update(7, 10)
  expect_equal(m$posterior_mean(), 8 / 12)
  m$update(6, 10)
  expect_equal(m$posterior_mean(), 14 / 22)
  m$update(8, 10)
  expect_equal(m$posterior_mean(), 22 / 32)
  expect_equal(m$posterior_variance(), 22 * 10 / (32^2 * 33))
})

test_that("BetaBinomialModel credible interval", {
  m <- BetaBinomialModel$new(1, 1)
  m$update(7, 10)
  m$update(6, 10)
  m$update(8, 10)

  ci <- m$credible_interval(0.95)
  expect_length(ci, 2)
  expect_true(ci[1] < m$posterior_mean() && m$posterior_mean() < ci[2])
  expect_equal(ci[1], 0.5293562, tolerance = 1e-5)
  expect_equal(ci[2], 0.8456438, tolerance = 1e-5)

  ci90 <- m$credible_interval(0.90)
  expect_gt(ci90[1], ci[1])   # narrower interval at lower confidence
  expect_lt(ci90[2], ci[2])

  expect_error(m$credible_interval(0), "confidence must be")
  expect_error(m$credible_interval(1), "confidence must be")
})

test_that("BetaBinomialModel update validation and chaining", {
  m <- BetaBinomialModel$new(1, 1)
  expect_error(m$update(11, 10), "0 <= successes <= trials")
  expect_error(m$update(-1, 10), "0 <= successes <= trials")
  expect_error(m$update(5, 0), "trials must be > 0")

  chained <- BetaBinomialModel$new(1, 1)$update(7, 10)
  expect_s3_class(chained, "BetaBinomialModel")
  expect_equal(chained$posterior_mean(), 2 / 3)
})

test_that("NormalNormalModel prior and validation", {
  m <- NormalNormalModel$new(mu0 = 2, sigma0 = 3, sigma = 1)
  expect_equal(m$prior_mean(), 2)
  expect_equal(m$prior_variance(), 9)
  expect_error(NormalNormalModel$new(0, 0, 1), "must be > 0")
  expect_error(NormalNormalModel$new(0, 1, 0), "must be > 0")

  m1 <- NormalNormalModel$new(0, 1, 1)
  expect_error(m1$posterior_mean(), "must call update")
  expect_error(m1$posterior_variance(), "must call update")
  expect_error(m1$credible_interval(), "must call update")
  expect_error(m1$update(numeric(0)), "must not be empty")
})

test_that("NormalNormalModel posterior after one batch", {
  m <- NormalNormalModel$new(mu0 = 0, sigma0 = 10, sigma = 1)
  m$update(rep(5, 20))
  expect_equal(m$posterior_mean(), 4.9975012, tolerance = 1e-6)
  expect_equal(m$posterior_variance(), 0.04997501, tolerance = 1e-6)
})

test_that("NormalNormalModel sequential updating", {
  m <- NormalNormalModel$new(mu0 = 0, sigma0 = 10, sigma = 1)
  m$update(c(5, 5))
  expect_equal(m$posterior_mean(), 4.9751244, tolerance = 1e-6)
  expect_equal(m$posterior_variance(), 0.4975124, tolerance = 1e-6)
  m$update(c(5))
  expect_equal(m$posterior_mean(), 4.9833887, tolerance = 1e-6)
  expect_equal(m$posterior_variance(), 0.3322259, tolerance = 1e-6)
})

test_that("NormalNormalModel exact credible interval", {
  m <- NormalNormalModel$new(mu0 = 0, sigma0 = 10, sigma = 1)
  m$update(rep(5, 20))

  ci <- m$credible_interval(0.95)
  expect_equal(ci[1], 4.5593498, tolerance = 1e-5)
  expect_equal(ci[2], 5.4356527, tolerance = 1e-5)
  expect_lt(ci[1], m$posterior_mean())
  expect_gt(ci[2], m$posterior_mean())

  ci50 <- m$credible_interval(0.50)
  expect_gt(ci50[1], ci[1])   # narrower interval at lower confidence
  expect_lt(ci50[2], ci[2])

  expect_error(m$credible_interval(0), "confidence must be")
  expect_s3_class(NormalNormalModel$new(0, 1, 1)$update(c(1, 2)),
                  "NormalNormalModel")
})
