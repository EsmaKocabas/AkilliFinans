"""
Import demand_points.csv into customer_points (including user_id).
Seeds missing users from users.csv when required by FK (users 3..N; keeps existing ids 1-2).
"""
import csv
import os
from pathlib import Path

import psycopg
from dotenv import load_dotenv

BACKEND_ROOT = Path(__file__).resolve().parents[3]
load_dotenv(BACKEND_ROOT / ".env")

POINTS_CSV = BACKEND_ROOT / "src/analytics/veri/demand_points.csv"
USERS_CSV = BACKEND_ROOT / "src/analytics/veri/users.csv"


def sanitize_database_url(url: str) -> str:
    """Fix .env typos and drop channel_binding (psycopg/libpq mismatch)."""
    from urllib.parse import parse_qsl, urlencode, urlparse, urlunparse

    url = url.replace("require'", "require")
    parsed = urlparse(url)
    query = urlencode([(k, v) for k, v in parse_qsl(parsed.query) if k != "channel_binding"])
    return urlunparse(parsed._replace(query=query))


def get_connection():
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        raise RuntimeError("DATABASE_URL is not set in backend/.env")
    return psycopg.connect(sanitize_database_url(database_url))


def seed_missing_users(cur) -> int:
    if not USERS_CSV.exists():
        raise FileNotFoundError(f"users.csv not found: {USERS_CSV}")

    cur.execute("SELECT id FROM users;")
    existing_ids = {row[0] for row in cur.fetchall()}

    to_insert = []
    with USERS_CSV.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            user_id = int(row["id"])
            if user_id in existing_ids:
                continue
            to_insert.append(
                (
                    user_id,
                    row["full_name"].strip(),
                    row["email"].strip().lower(),
                    row["password_hash"],
                    float(row["budget"]),
                )
            )

    if not to_insert:
        print("All users from CSV already exist in DB.")
        return 0

    cur.executemany(
        """
        INSERT INTO users (id, full_name, email, password_hash, budget, is_active)
        VALUES (%s, %s, %s, %s, %s, true)
        ON CONFLICT (id) DO NOTHING;
        """,
        to_insert,
    )

    cur.execute("SELECT setval('users_id_seq', COALESCE((SELECT MAX(id) FROM users), 1));")
    print(f"Seeded {len(to_insert)} users from users.csv.")
    return len(to_insert)


def import_customer_points(cur) -> int:
    if not POINTS_CSV.exists():
        raise FileNotFoundError(f"demand_points.csv not found: {POINTS_CSV}")

    points_data = []
    with POINTS_CSV.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            user_id_raw = (row.get("user_id") or "").strip()
            user_id = int(user_id_raw) if user_id_raw else None
            points_data.append(
                (
                    int(row["point_id"]),
                    float(row["latitude"]),
                    float(row["longitude"]),
                    int(row["transaction_volume"]),
                    user_id,
                )
            )

    cur.executemany(
        """
        INSERT INTO customer_points (point_id, latitude, longitude, transaction_volume, user_id)
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (point_id)
        DO UPDATE SET
            latitude = EXCLUDED.latitude,
            longitude = EXCLUDED.longitude,
            transaction_volume = EXCLUDED.transaction_volume,
            user_id = EXCLUDED.user_id;
        """,
        points_data,
    )
    return len(points_data)


def main():
    print(f"Using demand_points: {POINTS_CSV}")
    conn = get_connection()
    cur = conn.cursor()

    try:
        seed_missing_users(cur)
        count = import_customer_points(cur)
        conn.commit()

        cur.execute("SELECT COUNT(*) FROM customer_points WHERE user_id IS NOT NULL;")
        with_user = cur.fetchone()[0]
        cur.execute("SELECT COUNT(*) FROM customer_points;")
        total = cur.fetchone()[0]

        print(f"Imported/updated {count} customer points.")
        print(f"Rows with user_id: {with_user} / {total}")
    except Exception as exc:
        conn.rollback()
        print(f"Import failed: {exc}")
        raise
    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    main()
