"""
hyposthesis.py - classical hypothesis tests implemented from scratch
Dep:
src.distributions.normalDistribution <- CDF for p-value computation
src.utils.mean, std_dev <- sample statistics
Implemented in this order:
1._normal_p_value - the shared p-value engine; all tests use it
2. z_test - simplest; plugs straight into _normal_p_value
3. one_sample_t_test - t-statistic; same p-value engine (Normal approx)
4. two_sample_t_test - Welch's formula; same engine
5. chi_square_test - different statistic; Fisher's Normal approximation
"""
import math
from collections import namedtuple
from src.distributions import NormalDistribution
from src.utils import mean, std_dev
HypothesisResult = namedtuple("HypothesisResult", ["statistic", "p_value", "reject_h0"])
#Shared p-value helper
def _normal_p_value(z: float, alternative: str) -> float:
    raise NotImplementedError
# 1. One-sample z-test
def z_test(
        sample: list[float],
        mu0: float,
        sigma: float,
        alternative: str = "two-tailed",
        significance: float = 0.05,
) -> HypothesisResult:
    raise NotImplementedError
# 2. one-sample t-test
def one_sample_t_test(
        sample: list[float],
        mu0: float,
        alternative: str = "two-tailed",
        significance: float = 0.05,
) -> HypothesisResult:
    raise NotImplementedError
# 3 . Two sample t-test (welch's)
def two_sample_t_test(
        sample1: list[float],
        sample2: list[float],
        alternative: str = "two-tailed",
        significance: float = 0.05,
) -> HypothesisResult:
    raise NotImplementedError
# 4. chi - square goodness-of-fit test
def chi_square_test(
        observed: list[int],
        expected: list[float],
        significance: float = 0.05,
) -> HypothesisResult:
    raise NotImplementedError
