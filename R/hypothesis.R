#' Classical hypothesis tests implemented from scratch
#'
#' @description
#' Each public test function returns a \code{hypothesis_result} object
#' (an S3 list with \code{statistic}, \code{p_value}, \code{reject_h0}),
#' the R equivalent of the Python \code{HypothesisResult} namedtuple
#'
#' Depends on \code{\link{NormalDistribution}} (for its \code{cdf}) and
#' \code{\link{si_mean}} / \code{\link{si_std_dev}} from utils.R
#'
#' Implementation order (mirrors the original):
#' \enumerate{
#' \item \code{.normal_p_value} -- shared p-value engine (internal)
#' \item \code{z_test}
#' \item \code{one_sample_t_test}
#' \item \code{two_sample_t_test}
#' \item \code{chi_square_test}
#' }
#' @name hypothesis
NULL

                                        #========================
                                        # Result type
                                        #========================

#' Construct a hypothesis_result object
#'
#' @param statistic Computed test statistic (z, t, or chi-squared)
#' @param p_value Probability of observing this result under H0
#' @param reject_h0 Logical: TRUE when p_value < significance level
#' @return A \code{hypothesis_result} object (S3 list)
#' @export
hypothesis_result <- function(statistic, p_value, reject_h0) {
  structure(
    list(statistic = statistic, p_value = p_value, reject_h0 = reject_h0),
    class = "hypothesis_result"
  )
}

#' Print method for hypothesis_result objects
#'
#' @param x A \code{hypothesis_result} object
#' @param ... Further arguments passed to or from other methods
#' @export
print.hypothesis_result <- function(x, ...) {
  cat(sprintf(
    "<hypothesis_result> statistic = %.4f     p_value = %.4g      reject_h0 = %s\n",
    x$statistic, x$p_value, x$reject_h0
  ))
  invisible(x)
}

                                        # =====================================
                                        # Shared p-value helper (internal engine)
                                        #======================================

#' Convert a z (or t) statistic to a p-value via the std Normal CDF
#'
#' This is a Normal approximation. For t-tests it is accurate when
#' n >= 30; for smaller samples the exact t-distribution would give a
#' more conservative (larger) p-value
#'
#' @param z Test statistic
#' @param alternative One of \code{"two-tailed"}, \code{"less"},
#'      \code{"greater"}
#' @return numeric p-value in (0, 1]
#' @keywords internal
.normal_p_value <- function(z, alternative) {
  Phi <- function(x) NormalDistribution$new(0, 1)$cdf(x)
  if (alternative == "two-tailed") {
    2 * (1 - Phi(abs(z)))
  } else if (alternative == "less") {
    Phi(z)
  } else if (alternative == "greater") {
    1 - Phi(z)
  } else {
    stop(
      "alternative must be one of 'two-tailed', 'less', 'greater'",
      call. = FALSE
    )
  }
}

                                        # ======================
                                        # 1. One-sample z-test
                                        #====================
#' One-sample z-test (population std deviation known)
#'
#' H0: mu = mu0. Test statistic:
#' \deqn{z = (\bar{x} - \mu_0) / (\sigma / \sqrt{n})}
#'
#' @param sample Numeric vector of observed data
#' @param mu0 Hypothesised mean under H0
#' @param sigma Known population std dev (> 0)
#' @param alternative \code{"two-tailed"}, \code{"less"}, or
#'      \code{"greater"}.
#' @param significance Alpha level (default 0.05)
#' @return A \code{hypothesis_result}
#' @examples
#' z_test(c(10, 11, 12, 13, 14), mu0 = 5.0, sigma = 2.0)
#' @export
z_test <- function(sample, mu0, sigma, alternative = "two-tailed",
                   significance = 0.05) {
  if (length(sample) == 0) {
    stop("sample must not be empty", call. = FALSE)
  }
  if (sigma <= 0) {
    stop("sigma must be > 0", call. = FALSE)
  }
  n <- length(sample)
  xbar <- si_mean(sample)
  z <- (xbar - mu0) / (sigma / sqrt(n))
  p <- .normal_p_value(z, alternative)
  hypothesis_result(z, p, p < significance)
}


                                        #==============================
                                        # 2. One-sample t-test
                                        #==================
