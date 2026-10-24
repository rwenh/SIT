#' Core mathematical utilities for the statinfer package
#'
#' @description
#' Every formula below is hand-implemented rather than delegated to base R
#' or the \pkg{stats} package (which already provides \code{mean()},
#' \code{var()}, \code{sd()}, \code{cor()}, \code{cov()},
#' \code{factorial()}, \code{choose()}, \code{gamma()}, \code{qnorm()}...).
#'
#' Functions here are prefixed \code{si_} (Statistical Inference) so that
#' attaching this package with \code{library(statinfer)} never masks base
#' R's \code{mean}, \code{gamma}, \code{factorial}, etc.
#'
#' Implementation order mirrors the original:
#' \enumerate{
#' \item \code{si_factorial}
#' \item \code{si_combinations}
#' \item \code{si_mean}
#' \item \code{si_variance}
#' \item \code{si_std_dev}
#' \item \code{si_covariance}
#' \item \code{si_correlation}
#' \item \code{si_erf}
#' \item \code{si_gamma}
#' \item \code{si_normal_ppf}
#' }
#' @name si_utils
NULL

                                        #=============
                                        # Integer / combinatorial helpers
                                        #======================================

#' Factorial (n!)
#'
#' Computes \eqn{n!} iteratively.
#'
#' @param n Non-negative integer
#' @return \eqn{n!} (0! == 1 by convention)
#' @examples
#' si_factorial(0)
#' si_factorial(5)
#' si_factorial(10)
#' @export
si_factorial <- function(n) {
  if (n < 0) {
    stop("n must be a non-negative integer", call. = FALSE)
  }
  result <- 1
  if (n >= 2) {
    for (i in 2:n) {
      result <- result * i
    }
  }
  result
}


#' Binomial coefficient C(n, k)
#'
#' Computes \eqn{C(n, k) = n! / (k! (n-k)!)} using the multiplicative
#' formula, avoiding large intermediate factorials:
#' \deqn{C(n,k) = \prod_{i=1}^{k} (n - i + 1) / i}
#'
#' @param n Integer, >= 0
#' @param k Integer with \code{0 <= k <= n}
#' @return The binomial coefficient \eqn{C(n, k)}
#' @examples
#' si_combinations(5, 2)
#' si_combinations(10, 0)
#' si_combinations(20, 10)
#' @export
si_combinations <- function(n, k) {
  if (k < 0 || k > n) {
    stop("k must satisfy 0 <= k <= n", call. = FALSE)
  }
  result <- 1
  if (k > 0) {
    for (i in seq_len(k)) {
      # At each step result == C(n, i-1), so the product is exactly
      # divisible by i and integer division is exact.  The parentheses
      # are required: %/% binds tighter than * in R.
      result <- (result * (n - i + 1)) %/% i
    }
  }
  result
}

                                        #=================
                                        # Descriptive statistics
                                        #=============================

#' Arithmetic mean
#'
#' @param data Non-empty numeric vector
#' @return numeric
#' @examples
#' si_mean(c(1, 2, 3, 4, 5))
#' @export
si_mean <- function(data) {
  if (length(data) == 0) {
    stop("data must not be empty", call. = FALSE)
  }
  sum(data) / length(data)
}

#' Variance
#'
#' \deqn{var = \sum (x_i - \bar{x})^2 / (n - ddof)}
#'
#' @param data Numeric vector
#' @param ddof Delta degrees of freedom. \code{ddof = 0} gives the
#' population variance (divide by N); \code{ddof = 1} gives the sample
#' variance (divide by N-1, Bessel's correction)
#' @return numeric
#' @examples
#' si_variance(c(2, 4, 4, 4, 5, 5, 7, 9))
#' si_variance(c(2, 4, 4, 4, 5, 5, 7, 9), ddof = 1)
#' @export
si_variance <- function(data, ddof = 0) {
  n <- length(data)
  if (n <= ddof) {
    stop("not enough data points for the given ddof", call. = FALSE)
  }
  m <- si_mean(data)
  sum((data - m)^2) / (n - ddof)
}

#' Standard deviation
#'
#' \code{sqrt(si_variance(data, ddof))}
#'
#' @inheritParams si_variance
#' @return numeric
#' @examples
#' si_std_dev(c(2, 4, 4, 4, 5, 5, 7, 9))
#' @export
si_std_dev <- function(data, ddof = 0) {
  sqrt(si_variance(data, ddof))
}


#' Sample covariance
#'
#' \deqn{cov(X,Y) = \sum (x_i - \bar{x})(y_i - \bar{y}) / (n - ddof)}
#'
#' @param x Numeric vector
#' @param y Numeric vector of equal length
#' @param ddof Delta degrees of freedom (default 1, sample covariance)
#' @return numeric
#' @examples
#' si_covariance(c(1, 2, 3), c(4, 5, 6))
#' @export
si_covariance <- function(x, y, ddof = 1) {
  if (length(x) != length(y)) {
    stop("x and y must have the same length", call. = FALSE)
  }
  n <- length(x)
  if (n <= ddof) {
    stop("not enough data points for the given ddof", call. = FALSE)
  }
  mx <- si_mean(x)
  my <- si_mean(y)
  sum((x - mx) * (y - my)) / (n - ddof)
}

