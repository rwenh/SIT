'''
bayesian.py - Bayesian inference via conjugate priors

Model 1: BetaBinomialModel
Model 2: NormalNormalModel
Dependencies:
src.utils.normal_ppf<- credible interval computation
src.utils.mean<- NormalNormalModel.update
'''
import math
from src.utils import normal_ppf, mean as _mean

# 1. Beta-Binomial conjugate model
class BetaBinomialModel:
    def __init__(self, alpha: float = 1.0, beta: float = 1.0) -> None:
        raise NotImplementedError
# Prior moments
    def prior_mean(self) -> float:
        raise NotImplementedError
    def prior_variance(self) -> float:
        raise NotImplementedError
    # Bayesian Update
    def update(self, successes: int, trials: int) -> "BetaBinomialModel":
        raise NotImplementedError
    # Posterior moments
    def posterior_mean(self) -> float:
        raise NotImplementedError
    def posterior_variance(self) -> float:
        raise NotImplementedError
    def credible_interval(self, confidence: float = 0.95) -> tuple[float, float]:
        raise NotImplementedError
    # 2. Normal-Normal conjugate model
class NormalNormalModel:
    def __init__(self, mu0: float, sigma0: float, sigma: float) -> None:
        raise NotImplementedError
    # Prior moments
    def prior_mean(self) -> float:
        raise NotImplementedError
    def prior_variance(self) -> float:
        raise NotImplementedError
    # Bayesian update
    def update(self, data: list[float]) -> "NormalNormalModel":
        raise NotImplementedError
    # Posterior moments
    def posterior_mean(self) -> float:
        raise NotImplementedError
    def posterior_variance(self) -> float:
        raise NotImplementedError
    def posterior_interval(self, confidence: float = 0.95) -> tuple[float, float]:
        raise NotImplementedError
