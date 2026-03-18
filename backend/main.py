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
from flask_cors import CORS
from google.cloud import firestore, storage

DEFAULT_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:5000",
    "http://localhost:50544",
    "http://localhost:53551",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:5000",
    "http://127.0.0.1:50544",
    "http://127.0.0.1:53551",
    "https://demand-forecast-ian.web.app",
    "https://demand-forecast-ian.firebaseapp.com",
]


def _get_allowed_origins():
    """Return the configured CORS origin allowlist."""
    configured_origins = os.environ.get("ALLOWED_ORIGINS", "")
    if not configured_origins.strip():
        return DEFAULT_ALLOWED_ORIGINS

    return [
        origin.strip()
        for origin in configured_origins.split(",")
        if origin.strip()
    ]


# Initialize Flask app
app = Flask(__name__)
CORS(
    app,
    resources={r"/*": {"origins": _get_allowed_origins()}},
    methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization"],
)

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
    Input files: staging/{userId}/{uploadId}/mapped_1.xlsx..mapped_3.xlsx
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
    bucket = STORAGE_CLIENT.bucket(bucket_name)

    ready_blob = bucket.blob(file_path)
    try:
        ready_payload = json.loads(ready_blob.download_as_text())
    except Exception as exc:
        logger.error("Failed to parse READY payload for %s: %s", file_path, exc)
        return "Failed to parse READY payload", 500

    uploaded_files = ready_payload.get("files", [])
    expected_files = [
        file_info.get("mappedName")
        for file_info in uploaded_files
        if isinstance(file_info, dict) and file_info.get("mappedName")
    ]

    blobs = list(bucket.list_blobs(prefix=folder_path))
    filenames = [b.name.split("/")[-1] for b in blobs]

    if not expected_files:
        expected_files = sorted(
            filename for filename in filenames if filename.endswith(".xlsx")
        )

    missing = [filename for filename in expected_files if filename not in filenames]

    if missing:
        logger.info("Request incomplete in %s. Waiting for %s", folder_path, missing)
        return "Waiting", 200

    logger.info("All expected files present in %s. Starting forecast.", folder_path)

    doc_ref = DB.collection("forecasts").document(upload_id)
    doc_ref.set(
        {
            "userId": user_id,
            "uploadId": upload_id,
            "createdAt": firestore.SERVER_TIMESTAMP,
            "status": "processing",
            "source": folder_path,
            "sourceFiles": [
                file_info.get("originalName")
                for file_info in uploaded_files
                if isinstance(file_info, dict) and file_info.get("originalName")
            ],
            "filesUploaded": len(expected_files),
        },
        merge=True,
    )

    try:
        results = run_forecast_logic(bucket, folder_path, expected_files)

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
                "sourceFiles": [
                    file_info.get("originalName")
                    for file_info in uploaded_files
                    if isinstance(file_info, dict) and file_info.get("originalName")
                ],
                "filesUploaded": len(expected_files),
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
        return "Forecast failed.", 500

    return "Forecast processed successfully.", 200


def run_forecast_logic(bucket, folder_path, files):
    """Load the mapped yearly files from Cloud Storage and build forecast rows."""
    data_frames = []

    with tempfile.TemporaryDirectory() as tmpdirname:
        for filename in files:
            blob_path = f"{folder_path}/{filename}"
            blob = bucket.blob(blob_path)
            local_path = os.path.join(tmpdirname, filename)
            blob.download_to_filename(local_path)

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
                df["source_file"] = filename
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

    forecast_year = int(full_df["shipped"].dt.year.max()) + 1
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
