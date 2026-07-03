"""
regression.py
"""
import math
from src.utils import mean, variance, covariance
class SimpleLinearRegression:
    def __init__(self) -> None:
        raise NotImplementedError
    def fit(self, x: list[float], y: list[float]) -> "SimpleLinearRegression":
        raise NotImplementedError
    def predict(self, x: list[float]) -> list[float]:
        raise NotImplementedError
    def residuals(self) -> list[float]:
        raise NotImplementedError
    def r_squared(self) -> float:
        raise NotImplementedError
    def summary(self) -> dict:
        raise NotImplementedError
