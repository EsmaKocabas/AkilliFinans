import csv
from pathlib import Path

from backend.database.connection import get_connection

ROOT = Path(__file__).resolve().parent.parent

conn = get_connection()
cur = conn.cursor()

# --- performans_raporu.csv → algorithm_results ---
with (ROOT / "app" / "veri" / "performans_raporu.csv").open(
    newline="", encoding="utf-8"
) as f:
    reader = csv.DictReader(f)
    for row in reader:
        cur.execute("""
            INSERT INTO algorithm_results (
                algorithm_name, n_value,
                hybrid_time_ms, random_time_ms,
                hybrid_cost, random_cost,
                improvement_rate, is_synthetic
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            'hybrid',
            int(row['Musteri_Sayisi (N)']),
            float(row['Hibrit_Sure (sn)']) * 1000,   # sn → ms
            float(row['Random_Sure (sn)']) * 1000,    # sn → ms
            float(row['Hibrit_Maliyet']),
            float(row['Random_Maliyet']),
            float(row['Maliyet_Iyilesmesi (%)']),
            True
        ))

print("✅ performans_raporu aktarıldı")
# --- secilen_kesin_atmler.csv → selected_atms ---
with open("app/veri/secilen_kesin_atmler.csv", newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        cur.execute("""
            INSERT INTO selected_atms (
                cluster_no, virtual_center_x, virtual_center_y,
                selected_atm_x, selected_atm_y, distance_cost
            ) VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            int(row['Kume_No']),
            float(row['Sanal_Merkez_X']),
            float(row['Sanal_Merkez_Y']),
            float(row['Secilen_ATM_X']),
            float(row['Secilen_ATM_Y']),
            float(row['Mesafe_Maliyeti'])
        ))

print("✅ secilen_kesin_atmler aktarıldı")

conn.commit()
cur.close()
conn.close()