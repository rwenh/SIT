library(statinfer)

cat("Beta-Binomial: estimating a coin's bias\n")
coin <- BetaBinomialModel$new(alpha = 1, beta = 1)
cat(sprintf("   prior_mean() = %.4f\n", coin$prior_mean()))

batches <- list(c(7, 10), c(6, 10), c(8, 10)) # (successes, trials) per batch
for (b in batches) {
  coin$update(b[1], b[2])
  cat(sprintf(
    "   after update(%d, %d): posterior_mean() = %.4f\n",
    b[1], b[2], coin$posterior_mean()
  ))
}
ci <- coin$credible_interval(0.95)
cat(sprintf("   95%% credible interval: [%.4f, %.4f]\n\n", ci[1], ci[2]))

cat("Normal-Normal: estimating an unknown mean\n")
true_mu <- 5.0
data <- true_mu + stats::rnorm(30)
model <- NormalNormalModel$new(mu0 = 0.0, sigma0 = 100.0, sigma = 1.0)
model$update(data)
cat(sprintf("   true mu             = %.4f\n", true_mu))
cat(sprintf("   posterior_mean()    = %.4f\n", model$posterior_mean()))
cat(sprintf("   posterior_variance() = %.6f\n", model$posterior_variance()))
ci2 <- model$credible_interval(0.95)
cat(sprintf("   95%% credible interval: [%.4f, %.4f]\n", ci2[1], ci2[2]))
