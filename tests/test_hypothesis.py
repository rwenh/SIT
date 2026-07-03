'''
tests/test_hypothesis.py
python -m unittest tests/test_hypothesis.py
'''
import unittest
from src.hypothesis import(
    HypothesisResult,
    _normal_p_value,
    z_test,
    one_sample_t_test,
    two_sample_t_test,
    chi_square_test,
)
# _normal_p_value helper
class TestNormalPValue(unittest.TestCase):
    def test_two_tailed_z_zero_gives_one(self):
        # z=0 -> p = 2*(1-0.5) = 1.0
        self.assertAlmostEqual(_normal_p_value(0.0, 'two-tailed'), 1.0, places=4)
    def test_two_tailed_large_z_is_small(self):
        # z=4 -> p << 0.001
        self.assertLess(_normal_p_value(4.0, "two-tailed"), 0.001)
    def test_less_negative_z_is_small(self):
        # z=-2 -> p = \N{GREEK SMALL LETTER PHI}(-2) \N{IDENTICAL TO} 0.023 < 0.05
        self.assertLess(_normal_p_value(-2.0, 'less'), 0.05)
    def test_greater_positive_z_is_small(self):
        # z=2 -> p = 1- \N{GREEK SMALL LETTER PHI}(2) \N{IDENTICAL TO} 0.023 < 0.05
        self.assertLess(_normal_p_value(2.0, 'greater'), 0.05)
    def test_invalid_alternative_raises(self):
        with self.assertRaises(ValueError):
            _normal_p_value(1.0, 'both')
# z_test
class TestZTest(unittest.TestCase):
    def test_reject_clearly_different_mean(self):
        #sample mean =12, mu0=5 -> clearly reject H0
        result = z_test([4.8, 5.1, 5.0, 4.9, 5.2], mu0=5.0, sigma=1.0)
        self.assertFalse(result.reject_h0)
    def test_dont_reject_same_mean(self):
        #Sample mean "\N{IDENTICAL TO}" 5, mu0=5 -> fail to reject H0
        result = z_test([4.8, 5.1, 5.0, 4.9, 5.2], mu0=5.0, sigma=1.0)
        self.assertFalse(result.reject_h0)
    def test_statistic_positive_when_mean_above_mu0(self):
        result = z_test([6, 7, 8], mu0=5.0, sigma=1.0)
        self.assertGreater(result.statistic, 0)
    def test_returns_hypothesis_result_namedtuple(self):
        result = z_test([1, 2, 3, 4, 5], mu0=3.0, sigma=1.0)
        self.assertIsInstance(result, HypothesisResult)
    def test_one_tailed_greater_rejects(self):
        result = z_test([8, 9, 10, 11, 12], mu0=5.0, sigma=2.0, alternative="greater")
        self.assertTrue(result.reject_h0)
    def test_invalid_sigma_raises(self):
        with self.assertRaises(ValueError):
            z_test([1, 2, 3], mu0=2.0, sigma=0.0)
    def test_invalid_sigma_raises(self):
        with self.assertRaises(ValueError):
            z_test([1, 2, 3], mu0=2.0, sigma=0.0)
    def test_empty_sample_raises(self):
        with self.assertRaises(ValueError):
            z_test([], mu0=0.0, sigma=1.0)
# One_sample_t_test
class TestOneSampleTTest(unittest.TestCase):
    def test_reject_clearly_different(self):
        result = one_sample_t_test([20, 21, 22, 23 ,24], mu0=10.0)
        self.assertTrur(result.reject_h0)
    def test_dont_reject_close_to_null(self):
        result = one_sample_t_test([5.0, 5.1, 4.9, 5.05, 4.95], mu0=5.0)
        self.assertFalse(result.reject_h0)
    def test_statistic_positive_when_above_null(self):
        result = one_sample_t_test([6, 7, 8, 9, 10], nu0=5.0)
        self.assertGreater(result.statistic, 0)
    def test_too_short_raises(self):
        with self.assertRaises(ValueError):
            one_sample_t_test([5.0],mu0=5.0)
# Two_sample_t_test
class TestTwoSampleTTest(unittest.TestCase):
    def test_clearly_differently_samples_reject(self):
        result = two_sample_t_test([1, 2, 3, 4, 5], [10, 11, 12, 13, 14])
    def test_sample_population_dont_reject(self):
        result = two_sample_t_test([4.9, 5.0, 5.1, 5.05], [4.8, 5.0, 5.2, 4.95])
        self.assertFalse(result.reject_h0)
    def test_statistic_negative_when_sample1_below_sample2(self):
        result = two_sample_t_test([1, 2, 3], [10, 11, 12])
        self.assertLess(result.statistic, 0)
    def test_short_sample_raises(self):
        with self.assertRaises(ValueError):
            two_sample_t_test([5.0], [4.0, 5.0, 6.0])
# chi_square-test
class TestChiSquareTest(unittest.TestCase):
    def test_uniform_data_dont_reject(self):
        # Perfectly uniform: \N{GREEK SMALL LETTER CHI} = 0 -> do not reject H0
        obs = [20, 20, 20, 20]
        exp = [20.0, 20.0, 20.0, 20.0]
        result = chi_square_test(obs, exp)
        self.assertFalse(result.reject_h0)
    def test_extreme_deviation_rejects(self):
        # All counts in one bucket: \N{GREEK SMALL LETTER CHI} is huge -> reject H0
        obs = [100, 0, 0, 0]
        exp = [25.0, 25.0, 25.0, 25.0]
        result = chi_square_test(obs, exp)
        self.assertTrue(result.reject_h0)
    def test_length_mismatch_raises(self):
        with self.assertRaises(ValueError):
            chi_square_test([1, 2, 3], [1.0, 2.0])
    def test_zero_expected_raises(self):
        with self.assertRaises(ValueError):
            chi_square_test([1, 2], [0.0, 3.0])
if __name__ == "__main__":
    unittest.main()
