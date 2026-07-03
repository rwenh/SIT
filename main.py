"""
main.py

Usage:
    python main.py
    python main.py --demo dist
    python main.py --demo hypo
    python main.py --demo reg
    python main.py --demo bayes
"""

import argparse


# Demo functions - Implement these after finishing all src/ modules

def run_distributions_demo() -> None:
    """Run the distributions demo."""
    # from src.distributions import (
    #     NormalDistribution,
    #     BinomialDistribution,
    #     PoissonDistribution,
    # )
    print("Distributions demo not implemented yet.")


def run_hypothesis_demo() -> None:
    """Run the hypothesis testing demo."""
    # from src.hypothesis import (
    #     z_test,
    #     one_sample_t_test,
    #     two_sample_t_test,
    #     chi_square_test,
    # )
    print("Hypothesis demo not implemented yet.")


def run_regression_demo() -> None:
    """Run the regression demo."""
    # from src.regression import SimpleLinearRegression
    print("Regression demo not implemented yet.")


def run_bayesian_demo() -> None:
    """Run the Bayesian inference demo."""
    # from src.bayesian import BetaBinomialModel, NormalNormalModel
    print("Bayesian demo not implemented yet.")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Statistical Inference Toolkit - demo runner"
    )

    parser.add_argument(
        "--demo",
        choices=["dist", "hypo", "reg", "bayes", "all"],
        default="all",
        help="Which demo to run (default: all)",
    )

    args = parser.parse_args()

    demos = {
        "dist": run_distributions_demo,
        "hypo": run_hypothesis_demo,
        "reg": run_regression_demo,
        "bayes": run_bayesian_demo,
    }

    if args.demo == "all":
        for name, fn in demos.items():
            print(f"\n{'=' * 50}")
            print(f" {name.upper()} DEMO")
            print(f"{'=' * 50}")
            fn()
    else:
        demos[args.demo]()


if __name__ == "__main__":
    main()
