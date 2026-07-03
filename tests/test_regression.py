'''
tests/test_regression.py
python -m unittest tests/test_regression.py
'''
import unittest
from src.regression import SimpleLinearRegression
class TestSimpleLinearRegression(unittest.TestCase):
    # fit - slope and intercept
    def test_perfect_fit_slope_zero_intercept(self):
        # y = 2x exactly
        m = SimpleLinearRegression().fit([1, 2, 3, 4, 5], [2, 4, 6, 8, 10])
        self.assertAlmostEqual(m.slope, 2.0, places=9)
        self.assertAlmostEqual(m.intercept, 0.0, places=9)
    def test_nonzero_intercept(self):
        # y = 2x + 1
        m = SimplerLinearRegression().fit([0, 1, 2], [1, 3, 5])
        self.assertAlmostEqual(m.slope, 2.0, places=9)
        self.assertAlmostEqual(m.intercept, 1.0, places=9)
    def test_negative_slope(self):
        # y = -x + 10
        m = SimpleLinearRegression().fit([1, 2, 3, 4, 5], [9, 8, 7, 6, 5])
        self.assertAlmostEqual(m.slope, -1.0, places=9)
        self.assertAlmostEqual(m.intercept, 10.0, places=9)
# fit - error cases
    def test_length_mismatch_raises(self):
        with self.assertRaises(Valueerror):
            SimpleLinearRegression().fit([1, 2, 3], [1, 2])
    def test_too_short_raises(self):
        with self.assertRaises(ValueError):
            SimpleLinearRegression().fit([1], [2])
    def test_constant_x_raises(self):
        # var(x) == 0 -> slope undefined
        with self.assertRaises(ValueError):
            SimpleLinearRegression().fit([3, 3, 3, 3], [1, 2, 3, 4])
# method chaining
    def test_fit_returns_self(self):
        m = SimpleLinearRegression()
        returned = m.fit([1, 2, 3], [2, 4, 6])
        self.assertIs(returned, m)
# predict
    def test_predict_in_sample(self):
        m = SimpleLinearRegression().fit([1, 2, 3], [2, 4, 6])
        self.assertAlmostEqual(m.predict([4])[0], 8.0, places=9)
    def test_predict_multiple_values(self):
        m = SimpleLinearRegression().fit([1, 2, 3], [2, 4, 6])
        preds = m.predict([0, 5])
        self.assertAlmostEqual(preds[0], 0.0, places=9)
        self.assertAlmostEqual(preds[1], 10.0, places=9)
    def test_predict_before_fit_raises(self):
        with self.assertRaises(RuntimeError):
            SimpleLinearRegression().predict([1, 2, 3])
    # residuals
    def test_residuals_perfect_fit_are_zero(self):
        m = SimpleLinearRegression().fit([1, 2, 3, 4, 5], [2, 4, 6, 8, 10])
        for r in m.residuals():
            self.assertAlmostEqual(r, 0.0, places=9)
    def test_residuals_correct_length(self):
        m = SimpleLinearRegression().fit([1, 2, 3, 4], [2, 3, 5, 4])
        self.assertEqual(len(m.residuals()), 4)
    # r_squared
    def test_r_squared_perfect_fit(self):
        m = SimpleLinearRegression().fit([1, 2, 3, 4, 5], [2, 4, 6, 8, 10])
        self.assertAlmostEqual(m.r_squared(), 1.0, places=9)
    def test_r_squared_noisy_data_between_zero_and_one(self):
        # Noisy but still positively correlated
        m = SimpleLinearRegression().fit(
            [1, 2, 3, 4 ,5],
            [2.5, 3.5, 6.5, 8.0, 9.5],
        )
        r2 = m.r_squared()
        self.assertGreater(r2, 0.0)
        self.assertLessEqual(r2, 1.0)
# Summary
    def test_summary_has_correct_keys(self):
        m = SimpleLinearRegression().fit([1, 2, 3, 4, 5], [2, 4, 6, 8, 10])
        keys = set(m.summary().keys())
        self.assertEqual(keys, {'slope', 'intercept', 'r_squared', 'n'})
    def test_summary_n_equals_training_size(self):
        m = SimpleLinearRegression().fit([1, 2, 3, 4, 5], [2, 4, 6, 8, 10])
        self.assertEqual(m.summary()['n'], 5)
    def test_summary_before_fit_raises(self):
        with self.assertRaises(RuntimeError):
            SimpleLinearRegression().summary()
if __name__ == "__main__":
    unittest.main()
