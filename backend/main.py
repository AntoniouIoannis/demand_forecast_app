"""
Flask Application for Demand Forecasting.
Exposes endpoints to upload sales data and generate forecasts.
"""

# pylint: disable=broad-exception-caught,import-error

import base64
import json
import logging
import os
import tempfile

import pandas as pd
from flask import Flask, request
from google.cloud import firestore, storage

# Initialize Flask app
app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Google Cloud clients
try:
    STORAGE_CLIENT = storage.Client()
    DB = firestore.Client()
except Exception as e:
    logger.warning("Could not initialize GCP clients: %s", e)
    STORAGE_CLIENT = None
    DB = None


@app.route("/", methods=["GET"])
def health_check():
    """Health check endpoint to verify service is running."""
    return "Demand Forecast API is Running!", 200


@app.route("/pubsub", methods=["POST"])
def receive_pubsub_message():
    """Handle Pub/Sub push messages."""
    envelope = request.get_json()
    if not envelope:
        return "No Pub/Sub message received", 400

    if "message" not in envelope:
        return "Invalid Pub/Sub message format", 400

    pubsub_message = envelope["message"]

    if "data" not in pubsub_message:
        return "No data in message", 400

    try:
        data_str = base64.b64decode(pubsub_message["data"]).decode("utf-8")
        event_data = json.loads(data_str)

        # Check if this is a Cloud Storage notification
        if "bucket" in event_data and "name" in event_data:
            return process_storage_event(event_data)
        else:
            logger.info("Ignoring non-storage event: %s", event_data)
            return "Ignored", 200

    except Exception as e:
        logger.error("Error processing message: %s", e)
        return "Error", 500


def process_storage_event(data):
    """
    Process GCS notification.
    Trigger object: ready/{userId}/{uploadId}/READY.json
    Input files: staging/{userId}/{uploadId}/sales2017.xlsx|sales2018.xlsx|sales2019.xlsx
    """
    if not STORAGE_CLIENT or not DB:
        logger.error("GCP clients not initialized.")
        return "Service Unavailable", 503

    bucket_name = data["bucket"]
    file_path = data["name"]

    logger.info("Processing file event: gs://%s/%s", bucket_name, file_path)

    # Process only the final ready marker event.
    parts = file_path.split("/")
    if len(parts) < 4:
        logger.warning("File path %s does not match expected structure.", file_path)
        return "Ignored", 200

    if parts[0] != "ready" or parts[-1] != "READY.json":
        logger.info("Ignoring non-ready object event: %s", file_path)
        return "Ignored", 200

    user_id = parts[1]
    upload_id = parts[2]
    folder_path = f"staging/{user_id}/{upload_id}"

    # Check for completion of set (2017, 2018, 2019)
    bucket = STORAGE_CLIENT.bucket(bucket_name)
    blobs = list(bucket.list_blobs(prefix=folder_path))
    filenames = [b.name.split("/")[-1] for b in blobs]

    required_files = ["sales2017.xlsx", "sales2018.xlsx", "sales2019.xlsx"]
    missing = [f for f in required_files if f not in filenames]

    if missing:
        logger.info("Request incomplete in %s. Waiting for %s", folder_path, missing)
        return "Waiting", 200

    logger.info("All files present in %s. Starting forecast.", folder_path)

    doc_ref = DB.collection("forecasts").document(upload_id)
    doc_ref.set(
        {
            "userId": user_id,
            "uploadId": upload_id,
            "createdAt": firestore.SERVER_TIMESTAMP,
            "status": "processing",
            "source": folder_path,
        },
        merge=True,
    )

    try:
        results = run_forecast_logic(bucket, folder_path, required_files)

        # Save a durable results artifact in the received-files bucket.
        results_bucket_name = os.environ.get("RESULTS_BUCKET", "bucket-received-files")
        results_bucket = STORAGE_CLIENT.bucket(results_bucket_name)
        results_object_path = f"results/{user_id}/{upload_id}/forecast_results.json"
        results_blob = results_bucket.blob(results_object_path)
        results_blob.upload_from_string(
            json.dumps(
                {
                    "userId": user_id,
                    "uploadId": upload_id,
                    "source": folder_path,
                    "results": results,
                },
                ensure_ascii=False,
            ),
            content_type="application/json",
        )

        # Save results to Firestore
        doc_ref.set(
            {
                "userId": user_id,
                "uploadId": upload_id,
                "status": "completed",
                "results": results,
                "source": folder_path,
                "resultsBucket": results_bucket_name,
                "resultsObject": results_object_path,
                "completedAt": firestore.SERVER_TIMESTAMP,
            },
            merge=True,
        )
        logger.info("Forecast saved to Firestore: forecasts/%s", upload_id)

    except Exception as e:
        logger.error("Forecast failed: %s", e)
        doc_ref.set(
            {
                "status": "failed",
                "error": str(e),
                "failedAt": firestore.SERVER_TIMESTAMP,
            },
            merge=True,
        )
        return "Failed", 500

    return "Processed", 200


def run_forecast_logic(bucket, folder_path, files):
    """Load the mapped yearly files from Cloud Storage and build forecast rows."""
    data_frames = []

    with tempfile.TemporaryDirectory() as tmpdirname:
        for filename in files:
            blob_path = f"{folder_path}/{filename}"
            blob = bucket.blob(blob_path)
            local_path = os.path.join(tmpdirname, filename)
            blob.download_to_filename(local_path)

            # Identify year from filename
            year = filename.replace("sales", "").replace(".xlsx", "")

            try:
                df = pd.read_excel(local_path)

                # Normalize headers
                df.columns = [
                    str(c).lower().strip().replace(" ", "_") for c in df.columns
                ]

                required = ["shipped", "product_id", "ordered_qty"]
                for col in required:
                    if col not in df.columns:
                        raise ValueError(f"Missing column '{col}' in {filename}")

                df["shipped"] = pd.to_datetime(df["shipped"], errors="coerce")
                df = df.dropna(subset=required)
                df["source_year"] = year
                data_frames.append(df)

            except Exception as e:
                logger.error("Error processing %s: %s", filename, e)
                raise

    if not data_frames:
        raise ValueError("No data frames created")

    full_df = pd.concat(data_frames, ignore_index=True)

    # Logic (Same as before)
    full_df["month"] = full_df["shipped"].dt.month
    monthly_avg = (
        full_df.groupby(["product_id", "month"])["ordered_qty"].mean().reset_index()
    )

    forecast_year = 2020
    results = []

    for _, row in monthly_avg.iterrows():
        results.append(
            {
                "product_id": str(row["product_id"]),
                "month_year": f"{forecast_year}-{int(row['month']):02d}",
                "forecast_qty": round(float(row["ordered_qty"]), 2),
            }
        )

    # Sort results
    results.sort(key=lambda x: (x["product_id"], x["month_year"]))
    return results


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
