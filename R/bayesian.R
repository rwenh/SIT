#' Bayesian inference via conjugate priors
#'
#' @description
#' Two analytically exact conjugate models (no sampling or MCMC needed):
#'
#' \strong{Model 1 -- BetaBinomialModel}
#' \itemize{
#'   \item Prior: p ~ Beta(alpha, beta)
#'   \item Likelihood: k | p ~ Binomial(n, p)
#'   \item Posterior: p | k ~ Beta(alpha + k, beta + n - k) -- same family!
#' }
#'
#' \strong{Model 2 -- NormalNormalModel}
#' \itemize{
#'  \item Prior: mu ~ Normal(mu0, sigma0^2), sigma known
#'  \item Likelihood: X | mu ~ Normal(mu, sigma^2)
#'  \item Posterior: mu | X ~ Normal(mu_n, sigma_n^2) -- same family!
#' }
#'
#' \deqn{\sigma_n^2 = 1 / (1/\sigma_0^2 + n/\sigma^2)}
#' \deqn{\mu_n = \sigma_n^2 (\mu_0/\sigma_0^2 + n\bar{x}/\sigma^2)}
#'
#' Depends on \code{\link{si_normal_ppf}} (credible intervals) and
#' \code{\link{si_mean}} (\code{NormalNormalModel$update})
#'
#' @name bayesian
NULL


                                        #---------------------------------------------
                                        # 1. Beta-Binomial conjugate model
                                        #====================================
#' Beta-Binomial conjugate model for estimating a proportion p
#'
#' @description
#' Start with a prior belief p ~ Beta(alpha, beta): alpha = prior
#' "pseudo-successes", beta = prior "pseudo-failures". alpha = beta = 1
#' gives a uniform (uninformative) prior
#'
#' After observing k successes in n trials, the posterior is
#' Beta(alpha + k, beta + n - k).
#'
#' Useful moments of Beta(alpha, beta):
#' \deqn{mean = \alpha / (\alpha + \beta)}
#' \deqn{variance = \alpha\beta / ((\alpha+\beta)^2 (\alpha+\beta+1))}
#'
#' @export
#' @examples
#' m <- BetaBinomialModel$new(alpha = 1, beta = 1)$update(7, 10)
#' round(m$posterior_mean(), 3)
BetaBinomialModel <- R6::R6Class("BetaBinomialModel",
  public = list(
    #' @field alpha Prior alpha (> 0), never changed after construction
    alpha = NULL,
    #' @field beta Prior beta (> 0), never changed after construction
    beta = NULL,

    #' @description Store prior parameters and initialise state.
    #' @param alpha Prior alpha, > 0 (default 1.0)
    #' @param beta Prior beta, > 0 (default 1.0)
    initialize = function(alpha = 1.0, beta = 1.0) {
      if (alpha <= 0 || beta <= 0) {
        stop("alpha and beta must be > 0", call. = FALSE)
      }
      self$alpha <- alpha
      self$beta <- beta
      private$post_alpha <- alpha
      private$post_beta <- beta
      private$fitted <- FALSE
    },
    #' @description Mean of the prior Beta(alpha, beta):
    #' \code{alpha / (alpha + beta)}.
    prior_mean = function() {
      self$alpha / (self$alpha + self$beta)
    },
    #' @description Incorporate observed data:
    #' \code{post_alpha += successes}, \code{post_beta += trials - successes}.
    #' @param successes Observed successes, \code{0 <= successes <= trials}
    #' @param trials Total observed trials, > 0
    #' @return \code{self}, invisibly (enables method chaining)
    update = function(successes, trials) {
      if (trials <= 0) {
        stop("trials must be > 0", call. = FALSE)
      }
      if (successes < 0 || successes > trials) {
        stop("successes must satisfy 0 <= successes <= trials", call. = FALSE)
      }
      private$post_alpha <- private$post_alpha + successes
      private$post_beta <- private$post_beta + (trials - successes)
      private$fitted <- TRUE
      invisible(self)
    },
    #' @description Mean of the posterior Beta distribution:
    #' \code{post_alpha / (post_alpha + post_beta)}.
    posterior_mean = function() {
      private$require_fitted()
      private$post_alpha / (private$post_alpha + private$post_beta)
    },
    #' @description Variance of the posterior Beta distribution:
    #' \code{post_alpha * post_beta / ((post_alpha + post_beta)^2
    #' (post_alpha + post_beta + 1))}.
    posterior_variance = function() {
      private$require_fitted()
      a <- private$post_alpha
      b <- private$post_beta
      (a * b) / ((a + b)^2 * (a + b + 1))
    },

    #' @description Approximate central credible interval for the
    #' posterior, using a Normal approximation (mean +/- z * sd, clamped
    #' to the 0-to-1 range).
    #' @param confidence e.g. 0.95 for a 95% credible interval
    #' @return numeric vector \code{c(lower, upper)}
    credible_interval = function(confidence = 0.95) {
      private$require_fitted()
      if (confidence <= 0 || confidence >= 1) {
        stop("confidence must be in (0, 1)", call. = FALSE)
      }
      m <- self$posterior_mean()
      s <- sqrt(self$posterior_variance())
      z <- si_normal_ppf(1 - (1 - confidence) / 2)
      lower <- max(m - z * s, 0.0)
      upper <- min(m + z * s, 1.0)
      c(lower, upper)
    }
  ),
  private = list(
    post_alpha = NULL,
    post_beta = NULL,
    fitted = FALSE,
    require_fitted = function() {
      if (!private$fitted) {
        stop("must call update() before accessing the posterior", call. = FALSE)
      }
    }
  )
)

                                        #========================
                                        # 2. Normal-Normal conjugate model
                                        #=============================
