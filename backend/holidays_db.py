"""SQLite-backed holiday events database utilities."""

import os
import sqlite3
from typing import Any

EVENT_TYPES = {"religious", "national", "shopping", "seasonal", "health"}
DEFAULT_DB_PATH = os.path.join(os.path.dirname(__file__), "data", "holidays.db")


def _read_sql_file(filename: str) -> str:
    sql_path = os.path.join(os.path.dirname(__file__), "sql", filename)
    with open(sql_path, "r", encoding="utf-8") as sql_file:
        return sql_file.read()


def _get_db_path() -> str:
    configured_path = os.environ.get("HOLIDAYS_DB_PATH", "").strip()
    return configured_path or DEFAULT_DB_PATH


def get_connection() -> sqlite3.Connection:
    db_path = _get_db_path()
    os.makedirs(os.path.dirname(db_path), exist_ok=True)
    connection = sqlite3.connect(db_path)
    connection.row_factory = sqlite3.Row
    return connection


def init_holidays_db(logger=None) -> None:
    schema_sql = _read_sql_file("holidays_schema.sql")
    seed_sql = _read_sql_file("holidays_seed.sql")

    with get_connection() as connection:
        connection.executescript(schema_sql)

        existing_count = connection.execute(
            "SELECT COUNT(*) AS total FROM holidays"
        ).fetchone()["total"]

        if existing_count == 0:
            connection.executescript(seed_sql)
            if logger:
                logger.info("Holiday DB initialized with seed records.")


def query_holidays(
    country_code: str | None = None,
    event_type: str | None = None,
    category: str | None = None,
    from_date: str | None = None,
    to_date: str | None = None,
    limit: int = 200,
) -> list[dict[str, Any]]:
    if limit <= 0:
        limit = 200
    limit = min(limit, 1000)

    base_query = """
        SELECT
            id,
            country_code,
            event_name,
            event_type,
            start_date,
            end_date,
            importance_weight,
            category
        FROM holidays
        WHERE 1=1
    """

    params: list[Any] = []

    if country_code:
        base_query += " AND country_code = ?"
        params.append(country_code.upper())

    if event_type:
        normalized_type = event_type.lower()
        if normalized_type not in EVENT_TYPES:
            raise ValueError(
                f"event_type must be one of: {', '.join(sorted(EVENT_TYPES))}"
            )
        base_query += " AND event_type = ?"
        params.append(normalized_type)

    if category:
        base_query += " AND category = ?"
        params.append(category)

    if from_date:
        base_query += " AND end_date >= ?"
        params.append(from_date)

    if to_date:
        base_query += " AND start_date <= ?"
        params.append(to_date)

    base_query += " ORDER BY start_date, country_code, event_name LIMIT ?"
    params.append(limit)

    with get_connection() as connection:
        rows = connection.execute(base_query, params).fetchall()

    return [dict(row) for row in rows]
