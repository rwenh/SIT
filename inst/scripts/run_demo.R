#!/usr/bin/env Rscript
# run_demo.R -- Demo CLI for the statinfer package (R port)
#
# Usage (after installing the statinfer package):
#   Rscript run_demo.R                    # run all four demos in sequence
#   Rscript run_demo.R --demo dist       # distribution sampling & properties
#   Rscript run_demo.R --demo hypo       # hypothesis testing examples
#   Rscript run_demo.R --demo reg        # linear regression fit and summary
#   Rscript run_demo.R --demo bayes      # Bayesian updating examples
#
# This is a thin CLI wrapper around the package's demo() topics
# (see demo/00Index); it is the R equivalent of the Python main.py --demo
# interface.

suppressPackageStartupMessages(library(statinfer))

args <- commandArgs(trailingOnly = TRUE)

demo_choice <- "all"
if (length(args) >= 2 && args[1] == "--demo") {
  demo_choice <- args[2]
} else if (length(args) == 1 && args[1] %in% c("-h", "--help")) {
  cat("Usage: Rscript run_demo.R [--demo dist|hypo|reg|bayes|all]\n")
  quit(status = 0)
} else if (length(args) == 1 && args[1] == "--demo") {
  stop("--demo requires a value: dist, hypo, reg, bayes or all", call. = FALSE)
}

valid <- c("dist", "hypo", "reg", "bayes", "all")
if (!demo_choice %in% valid) {
  stop(sprintf("--demo must be one of: %s", paste(valid, collapse = ", ")),
       call. = FALSE)
}

topics <- c(dist = "distributions", hypo = "hypothesis",
            reg = "regression", bayes = "bayesian")

run_one <- function(key) {
  cat(sprintf("\n%s\n  %s DEMO\n%s\n",
              strrep("=", 50), toupper(key), strrep("=", 50)))
  demo(topics[[key]], package = "statinfer", character.only = TRUE,
       ask = FALSE, echo = FALSE)
}

if (demo_choice == "all") {
  for (key in names(topics)) run_one(key)
} else {
  run_one(demo_choice)
}
