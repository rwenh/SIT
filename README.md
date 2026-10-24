# statinfer · Statistical Inference Toolkit (R port)

A from-scratch, pure-R implementation of statistical inference, ported
from an equivalent pure-Python toolkit ("Math-4"). No reliance on base
R's `mean()`, `var()`, `sd()`, `cor()`, `cov()`, `factorial()`,
`choose()`, `gamma()`, `qnorm()`, `lm()`, `t.test()`, etc. for the actual
math — every formula is hand-implemented. R6 classes are used only for
object-oriented structure, mirroring the original Python class design.

Licensed under the **GNU GPL v2** (see `COPYING`).

---

## Package layout

| Path | Contents |
|---|---|
| `DESCRIPTION` | Package metadata; `License: GPL-2` |
| `COPYING` | Full text of the GNU GPL v2 |
| `R/utils.R` | `si_factorial`, `si_combinations`, `si_mean`, `si_variance`, `si_std_dev`, `si_covariance`, `si_correlation`, `si_erf`, `si_gamma`, `si_normal_ppf` |
| `R/distributions.R` | `NormalDistribution`, `BinomialDistribution`, `PoissonDistribution` (R6 classes) |
| `R/hypothesis.R` | `z_test`, `one_sample_t_test`, `two_sample_t_test`, `chi_square_test`, `hypothesis_result` |
| `R/regression.R` | `SimpleLinearRegression` (R6 class) |
| `R/bayesian.R` | `BetaBinomialModel`, `NormalNormalModel` (R6 classes) |
| `demo/` | `00Index` + the four demo scripts (`distributions`, `hypothesis`, `regression`, `bayesian`) |
| `inst/scripts/run_demo.R` | CLI wrapper mirroring the original `main.py --demo` interface |
| `tests/testthat.R` | testthat (edition 3) runner |
| `tests/testthat/test-*.R` | Five test files — **41 `test_that()` blocks, 221 assertions** |

---

## Naming: why `si_` instead of the bare Python names

The Python original defines free functions named `mean`, `variance`,
`gamma`, `factorial`, etc. — safe in Python, since those names collide
with nothing in the standard library used here. In R, `mean()` is an S3
**generic** used pervasively across the ecosystem (`Date`, `POSIXct`,
`data.frame` columns, ...), and `var`, `sd`, `factorial`, `gamma`,
`choose` are all base/stats functions. Re-exporting functions under
those exact names would silently mask them for anyone who runs
`library(statinfer)` alongside other work — a real footgun in an
interactive session.

So the low-level math utilities are prefixed `si_` (Statistical
Inference): `si_mean`, `si_variance`, `si_std_dev`, `si_covariance`,
`si_correlation`, `si_factorial`, `si_combinations`, `si_erf`,
`si_gamma`, `si_normal_ppf`. Everything else — hypothesis tests, R6
class names — keeps the original names, since none of those collide
with anything in base R.

## Classes: R6 instead of Python's built-in classes

R6 gives reference semantics and `self$`/`private$` fields close to
Python's `self.` attributes, so the five classes translate almost
1:1: constructor → `initialize()`, instance state → `private` fields
(with read-only public fields for the constructor-supplied parameters),
methods → public methods. Method chaining
(`SimpleLinearRegression$new()$fit(x, y)$predict(...)`) works the same
way it does in the Python version, via `invisible(self)` returns.

## `HypothesisResult` → `hypothesis_result`

Python's `namedtuple` becomes a small S3 class: a list with
`statistic`, `p_value`, `reject_h0`, plus a `print.hypothesis_result`
method for readable console output.

## Known numerical details

- **`si_erf(0)`**: the Abramowitz & Stegun 7.1.26 rational
  approximation's published coefficients sum to `0.999999999` rather
  than exactly `1`, which leaves a ~1e-9 floating-point artifact at
  `x == 0` (present in this formula regardless of language). `si_erf`
  special-cases `x == 0` to return exactly `0.0`.
- **Normal-approximation p-values**: `one_sample_t_test`,
  `two_sample_t_test` and `chi_square_test` compute p-values via the
  standard Normal CDF (accurate for n >= 30; smaller samples get a
  more conservative exact t-distribution value once Phase 1 of the
  roadmap lands — see below).
- **Binomial/Beta credible intervals**: `BetaBinomialModel` uses a
  Normal approximation clamped to [0, 1]; `NormalNormalModel`'s
  posterior is exactly Normal, so its intervals are exact.

---

## Installing

From the package source directory:

```r
# One-time setup, if not already installed:
install.packages(c("R6", "testthat", "roxygen2", "devtools"))

devtools::install("path/to/statinfer")
# or, from a built tarball:
install.packages("statinfer_0.1.0.tar.gz", repos = NULL, type = "source")
```

## Running the tests

```r
devtools::test("path/to/statinfer")     # from source, during development
# or, once installed:
testthat::test_check("statinfer")
```

The suite is written against independently verified expected values:
every constant was computed from a high-precision reference
implementation, never from the code under test. It includes regression
tests pinning the historically corrupted constants (the erf `a1`
coefficient and the Lanczos `p[4]` coefficient — see the recalibration
log below) and the `%/%` precedence fix in `si_combinations`.

## Running the demos

Each demo is a package `demo/` topic:

```r
library(statinfer)
demo("distributions", package = "statinfer")
demo("hypothesis",    package = "statinfer")
demo("regression",    package = "statinfer")
demo("bayesian",      package = "statinfer")
```

