import sys
from pathlib import Path

# Dynamically add the project root directory to sys.path to allow execution from any folder
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))

import csv
from backend.database.connection import get_connection

ROOT = Path(__file__).resolve().parent.parent.parent
points_csv = ROOT / "backend" / "veri" / "demand_points.csv"

# Check file existence
if not points_csv.exists():
    print(f"❌ Error: Demand points CSV file not found at {points_csv}")
    exit(1)

conn = get_connection()
cur = conn.cursor()

# --- Import Customer Points ---
print("Importing customer points (with user_id as NULL)...")
cur.execute("SELECT COUNT(*) FROM customer_points;")
before_points = cur.fetchone()[0]
print(f"Current customer points in DB: {before_points}")

points_upsert = """
    INSERT INTO customer_points (point_id, latitude, longitude, transaction_volume, user_id)
    VALUES (%s, %s, %s, %s, NULL)
    ON CONFLICT (point_id)
    DO UPDATE SET
        latitude = EXCLUDED.latitude,
        longitude = EXCLUDED.longitude,
        transaction_volume = EXCLUDED.transaction_volume,
        user_id = NULL;
"""

points_data = []
with open(points_csv, newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        points_data.append((
            int(row["point_id"]),
            float(row["latitude"]),
            float(row["longitude"]),
            int(row["transaction_volume"]),
        ))

# Batch insert
cur.executemany(points_upsert, points_data)
conn.commit()

cur.execute("SELECT COUNT(*) FROM customer_points;")
after_points = cur.fetchone()[0]
print(f"✅ Customer points import finished: Processed {len(points_data)} rows. Total in DB: {after_points}")

cur.close()
conn.close()
