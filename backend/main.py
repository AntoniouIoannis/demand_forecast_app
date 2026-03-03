"""
Flask Application for Demand Forecasting.
Exposes endpoints to upload sales data and generate forecasts.
"""

# pylint: disable=broad-exception-caught

import logging
import os

import pandas as pd
from flask import Flask, jsonify, request

# Initialize Flask app
app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@app.route("/", methods=["GET"])
def health_check():
    """Health check endpoint to verify service is running."""
    return "Demand Forecast API is Running!", 200


@app.route("/forecast", methods=["POST"])
def generate_forecast():
    """
    Endpoint to receive sales files (Excel) and generate a demand forecast.
    Expected files: sales2017, sales2018, sales2019
    Expected input columns (mapped by frontend): shipped, product_id, ordered_qty
    """
    try:
        data_frames = []
        years = ["2017", "2018", "2019"]

        # 1. Read and combine files
        for year in years:
            file_key = f"sales{year}"
            file = request.files.get(file_key)

            if file:
                logger.info("Processing file: %s", file.filename)
                try:
                    # Read Excel file
                    df = pd.read_excel(file)

                    # Normalize headers to ensure we find our columns
                    df.columns = [
                        str(c).lower().strip().replace(" ", "_") for c in df.columns
                    ]

                    # Ensure required columns exist
                    required_cols = ["shipped", "product_id", "ordered_qty"]
                    missing = [c for c in required_cols if c not in df.columns]

                    if missing:
                        # Fallback: Try mapping if frontend didn't do it perfectly,
                        # or just skip this file/year if critical data missing.
                        logger.warning(
                            "Missing columns %s in %s. Columns found: %s",
                            missing,
                            file_key,
                            df.columns.tolist(),
                        )
                        continue

                    # Standardize date column
                    try:
                        df["shipped"] = pd.to_datetime(df["shipped"], errors="coerce")
                    except Exception as e:
                        logger.error("Date conversion error in %s: %s", file_key, e)
                        continue

                    # Filter valid rows
                    df = df.dropna(subset=["shipped", "product_id", "ordered_qty"])

                    # Add just in case we need to distinguish source
                    df["source_year"] = year

                    data_frames.append(df)

                except Exception as e:
                    logger.error("Error reading %s: %s", file_key, e)
                    return (
                        jsonify(
                            {"error": f"Failed to read file {file.filename}: {str(e)}"}
                        ),
                        400,
                    )

        if not data_frames:
            return (
                jsonify({"error": "No valid files provided or files are empty."}),
                400,
            )

        # Combine all data
        full_df = pd.concat(data_frames, ignore_index=True)

        if full_df.empty:
            return jsonify({"error": "Combined dataset is empty."}), 400

        # 2. Perform Forecasting Logic
        # -------------------------------------------------------------------------
        # This is a PLACEHOLDER logic. You should replace this section with your
        # actual AI/ML forecasting code (ARIMA, Linear Regression, etc.)
        #
        # Current Logic: Simple Average of Monthly Sales per Product
        # -------------------------------------------------------------------------

        # Extract Month (1-12)
        full_df["month"] = full_df["shipped"].dt.month

        # Group by Product and Month to get average quantity
        # (This averages across 2017, 2018, 2019)
        monthly_avg = (
            full_df.groupby(["product_id", "month"])["ordered_qty"].mean().reset_index()
        )

        # Generate Forecast for next year (e.g., 2020)
        forecast_year = 2020
        results = []

        # Iterate through products and months to build the result
        for _, row in monthly_avg.iterrows():
            product_id = str(row["product_id"])
            month = int(row["month"])
            qty = float(row["ordered_qty"])

            # Format month_year as "YYYY-MM"
            month_str = f"{month:02d}"
            month_year = f"{forecast_year}-{month_str}"

            results.append(
                {
                    "product_id": product_id,
                    "month_year": month_year,
                    "forecast_qty": round(qty, 2),
                }
            )

        # Ensure we have results
        if not results:
            return (
                jsonify(
                    {
                        "message": "Insufficient data to generate forecast.",
                        "results": [],
                    }
                ),
                200,
            )

        # Sort results by product, then date
        results.sort(key=lambda x: (x["product_id"], x["month_year"]))

        logger.info("Generated %d forecast records.", len(results))

        return jsonify({"results": results})

    except Exception as e:
        logger.error("Internal Server Error: %s", e, exc_info=True)
        return jsonify({"error": f"Internal Server Error: {str(e)}"}), 500


if __name__ == "__main__":
    # Local development run
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
