import sys
from pathlib import Path

# Dynamically add the project root directory to sys.path to allow execution from any folder
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))

import csv
from backend.database.connection import get_connection

ROOT = Path(__file__).resolve().parent.parent.parent
csv_path = ROOT / "backend" / "veri" / "atm_candidates.csv"

if not csv_path.exists():
    print(f"❌ Error: CSV file not found at {csv_path}")
    exit(1)

print(f"Reading CSV from: {csv_path}")

conn = get_connection()
cur = conn.cursor()

# Get table count before
cur.execute("SELECT COUNT(*) FROM atm_candidates;")
before_count = cur.fetchone()[0]
print(f"Current candidate count in DB: {before_count}")

# Check if candidate_id has primary key or unique constraint to use ON CONFLICT
# We'll use insert or update pattern (UPSERT)
upsert_query = """
    INSERT INTO atm_candidates (candidate_id, location_name, latitude, longitude, setup_cost, cash_capacity, last_updated)
    VALUES (%s, %s, %s, %s, %s, %s, NOW())
    ON CONFLICT (candidate_id) 
    DO UPDATE SET 
        location_name = EXCLUDED.location_name,
        latitude = EXCLUDED.latitude,
        longitude = EXCLUDED.longitude,
        setup_cost = EXCLUDED.setup_cost,
        last_updated = NOW();
"""

candidates_data = []
with open(csv_path, newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        # Default cash_capacity to None since it's not in CSV
        cash_capacity = None
        candidates_data.append((
            int(row["candidate_id"]),
            row["location_name"],
            float(row["latitude"]),
            float(row["longitude"]),
            float(row["setup_cost"]),
            cash_capacity,
        ))

# Batch insert
cur.executemany(upsert_query, candidates_data)
conn.commit()

# Get table count after
cur.execute("SELECT COUNT(*) FROM atm_candidates;")
after_count = cur.fetchone()[0]

cur.close()
conn.close()

print(f"✅ Successfully processed {len(candidates_data)} rows.")
print(f"Candidate count in DB after import: {after_count}")