#' Pearson correlation coefficient
#'
#' \deqn{r = cov(X,Y) / (std(X) \cdot std(Y))}
#'
#' @param x Numeric vector
#' @param y Numeric vector of equal length
#' @return numeric in \eqn{[-1, 1]}
#' @examples
#' si_correlation(c(1, 2, 3), c(4, 5, 6))
#' @export
si_correlation <- function(x, y) {
  sx <- si_std_dev(x, ddof = 1)
  sy <- si_std_dev(y, ddof = 1)
  if (sx == 0 || sy == 0) {
    stop("correlation is undefined when a series has zero variance", call. = FALSE)
  }
  si_covariance(x, y, ddof = 1) / (sx * sy)
}

                                        #============================
                                        # Special functions
                                        #=====================
#' Error function
#'
#' \deqn{erf(x) = (2/\sqrt{\pi}) \int_0^x e^{-t^2} dt}
#'
#' Horner-form rational approximation (Abramowitz & Stegun 7.1.26,
#' max absolute error < 1.5e-7). \code{x == 0} is special-cased to return
#' exactly \code{0.0}: the published coefficients sum to
#' \code{0.999999999} rather than exactly 1, which otherwise leaves a
#' ~1e-9 floating point artifact at zero.
#'
#' @param x numeric
#' @return numeric in (-1, 1)
#' @examples
#' si_erf(0)
#' si_erf(1)
#' @export
si_erf <- function(x) {
  if (x == 0) {
    return(0.0)
  }
  a1 <- 0.254829592
  a2 <- -0.284496736
  a3 <- 1.421413741
  a4 <- -1.453152027
  a5 <- 1.061405429
  p <- 0.3275911

  sgn <- if (x < 0) -1 else 1
  ax <- abs(x)

  t <- 1 / (1 + p * ax)
  poly <- t * (a1 + t * (a2 + t * (a3 + t * (a4 + t * a5))))
  y <- 1 - poly * exp(-ax^2)

  sgn * y
}

#' Gamma function
#'
#' Lanczos approximation (g = 7, 9 coefficients, relative error < 1e-13).
#'
#' Key identities: \eqn{\Gamma(n) = (n - 1)!} for positive integers,
#' \eqn{\Gamma(x+1) = x \Gamma(x)}, \eqn{\Gamma(0.5) = \sqrt{\pi}}
#'
#' @param x numeric, must be > 0 (or a non-integer negative, via the
#' reflection formula)
#' @return numeric
#' @examples
#' si_gamma(1)
#' si_gamma(5)
#' si_gamma(0.5)
#' @export
si_gamma <- function(x) {
  g <- 7
  p <- c(
    0.99999999999980993,
    676.5203681218851,
    -1259.1392167224028,
    771.32342877765313,
    -176.61502916214059,
    12.507343278686905,
    -0.13857109526572012,
    9.9843695780195716e-6,
    1.5056327351493116e-7
  )

  if (x == 0 || (x < 0 && x == floor(x))) {
    stop("gamma is undefined at non-positive integers", call. = FALSE)
  }

  if (x < 0.5) {
    return(pi / (sin(pi * x) * si_gamma(1 - x)))
  }

  x <- x - 1
  a <- p[1]
  for (i in 1:8) {
    a <- a + p[i + 1] / (x + i)
  }
  t <- x + g + 0.5
  sqrt(2 * pi) * t^(x + 0.5) * exp(-t) * a
}

#' Inverse std Normal CDF (quantile / percent-point function)
#'
#' Finds \eqn{x} such that \eqn{\Phi(x) = p}, where
#' \eqn{\Phi(x) = 0.5 (1 + erf(x/\sqrt{2}))},
#' via bisection on \eqn{\Phi}
#'
#' @param p Probability in (0, 1)
#' @param tol Convergence tolerance for the bisection
#' @return numeric
#' @examples
#' si_normal_ppf(0.5)
#' round(si_normal_ppf(0.975), 2)
#' @export
si_normal_ppf <- function(p, tol = 1e-9) {
  if (p <= 0 || p >= 1) {
    stop("p must be in (0, 1)", call. = FALSE)
  }
  Phi <- function(z) 0.5 * (1 + si_erf(z / sqrt(2)))
  lo <- -10.0
  hi <- 10.0
  while (hi - lo > tol) {
    mid <- (lo + hi) / 2
    if (Phi(mid) < p) {
      lo <- mid
    } else {
      hi <- mid
    }
  }
  (lo + hi) / 2
}
