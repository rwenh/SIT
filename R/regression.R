#' Ordinary Least Squares linear regression from scratch
#'
#' @description
#' Model: \eqn{\hat{y} = slope \cdot x + intercept}
#'
#' Closed-form OLS solution:
#' \deqn{slope = cov(x, y) / var(x)}
#' \deqn{intercept = \bar{y} - slope \cdot \bar{x}}
#' (both sample statistics, ddof = 1)
#'
#' Coefficient of determination:
#' \deqn{R^2 = 1 - SS_{res} / SS_{tot}}
#'
#' Depends on \code{\link{si_mean}}, \code{\link{si_variance}},
#' and \code{\link{si_covariance}} from utils.R
#' @export
#' @examples
#' model <- SimpleLinearRegression$new()$fit(c(1, 2, 3, 4, 5), c(2, 4, 6, 8, 10))
#' model$slope
#' model$intercept
#' model$predict(c(3.5, 4.0))
#' model$r_squared()
SimpleLinearRegression <- R6::R6Class("SimpleLinearRegression",
  public = list(
    #' @field slope Fitted slope, or NULL before \code{fit()}
    slope = NULL,
    #' @field intercept Fitted intercept, or NULL before \code{fit()}
    intercept = NULL,

    #' @description Create an unfitted regression model.
    initialize = function() {
      self$slope <- NULL
      self$intercept <- NULL
      private$x_data <- NULL
      private$y_data <- NULL
    },

    #' @description Compute slope and intercept via OLS and store the
    #' training data for later use by \code{residuals()} and
    #' \code{r_squared()}.
    #' @param x Numeric vector
    #' @param y Numeric vector of equal length, \code{length >= 2}
    #' @return \code{self}, invisibly (enables method chaining)
    fit = function(x, y) {
      if (length(x) != length(y)) {
        stop("x and y must have the same length", call. = FALSE)
      }
      if (length(x) < 2) {
        stop("need at least 2 data points", call. = FALSE)
      }
      vx <- si_variance(x, ddof = 1)
      if (vx == 0) {
        stop("variance of x is zero; slope is undefined", call. = FALSE)
      }
      self$slope <- si_covariance(x, y, ddof = 1) / vx
      self$intercept <- si_mean(y) - self$slope * si_mean(x)
      private$x_data <- x
      private$y_data <- y
      invisible(self)
    },

    #' @description Predict \code{y} for new \code{x} values using the
    #' fitted line.
    #' @param x Numeric vector of query points
    #' @return Predicted values \eqn{slope \cdot x + intercept}
    predict = function(x) {
      private$require_fitted("predict")
      self$slope * x + self$intercept
    },

    #' @description Residuals \code{y - y_hat} on the training data.
    residuals = function() {
      private$require_fitted("residuals")
      private$y_data - self$predict(private$x_data)
    },

    #' @description Coefficient of determination \eqn{R^2} on the
    #' training data.
    r_squared = function() {
      private$require_fitted("r_squared")
      y <- private$y_data
      y_hat <- self$predict(private$x_data)
      ss_res <- sum((y - y_hat)^2)
      ss_tot <- sum((y - si_mean(y))^2)
      if (ss_tot == 0) {
        stop("total sum of squares is zero; R-squared is undefined",
             call. = FALSE)
      }
      1 - ss_res / ss_tot
    },

    #' @description A named list summarising the fitted model.
    #' @return A list with elements \code{slope}, \code{intercept},
    #' \code{r_squared} and \code{n}
    summary = function() {
      private$require_fitted("summary")
      list(
        slope = self$slope,
        intercept = self$intercept,
        r_squared = self$r_squared(),
        n = length(private$x_data)
      )
    }
  ),
  private = list(
    x_data = NULL,
    y_data = NULL,
    require_fitted = function(method_name) {
      if (is.null(self$slope)) {
        stop(sprintf("must call fit() before %s()", method_name), call. = FALSE)
      }
    }
  )
)
