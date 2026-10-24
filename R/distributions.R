#' Probability distributions implemented from scratch
#'
#' @description
#' Three distributions as R6 classes. Each exposes:
#' \itemize{
#'      \item \code{pdf(x)} / \code{pmf(k)} -- density or mass at a point
#'      \item \code{cdf(x)} -- cumulative probability P(X <= x)
#'      \item \code{mean()} -- theoretical mean
#'      \item \code{variance()} -- theoretical variance
#'      \item \code{sample(n)}  -- draw n independent samples using pure R
#' }
#'
#' Depends on \code{\link{si_erf}}, \code{\link{si_combinations}}
#' and \code{\link{si_factorial}} from utils.R
#'
#' @name distributions
#' @importFrom R6 R6Class
#' @importFrom stats runif
NULL

                                        #====================
                                        # 1. Normal Distribution
                                        #==========================

#' Normal (Gaussian) distribution N(mu, sigma^2)
#'
#' @export
#' @examples
#' d <- NormalDistribution$new(mu = 0, sigma = 1)
#' d$pdf(0)
#' d$cdf(1.96)
#' d$mean()
#' d$variance()
#' length(d$sample(10))
NormalDistribution <- R6::R6Class("NormalDistribution",
  public = list(
    #' @field mu Mean
    mu = NULL,
    #' @field sigma Std dev (> 0)
    sigma = NULL,

    #' @description Create a Normal(mu, sigma) distribution.
    #' @param mu Mean (default 0)
    #' @param sigma Std dev, must be > 0 (default 1)
    initialize = function(mu = 0.0, sigma = 1.0) {
      if (sigma <= 0) {
        stop("sigma must be > 0", call. = FALSE)
      }
      self$mu <- mu
      self$sigma <- sigma
    },

    #' @description Density of N(mu, sigma^2) at \code{x}.
    #' @param x Numeric point
    pdf = function(x) {
      coef <- 1 / (self$sigma * sqrt(2 * pi))
      coef * exp(-((x - self$mu)^2) / (2 * self$sigma^2))
    },

    #' @description Cumulative probability \eqn{P(X <= x)} via \code{\link{si_erf}}.
    #' @param x Numeric point
    cdf = function(x) {
      0.5 * (1 + si_erf((x - self$mu) / (self$sigma * sqrt(2))))
    },

    #' @description Theoretical mean \eqn{mu}.
    mean = function() self$mu,

    #' @description Theoretical variance \eqn{sigma^2}.
    variance = function() self$sigma^2,

    #' @description Draw \code{n} independent samples using the Box-Muller
    #' transform: two uniform draws give two independent N(0,1) values,
    #' which are then shifted and scaled.
    #' @param n Number of samples (default 1)
    sample = function(n = 1) {
      samples <- numeric(0)
      while (length(samples) < n) {
        u1 <- stats::runif(1)
        while (u1 == 0) {
          u1 <- stats::runif(1)
        }
        u2 <- stats::runif(1)
        r <- sqrt(-2 * log(u1))
        z0 <- r * cos(2 * pi * u2)
        z1 <- r * sin(2 * pi * u2)
        samples <- c(samples,
                     self$mu + self$sigma * z0,
                     self$mu + self$sigma * z1)
      }
      samples[seq_len(n)]
    }
  )
)

                                        #====================
                                        # 2. Binomial Distribution
                                        #==========================

#' Binomial distribution B(n, p)
#'
#' Models the number of successes in \code{n} independent Bernoulli
#' trials, each with success probability \code{p}
#'
#' @export
#' @examples
#' d <- BinomialDistribution$new(n = 10, p = 0.5)
#' d$pmf(5)
#' d$mean()
#' d$variance()
BinomialDistribution <- R6::R6Class("BinomialDistribution",
  public = list(
    #' @field n Number of trials (integer >= 1)
    n = NULL,
    #' @field p Success probability between 0 and 1, inclusive
    p = NULL,

    #' @description Create a Binomial(n, p) distribution.
    #' @param n Number of trials, integer >= 1
    #' @param p Success probability between 0 and 1, inclusive
    initialize = function(n, p) {
      if (n < 1 || p < 0 || p > 1) {
        stop("n must be >= 1 and p must be in [0, 1]", call. = FALSE)
      }
      self$n <- n
      self$p <- p
    },

    #' @description Probability mass at \code{k} successes.
    #' @param k Integer number of successes, \code{0 <= k <= n}
    pmf = function(k) {
      if (k < 0 || k > self$n || k != floor(k)) {
        stop("k must be an integer in [0, n]", call. = FALSE)
      }
      si_combinations(self$n, k) * self$p^k * (1 - self$p)^(self$n - k)
    },

    #' @description Cumulative probability \eqn{P(X <= k)}.
    #' @param k Numeric point (floored for the summation range)
    cdf = function(k) {
      if (k < 0) {
        return(0.0)
      }
      if (k >= self$n) {
        return(1.0)
      }
      sum(vapply(0:floor(k), self$pmf, numeric(1)))
    },

    #' @description Theoretical mean \eqn{n p}.
    mean = function() self$n * self$p,

    #' @description Theoretical variance \eqn{n p (1 - p)}.
    variance = function() self$n * self$p * (1 - self$p),

    #' @description Draw \code{n_samples} outcomes by counting successes
    #' in \code{n} uniform Bernoulli draws each.
    #' @param n_samples Number of samples (default 1)
    sample = function(n_samples = 1) {
      vapply(seq_len(n_samples), function(i) {
        sum(stats::runif(self$n) < self$p)
      }, numeric(1))
    }
  )
)

                                        #====================
                                        # 3. Poisson Distribution
                                        #==========================

#' Poisson distribution Pois(lambda)
#'
#' Models the number of events in a fixed interval when events occur at a
#' constant average rate \code{lambda}
#'
#' @export
#' @examples
#' d <- PoissonDistribution$new(lam = 3)
#' d$pmf(3)
#' d$mean()
#' d$variance()
PoissonDistribution <- R6::R6Class("PoissonDistribution",
  public = list(
    #' @field lam Rate parameter lambda (> 0)
    lam = NULL,

    #' @description Create a Poisson(lam) distribution.
    #' @param lam Rate parameter, must be > 0
    initialize = function(lam) {
      if (lam <= 0) {
        stop("lam must be > 0", call. = FALSE)
      }
      self$lam <- lam
    },

    #' @description Probability mass at \code{k} events.
    #' @param k Integer number of events, >= 0
    pmf = function(k) {
      if (k < 0 || k != floor(k)) {
        stop("k must be a non-negative integer", call. = FALSE)
      }
      (self$lam^k * exp(-self$lam)) / si_factorial(k)
    },

    #' @description Cumulative probability \eqn{P(X <= k)}.
    #' @param k Numeric point (floored for the summation range)
    cdf = function(k) {
      if (k < 0) {
        return(0.0)
      }
      sum(vapply(0:floor(k), self$pmf, numeric(1)))
    },

    #' @description Theoretical mean \eqn{lambda}.
    mean = function() self$lam,

    #' @description Theoretical variance \eqn{lambda}.
    variance = function() self$lam,

    #' @description Draw \code{n} samples using the inverse-transform
    #' (multiplicative) method for the Poisson distribution.
    #' @param n Number of samples (default 1)
    sample = function(n = 1) {
      L <- exp(-self$lam)
      draw_one <- function() {
        k <- 0
        prod_u <- 1.0
        while (prod_u > L) {
          k <- k + 1
          prod_u <- prod_u * stats::runif(1)
        }
        k - 1
      }
      vapply(seq_len(n), function(i) draw_one(), numeric(1))
    }
  )
)