#' Normal-Normal conjugate model for estimating an unknown mean mu
#'
#' @description
#' Prior: mu ~ Normal(mu0, sigma0^2). Likelihood: X ~ Normal(mu, sigma^2)
#' with sigma known; only mu is unknown
#'
#' Posterior after observing data x1 .. xn:
#' \deqn{\sigma_n^2 = 1 / (1/\sigma_0^2 + n/\sigma^2)}
#' \deqn{\mu_n = \sigma_n^2 (\mu_0/\sigma_0^2 + n \bar{x}/\sigma^2)}
#'
#' @export
#' @examples
#' m <- NormalNormalModel$new(mu0 = 0.0, sigma0 = 10.0, sigma = 1.0)
#' m$update(rep(5.0, 20))
#' round(m$posterior_mean(), 1)
NormalNormalModel <- R6::R6Class("NormalNormalModel",
  public = list(
    #' @field mu0 Prior mean, never changed after construction
    mu0 = NULL,
    #' @field sigma0 Prior std dev (> 0), never changed after construction
    sigma0 = NULL,
    #' @field sigma Known likelihood std dev (> 0), never changed after construction
    sigma = NULL,

    #' @description Store parameters and initialise state
    #' @param mu0 Prior mean
    #' @param sigma0 Prior std dev, > 0
    #' @param sigma Known likelihood std dev, > 0
    initialize = function(mu0, sigma0, sigma) {
      if (sigma0 <= 0 || sigma <= 0) {
        stop("sigma0 and sigma must be > 0", call. = FALSE)
      }
      self$mu0 <- mu0
      self$sigma0 <- sigma0
      self$sigma <- sigma
      private$post_mu <- mu0
      private$post_var <- sigma0^2
      private$fitted <- FALSE
    },
    #' @description Prior mean mu0
    prior_mean = function() self$mu0,

    #' @description Prior variance sigma0^2
    prior_variance = function() self$sigma0^2,

    #' @description Incorporate observed data and update the posterior
    #' @param data Numeric vector, at least 1 observation
    #' @return \code{self}, invisibly
    update = function(data) {
      if (length(data) == 0) {
        stop("data must not be empty", call. = FALSE)
      }
      n <- length(data)
      xbar <- si_mean(data)
      prior_mu <- private$post_mu
      prior_var <- private$post_var
      post_var_n <- 1 / (1 / prior_var + n / self$sigma^2)
      post_mu_n <- post_var_n * (prior_mu / prior_var + n * xbar / self$sigma^2)
      private$post_mu <- post_mu_n
      private$post_var <- post_var_n
      private$fitted <- TRUE
      invisible(self)
    },

    #' @description Current posterior mean (mu_n after the last
    #' \code{update()})
    posterior_mean = function() {
      private$require_fitted()
      private$post_mu
    },

    #' @description Current posterior variance (sigma_n^2 after the last
    #' \code{update()})
    posterior_variance = function() {
      private$require_fitted()
      private$post_var
    },

    #' @description Exact credible interval using Normal quantiles (no
    #' approximation needed since the posterior is exactly normal).
    #' @param confidence e.g. 0.95 for a 95% credible interval
    #' @return numeric vector \code{c(lower, upper)}
    credible_interval = function(confidence = 0.95) {
      private$require_fitted()
      if (confidence <= 0 || confidence >= 1) {
        stop("confidence must be in (0, 1)", call. = FALSE)
      }
      z <- si_normal_ppf(1 - (1 - confidence) / 2)
      s <- sqrt(self$posterior_variance())
      m <- self$posterior_mean()
      c(m - z * s, m + z * s)
    }
  ),
  private = list(
    post_mu = NULL,
    post_var = NULL,
    fitted = FALSE,
    require_fitted = function() {
      if (!private$fitted) {
        stop("must call update() before accessing the posterior", call. = FALSE)
      }
    }
  )
)
