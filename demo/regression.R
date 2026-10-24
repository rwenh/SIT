library(statinfer)

x <- c(1, 2, 3, 4, 5, 6, 7, 8)
y <- c(2.1, 3.9, 6.2, 7.8, 10.1, 11.9, 14.2, 15.8)

model <- SimpleLinearRegression$new()$fit(x, y)

s <- model$summary()
cat(sprintf("slope      = %.4f\n", s$slope))
cat(sprintf("intercept  = %.4f\n", s$intercept))
cat(sprintf("r_squared  = %.4f\n", s$r_squared))
cat(sprintf("n          = %d\n\n", s$n))

cat("Predictions for x = 9, 10:\n")
print(model$predict(c(9, 10)))

cat("\nFirst 3 residuals:\n")
print(head(model$residuals(), 3))