#' One-sample t-test (population std deviation unknown)
#'
#' Test statistic \eqn{t = (\bar{x} - \mu_0) / (s / \sqrt{n})} where s is
#' the sample standard deviation (ddof = 1). The p-value is computed via
#' the Normal approximation (accurate for n >= 30)
#'
#' @param sample Numeric vector, length >= 2
#' @param mu0 Null hypothesis mean
#' @param alternative \code{"two-tailed"}, \code{"less"}, or
#'      \code{"greater"}
#' @param significance Alpha level
#' @return A \code{hypothesis_result}
#' @examples
#' one_sample_t_test(c(20, 21, 22, 23, 24), mu0 = 10.0)
#' @export
one_sample_t_test <- function(sample, mu0, alternative = "two-tailed",
                              significance = 0.05) {
  if (length(sample) < 2) {
    stop("need at least 2 observations for a sample standard deviation",
         call. = FALSE)
  }
  n <- length(sample)
  xbar <- si_mean(sample)
  s <- si_std_dev(sample, ddof = 1)
  t <- (xbar - mu0) / (s / sqrt(n))
  p <- .normal_p_value(t, alternative)
  hypothesis_result(t, p, p < significance)
}


                                        #========================
                                        # 3. 2-sample t-test (Welch's)
                                        #===========================
#' Welch's 2-sample t-test (unequal variances assumed)
#'
#' H0: mu1 = mu2. Test statistic:
#' \deqn{t = (\bar{x}_1 - \bar{x}_2) / \sqrt{s_1^2/n_1 + s_2^2/n_2}}
#' p-value via the Normal approximation
#'
#' @param sample1 Numeric vector with >= 2 observations
#' @param sample2 Numeric vector with >= 2 observations
#' @param alternative \code{"two-tailed"}, \code{"less"}, or
#'      \code{"greater"}
#' @param significance Alpha level
#' @return A \code{hypothesis_result}
#' @examples
#' two_sample_t_test(c(1, 2, 3, 4, 5), c(10, 11, 12, 13, 14))
#' @export
two_sample_t_test <- function(sample1, sample2, alternative = "two-tailed",
                              significance = 0.05) {
  if (length(sample1) < 2 || length(sample2) < 2) {
    stop("each sample needs at least 2 observations", call. = FALSE)
  }
  n1 <- length(sample1)
  n2 <- length(sample2)
  m1 <- si_mean(sample1)
  m2 <- si_mean(sample2)
  v1 <- si_variance(sample1, ddof = 1)
  v2 <- si_variance(sample2, ddof = 1)
  t <- (m1 - m2) / sqrt(v1 / n1 + v2 / n2)
  p <- .normal_p_value(t, alternative)
  hypothesis_result(t, p, p < significance)
}

                                        #==============================
                                        # 4. Chi-square goodness-of-fit test
                                        #========================================
#' Chi-square goodness-of-fit test
#'
#' H0: the observed counts follow the expected distribution. Test
#' statistic \eqn{\chi^2 = \sum (O_i - E_i)^2 / E_i}
#' The p-value uses Fisher's Normal approximation:
#' \deqn{df = k - 1, \quad z = \sqrt{2\chi^2} - \sqrt{2df - 1},
#' \quad p = 1 - \Phi(z)}
#'
#' @param observed Integer vector of observed counts
#' @param expected Numeric vector of expected counts (same length as
#' \code{observed}; all > 0)
#' @param significance Alpha level
#' @return A \code{hypothesis_result}
#' @examples
#' chi_square_test(c(18, 22, 20, 20), c(20, 20, 20, 20))
#' @export
chi_square_test <- function(observed, expected, significance = 0.05) {
  if (length(observed) != length(expected)) {
    stop("observed and expected must have the same length", call. = FALSE)
  }
  if (length(observed) < 2) {
    stop("need at least 2 categories for a chi-square test", call. = FALSE)
  }
  if (any(expected <= 0)) {
    stop("expected values must be non-zero", call. = FALSE)
  }
  chi2 <- sum((observed - expected)^2 / expected)
  df <- length(observed) - 1
  z <- sqrt(2 * chi2) - sqrt(2 * df - 1)
  p <- 1 - NormalDistribution$new(0, 1)$cdf(z)
  hypothesis_result(chi2, p, p < significance)
}
