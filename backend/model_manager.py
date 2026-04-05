"""Model management: serialization, caching, and GCS storage."""

import logging
import os
import pickle
from typing import Any, Optional

try:
    from google.cloud import storage as gcs
except ImportError:
    gcs = None

logger = logging.getLogger(__name__)

# Model storage configuration
MODEL_BUCKET = os.environ.get("MODEL_BUCKET", "forecast-models")
LOCAL_MODEL_CACHE = os.environ.get(
    "LOCAL_MODEL_CACHE", os.path.join(os.path.dirname(__file__), "data", "models")
)


def _ensure_cache_dir():
    """Ensure cache directory exists."""
    os.makedirs(LOCAL_MODEL_CACHE, exist_ok=True)


def _get_gcs_client():
    """Get GCS client safely."""
    try:
        return gcs.Client() if gcs else None
    except (OSError, RuntimeError, ValueError, TypeError):
        return None


def get_model_path(country_code: str, market: str, version: str = "latest") -> str:
    """Generate standardized model filename."""
    safe_country = country_code.upper().replace(" ", "_")
    safe_market = market.upper().replace(" ", "_")
    return f"{safe_country}_{safe_market}_{version}.pkl"


def cache_model(
    country_code: str,
    market: str,
    model_data: Any,
    version: str = "latest",
) -> bool:
    """Cache trained model locally."""
    try:
        _ensure_cache_dir()
        model_path = get_model_path(country_code, market, version)
        local_file = os.path.join(LOCAL_MODEL_CACHE, model_path)

        with open(local_file, "wb") as f:
            pickle.dump(model_data, f, protocol=pickle.HIGHEST_PROTOCOL)

        logger.info("Cached model: %s", model_path)
        return True
    except (OSError, pickle.PickleError, ValueError, TypeError) as e:
        logger.error("Failed to cache model: %s", e)
        return False


def load_cached_model(
    country_code: str, market: str, version: str = "latest"
) -> Optional[Any]:
    """Load model from local cache."""
    try:
        model_path = get_model_path(country_code, market, version)
        local_file = os.path.join(LOCAL_MODEL_CACHE, model_path)

        if not os.path.exists(local_file):
            return None

        with open(local_file, "rb") as f:
            model = pickle.load(f)

        logger.info("Loaded cached model: %s", model_path)
        return model
    except (
        OSError,
        pickle.UnpicklingError,
        EOFError,
        AttributeError,
        ValueError,
        TypeError,
    ) as e:
        logger.error("Failed to load cached model: %s", e)
        return None


def upload_model_to_gcs(
    country_code: str,
    market: str,
    model_data: Any,
    version: str = "latest",
) -> bool:
    """Upload trained model to GCS."""
    client = _get_gcs_client()
    if not client:
        logger.warning("GCS client not available. Skipping upload to gs://.")
        return False

    try:
        _ensure_cache_dir()
        model_path = get_model_path(country_code, market, version)
        local_file = os.path.join(LOCAL_MODEL_CACHE, model_path)

        with open(local_file, "wb") as f:
            pickle.dump(model_data, f, protocol=pickle.HIGHEST_PROTOCOL)

        bucket = client.bucket(MODEL_BUCKET)
        blob = bucket.blob(f"models/{model_path}")
        blob.upload_from_filename(local_file)

        logger.info("Uploaded model to gs://%s/models/%s", MODEL_BUCKET, model_path)
        return True
    except (OSError, pickle.PickleError, RuntimeError, ValueError, TypeError) as e:
        logger.error("Failed to upload model to GCS: %s", e)
        return False


def download_model_from_gcs(
    country_code: str, market: str, version: str = "latest"
) -> Optional[Any]:
    """Download model from GCS to local cache."""
    client = _get_gcs_client()
    if not client:
        logger.warning("GCS client not available. Skipping download from gs://.")
        return None

    try:
        _ensure_cache_dir()
        model_path = get_model_path(country_code, market, version)
        local_file = os.path.join(LOCAL_MODEL_CACHE, model_path)

        bucket = client.bucket(MODEL_BUCKET)
        blob = bucket.blob(f"models/{model_path}")

        if not blob.exists():
            logger.info("Model not found in GCS: models/%s", model_path)
            return None

        blob.download_to_filename(local_file)
        logger.info("Downloaded model from gs://%s/models/%s", MODEL_BUCKET, model_path)

        with open(local_file, "rb") as f:
            model = pickle.load(f)

        return model
    except (
        OSError,
        pickle.UnpicklingError,
        EOFError,
        AttributeError,
        RuntimeError,
        ValueError,
        TypeError,
    ) as e:
        logger.error("Failed to download model from GCS: %s", e)
        return None


def get_model(country_code: str, market: str, version: str = "latest") -> Optional[Any]:
    """
    Get model with fallback chain:
    1. Try local cache
    2. Try GCS download
    3. Return None
    """
    model = load_cached_model(country_code, market, version)
    if model is not None:
        return model

    model = download_model_from_gcs(country_code, market, version)
    if model is not None:
        return model

    logger.warning("No model found for %s/%s version %s", country_code, market, version)
    return None
