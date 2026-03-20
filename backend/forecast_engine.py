"""Forecast engine with linear regression and model reuse."""

# pylint: disable=import-error

import logging
from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional

import numpy as np
import pandas as pd
from data_aggregation import aggregate_daily_to_weekly, calculate_aggregate_stats
from model_manager import cache_model, get_model, upload_model_to_gcs
from sklearn.linear_model import LinearRegression

logger = logging.getLogger(__name__)


def prepare_features_for_regression(
    df: pd.DataFrame, date_col: str = "shipped", qty_col: str = "ordered_qty"
) -> tuple[np.ndarray, np.ndarray]:
    """
    Prepare features (X) and target (y) for linear regression.

    X = days since start
    y = quantity
    """
    df_temp = df.copy().sort_values(date_col)
    df_temp[date_col] = pd.to_datetime(df_temp[date_col])

    min_date = df_temp[date_col].min()
    df_temp["days_since_start"] = (df_temp[date_col] - min_date).dt.days

    X = df_temp[["days_since_start"]].values
    y = df_temp[qty_col].values

    return X, y


def train_or_load_model(
    df: pd.DataFrame,
    country_code: str,
    market: str,
    force_retrain: bool = False,
    date_col: str = "shipped",
    qty_col: str = "ordered_qty",
) -> Optional[LinearRegression]:
    """
    Train a linear regression model or load cached version.

    Args:
        df: Training data
        country_code: Country code for model identification
        market: Market name for model identification
        force_retrain: If True, ignore cache and retrain
        date_col: Date column name
        qty_col: Quantity column name

    Returns:
        Trained LinearRegression model or None if failed
    """

    # Try to load cached model unless forced retrain
    if not force_retrain:
        model = get_model(country_code, market, version="latest")
        if model is not None:
            logger.info("Loaded cached model for %s/%s", country_code, market)
            return model

    # Train new model
    try:
        X, y = prepare_features_for_regression(df, date_col, qty_col)

        if len(X) < 3:
            logger.warning(
                "Insufficient training data (%s records) for %s/%s",
                len(X),
                country_code,
                market,
            )
            return None

        model = LinearRegression()
        model.fit(X, y)

        # Cache the model
        cache_model(country_code, market, model, version="latest")

        # Try to upload to GCS
        upload_model_to_gcs(country_code, market, model, version="latest")

        logger.info(
            "Trained and cached model for %s/%s with R²=%.4f",
            country_code,
            market,
            model.score(X, y),
        )
        return model

    except (ValueError, TypeError, RuntimeError, ArithmeticError) as e:
        logger.error("Failed to train model for %s/%s: %s", country_code, market, e)
        return None


def forecast_periods(
    model: LinearRegression,
    df: pd.DataFrame,
    periods: int = 12,
    date_col: str = "shipped",
) -> List[Dict[str, Any]]:
    """
    Generate forecast for N future periods using trained model.

    Args:
        model: Trained LinearRegression model
        df: Historical data (used to establish trend)
        periods: Number of periods to forecast
        date_col: Date column name

    Returns:
        List of forecast records
    """
    if model is None or len(df) == 0:
        logger.warning("Cannot forecast: invalid model or empty data")
        return []

    try:
        df_temp = df.copy().sort_values(date_col)
        df_temp[date_col] = pd.to_datetime(df_temp[date_col])

        min_date = df_temp[date_col].min()
        last_date = df_temp[date_col].max()

        # Days offset for last known value
        last_days_since_start = (last_date - min_date).days

        forecasts = []
        current_date = last_date + timedelta(days=7)  # Start from next week

        for i in range(1, periods + 1):
            days_since_start = last_days_since_start + (i * 7)  # Weekly step

            X_future = np.array([[days_since_start]])
            predicted_qty = model.predict(X_future)[0]

            # Ensure non-negative forecast
            predicted_qty = max(predicted_qty, 0.0)

            forecasts.append(
                {
                    "forecast_date": current_date.isoformat().split("T")[0],
                    "forecast_qty": round(float(predicted_qty), 2),
                    "days_ahead": i * 7,
                }
            )

            current_date += timedelta(days=7)

        logger.info("Generated %s forecast periods", len(forecasts))
        return forecasts

    except (ValueError, TypeError, RuntimeError, ArithmeticError) as e:
        logger.error("Failed to generate forecast: %s", e)
        return []


def run_optimized_forecast(
    df: pd.DataFrame,
    country_code: str,
    market: str,
    forecast_periods_count: int = 12,
    use_aggregation: bool = True,
) -> Dict[str, Any]:
    """
    Run complete optimized forecast pipeline.

    1. Aggregate daily → weekly
    2. Train or load model
    3. Generate forecast
    4. Return results with metadata

    Args:
        df: Daily sales data
        country_code: Country code
        market: Market segment
        forecast_periods_count: Number of periods to forecast
        use_aggregation: Use weekly aggregation if True

    Returns:
        Dictionary with forecast results and metadata
    """

    try:
        # Step 1: Aggregation
        if use_aggregation:
            df_train = aggregate_daily_to_weekly(df)
            logger.info("Using weekly aggregated data for training")
        else:
            df_train = df.copy()
            logger.info("Using daily data for training (no aggregation)")

        # Calculate stats on aggregated data
        stats = calculate_aggregate_stats(df_train)

        # Step 2: Train or load model
        model = train_or_load_model(df_train, country_code, market)

        if model is None:
            return {
                "status": "failed",
                "error": "Failed to train or load model",
                "results": [],
                "metadata": {
                    "country_code": country_code,
                    "market": market,
                    "timestamp": datetime.now().isoformat(),
                },
            }

        # Step 3: Generate forecast
        forecasts = forecast_periods(model, df_train, periods=forecast_periods_count)

        # Step 4: Compile results
        return {
            "status": "success",
            "results": forecasts,
            "metadata": {
                "country_code": country_code,
                "market": market,
                "training_records": len(df_train),
                "original_records": len(df),
                "aggregation_used": use_aggregation,
                "forecast_periods": forecast_periods_count,
                "model_r_squared": round(
                    model.score(*prepare_features_for_regression(df_train)), 4
                ),
                "training_stats": stats,
                "timestamp": datetime.now().isoformat(),
            },
        }

    except (ValueError, TypeError, RuntimeError, ArithmeticError) as e:
        logger.error("Forecast pipeline failed: %s", e)
        return {
            "status": "failed",
            "error": str(e),
            "results": [],
            "metadata": {
                "country_code": country_code,
                "market": market,
                "timestamp": datetime.now().isoformat(),
            },
        }
