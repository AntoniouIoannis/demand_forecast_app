"""Data aggregation and preprocessing for forecasting."""

# pylint: disable=import-error

import logging
from typing import Dict

import pandas as pd

logger = logging.getLogger(__name__)


def aggregate_daily_to_weekly(
    df: pd.DataFrame, date_col: str = "shipped", qty_col: str = "ordered_qty"
) -> pd.DataFrame:
    """
    Aggregate daily data to weekly for better model training and reduced computation.

    Args:
        df: DataFrame with daily data
        date_col: Column name for dates
        qty_col: Column name for quantities

    Returns:
        DataFrame aggregated to weekly level
    """
    if date_col not in df.columns or qty_col not in df.columns:
        raise ValueError(f"Required columns '{date_col}' or '{qty_col}' not found")

    df_temp = df.copy()
    df_temp[date_col] = pd.to_datetime(df_temp[date_col], errors="coerce")
    df_temp = df_temp.dropna(subset=[date_col])

    # Group by product and week
    df_temp["year_week"] = df_temp[date_col].dt.isocalendar().to_period("W")

    weekly = (
        df_temp.groupby(["product_id", "year_week"]).agg({qty_col: "sum"}).reset_index()
    )

    weekly[date_col] = weekly["year_week"].dt.to_timestamp()
    weekly = weekly.drop("year_week", axis=1)

    logger.info(
        "Aggregated %s daily records to %s weekly records", len(df), len(weekly)
    )
    return weekly


def aggregate_daily_to_monthly(
    df: pd.DataFrame, date_col: str = "shipped", qty_col: str = "ordered_qty"
) -> pd.DataFrame:
    """
    Aggregate daily data to monthly level.

    Returns aggregated monthly data
    """
    if date_col not in df.columns or qty_col not in df.columns:
        raise ValueError(f"Required columns '{date_col}' or '{qty_col}' not found")

    df_temp = df.copy()
    df_temp[date_col] = pd.to_datetime(df_temp[date_col], errors="coerce")
    df_temp = df_temp.dropna(subset=[date_col])

    df_temp["year_month"] = df_temp[date_col].dt.to_period("M")

    monthly = (
        df_temp.groupby(["product_id", "year_month"])
        .agg({qty_col: "sum"})
        .reset_index()
    )

    monthly[date_col] = monthly["year_month"].dt.to_timestamp()
    monthly = monthly.drop("year_month", axis=1)

    logger.info(
        "Aggregated %s daily records to %s monthly records", len(df), len(monthly)
    )
    return monthly


def calculate_aggregate_stats(df: pd.DataFrame, qty_col: str = "ordered_qty") -> Dict:
    """Calculate statistics on aggregated data."""
    return {
        "total_quantity": float(df[qty_col].sum()),
        "avg_quantity": float(df[qty_col].mean()),
        "std_quantity": float(df[qty_col].std()),
        "min_quantity": float(df[qty_col].min()),
        "max_quantity": float(df[qty_col].max()),
        "record_count": len(df),
    }