or, from the command line, via the bundled CLI wrapper
(`inst/scripts/run_demo.R`):

```bash
Rscript inst/scripts/run_demo.R                # all four, in sequence
Rscript inst/scripts/run_demo.R --demo dist
Rscript inst/scripts/run_demo.R --demo hypo
Rscript inst/scripts/run_demo.R --demo reg
Rscript inst/scripts/run_demo.R --demo bayes
```

## Building and checking

```r
devtools::document()   # regenerate man/ and NAMESPACE from roxygen
devtools::check()      # full R CMD check
```

---

## Recalibration log (v0.1.0 audit)

The initial port contained parse-time, logic, and constant-corruption
defects, all found and fixed in the v0.1.0 recalibration pass:

| Module | Key fixes |
|---|---|
| `R/utils.R` | `functions(` → `function(`; undefined `lengthA(y)`; `at` → `a1` in erf; `1e - 9` parse error; `%/%` precedence silently returned wrong binomial coefficients; erf constant `a1` restored to published `0.254829592`; Lanczos coefficient `p[4]` restored to `-176.61502916214059` (both had digit-level corruption) |
| `R/distributions.R` | `self * z1` → `self$sigma * z1` (Box–Muller); Binomial guard rejected every valid `p`; `functiono`/`stat::` typos; missing Poisson `variance()` method |
| `R/hypothesis.R` | `print.hypotheis_result` typo (S3 method never registered); `call. FALSE` parse error; chi-square guards (`expected <= 0`, `df >= 2`) |
| `R/regression.R` | slope computed via `si_variance(x, y, ...)` → `si_covariance` |
| `R/bayesian.R` | illegal `²` characters; missing `posterior_mean()`/`posterior_variance()` methods; self-referencing `post_mu_n <- post_mu_n` (posterior never computed); `requie_fitted` typo |
| `demo/`, `inst/scripts/` | undefined `sample_b` in the hypothesis demo; garbled Beta-Binomial update loop; `95%` vs `95%%` in `sprintf`; mislabeled demo prints; CLI `name(topics)` → `names(topics)` |
| `DESCRIPTION` | `Maintainer` email aligned with the `cre` role; `License` field set to `GPL-2` to match the shipped GNU GPL v2 text |

---

## Roadmap: later calibration phases

The project's core constraint is invariant across all future work:
**every formula stays hand-implemented** — no delegating to base R or
`stats` — and low-level additions keep the `si_` prefix. Expansion
happens in calibration phases; each phase follows the protocol at the
bottom of this section.

### Phase 1 — exact inference (replaces the Normal approximations)

- Implement the regularized incomplete gamma function `P(a, x)` (series
  + continued fraction, built on `si_gamma`) as `si_gamma_p`, and the
  regularized incomplete beta `I_x(a, b)` as `si_beta_ix`.
- Exact Student-t and chi-square p-values for the existing tests
  (`t_test` / `chi_square_test` stop routing through
  `.normal_p_value`); paired t-test; F-test for equality of variances.
- Confidence intervals for OLS slope/intercept (requires the t
  quantile function, `si_t_ppf`, built on `si_gamma_p`).

### Phase 2 — distribution library expansion

- Student-t, Chi-square, Exponential, Gamma, and Uniform distributions
  as R6 classes following the same five-method interface
  (`pdf`/`pmf`, `cdf`, `mean`, `variance`, `sample`), with inverse
  CDFs where closed forms exist (Exponential, Uniform) and numerical
  bisection elsewhere, mirroring `si_normal_ppf`.

### Phase 3 — Bayesian expansions

- True Beta-quantile credible intervals for `BetaBinomialModel`
  (replaces the clamped Normal approximation, using `si_beta_ix`).
- Metropolis–Hastings sampler for non-conjugate posteriors.
- Bayesian linear regression via the Normal–Inverse-Gamma conjugate
  model, reusing `SimpleLinearRegression` for the likelihood fit.

### Phase 4 — robustness and scale

- Vectorized `pdf`/`cdf` inputs across all distribution classes.
- Log-space computation for extreme parameters (e.g., Poisson pmf at
  large `k`, Binomial pmf at large `n`) to avoid underflow.
- Optional Rcpp accelerator kept strictly behind the pure-R reference
  implementations, plus a benchmark suite proving numerical parity.

### Phase 5 — packaging and community

- Package vignettes (one per module area), pkgdown site, codecov
  coverage tracking, and a CRAN submission checklist
  (GPL-2 + `COPYING` already satisfy the licensing requirements).

### Calibration protocol (how each phase is recalibrated)

1. **Expected values come from independent references** — high-precision
   external computation, never from the implementation under test.
2. **Structural scans** — parse/bracket balance and undefined-symbol
   sweeps on every touched file.
3. **Cross-consistency** — demos, modules, and tests are checked against
   each other; every demo call must resolve against the current module
   API.
4. **Regression tests pin every fixed constant** — historically
   corrupted values get explicit assertions so they cannot silently
   regress.
5. **Gate on `devtools::document()` + `devtools::check()`** — a phase is
   done only when documentation regenerates cleanly and the full check
   passes.

When adding any function: write the roxygen block (man pages are
auto-generated), add `testthat` cases with independently computed
expectations, wire in a demo where useful, and record the change in
the recalibration log above.