test_that("SimpleLinearRegression fits a perfect line exactly", {
  m <- SimpleLinearRegression$new()$fit(1:5, c(2, 4, 6, 8, 10))
  expect_equal(m$slope, 2)
  expect_equal(m$intercept, 0)
  expect_equal(m$r_squared(), 1)
  expect_equal(m$residuals(), rep(0, 5))
  expect_equal(m$predict(3.5), 7)
  expect_equal(m$predict(c(9, 10)), c(18, 20))
})

test_that("SimpleLinearRegression fits the demo dataset", {
  x <- c(1, 2, 3, 4, 5, 6, 7, 8)
  y <- c(2.1, 3.9, 6.2, 7.8, 10.1, 11.9, 14.2, 15.8)
  m <- SimpleLinearRegression$new()$fit(x, y)

  s <- m$summary()
  expect_equal(s$slope, 1.9857143, tolerance = 1e-6)
  expect_equal(s$intercept, 0.0642857, tolerance = 1e-6)
  expect_equal(s$r_squared, 0.9988454, tolerance = 1e-6)
  expect_equal(s$n, 8)

  expect_equal(m$predict(c(9, 10)), c(17.9357143, 19.9214286), tolerance = 1e-6)

  r <- m$residuals()
  expect_length(r, 8)
  expect_equal(r[1], 0.05, tolerance = 1e-10)
  expect_true(all(abs(r) < 0.25))
})

test_that("SimpleLinearRegression guards", {
  m <- SimpleLinearRegression$new()
  expect_error(m$predict(1), "must call fit")
  expect_error(m$residuals(), "must call fit")
  expect_error(m$r_squared(), "must call fit")
  expect_error(m$summary(), "must call fit")
  expect_error(m$fit(c(1, 2, 3), c(1, 2)), "same length")
  expect_error(m$fit(c(1), c(1)), "at least 2")
  expect_error(m$fit(c(1, 1, 1), c(1, 2, 3)), "variance of x is zero")

  m_flat <- SimpleLinearRegression$new()$fit(c(1, 2, 3), c(5, 5, 5))
  expect_equal(m_flat$slope, 0)
  expect_equal(m_flat$intercept, 5)
  expect_error(m_flat$r_squared(), "total sum of squares")
})

test_that("fit returns the model itself for chaining", {
  m <- SimpleLinearRegression$new()
  expect_s3_class(m$fit(1:3, c(1, 2, 3)), "SimpleLinearRegression")
  expect_identical(m$fit(1:3, c(2, 4, 6)), m)  # R6 reference semantics
  expect_equal(m$slope, 2)
})
