"""distribution.py
three distributions as classes. Each exposees:
pdf(x) / pmf(k) - density or mass at a point
cdf(x or k) - cumulative probability P (X <= x)
mean()  - theoretical mean
variance() - theoretical variance
sample(n) - draw n independent samples using pure python
Dependencies:
src.utils.erf<- NormalDistribution.cdf
src.utils.conmbinations <- BinomialDistribution.pmf
src.utils.factorial   <- PoissonDistribution.pmf
random(built-in)   <- sampling only

Implement in this order:
1: NormalDistribution - uses erf; Box-Muller for sampling
2. BinomialDistribution - uses combinations; bernoulli trials
3. PoissonDistribution - uses factorial; knuth algorithm for sampling
"""
import math
import random
from src.utils import erf, combinations, factorial
# 1. Normal Distribution
class NormalDistribution:
    def __init__(self, mu: float =0.0, sigma: float = 1.0) -> None:
        raise NotImplementedError
    def pdf(self, x: float) -> float:
        raise NotImplementedError
    def cdf(self, x: float) -> float:
        raise NotImplementedError
    def mean(self) -> float:
        raise NotImplementedError
    def variance(self) -> float:
        raise NotImplementedError
    def sample(self, n: int = 1) -> list[float]:
        raise NotImplementedError
# 2. Binomial Distribution
class BinomialDistribution:
    def __init__(self, n: int, p: float) -> None:
        raise NotImplementedError
    def pmf(self, k: int) -> float:
        raise NotImplementedError
    def cdf(self, k: int) -> float:
        raise NotImplementedError
    def mean(self) -> float:
        raise NotImplementedError
    def variance(self) -> float:
        raise NotImplementedError
    def sample(self, n_samples: int = 1) -> list[int]:
        raise NotImplementedError
# 3. Poisson distribution
class PoissonDistribution:
    def __init__(self, lam: float) -> None:
        raise NotImplementedError
    def pmf(self, k: int) -> float:
        raise NotImplementedError
    def cdf(self, k: int) -> float:
        raise NotImplementederror
    def mean(self) -> float:
        raise NotImplementedError
    def variance(self) -> float:
        raise NotImplementedError
    def sample(self, n: int = 1) -> list[int]:
        raise NotImplementedError
