import numpy as np
import pandas as pd
import random
from faker import Faker
import hashlib
import os

# Türkçe dil desteği
fake = Faker('tr_TR')

# Yolu tek bir değişkenle yönetelim ki hata payı kalmasın
output_path = 'backend/veri'

if not os.path.exists(output_path):
    os.makedirs(output_path)

print(f"🚀 {output_path} dizinine uyumlu veriler üretiliyor...")

num_users = 1900
num_candidates = 120

# ---------------------------------------------------------
# TABLO 1: users
# ---------------------------------------------------------
users_data = []
for i in range(1, num_users + 1):
    users_data.append([
        i,
        fake.name(),
        fake.unique.email(),
        hashlib.sha256(fake.password().encode()).hexdigest(),
        round(random.uniform(1000, 50000), 2)
    ])
df_users = pd.DataFrame(users_data, columns=['id', 'full_name', 'email', 'password_hash', 'budget'])
df_users.to_csv(f'{output_path}/users.csv', index=False)

# ---------------------------------------------------------
# TABLO 2: demand_points
# ---------------------------------------------------------
bolge_1 = np.random.normal(loc=[38.42, 27.14], scale=[0.02, 0.02], size=(300, 2))
bolge_2 = np.random.normal(loc=[38.45, 27.18], scale=[0.03, 0.03], size=(400, 2))
bolge_3 = np.random.normal(loc=[38.38, 27.10], scale=[0.02, 0.02], size=(300, 2))
bolge_4 = np.random.normal(loc=[38.40, 27.20], scale=[0.03, 0.03], size=(350, 2))
bolge_5 = np.random.normal(loc=[38.48, 27.12], scale=[0.02, 0.02], size=(250, 2))
bolge_6 = np.random.normal(loc=[38.35, 27.15], scale=[0.02, 0.02], size=(300, 2))

koordinatlar = np.vstack([bolge_1, bolge_2, bolge_3, bolge_4, bolge_5, bolge_6])

demand_points_data = []
for i in range(num_users):
    demand_points_data.append([
        i + 1,
        koordinatlar[i][0],
        koordinatlar[i][1],
        random.randint(10, 500),
        i + 1
    ])
df_demand = pd.DataFrame(demand_points_data, columns=['point_id', 'latitude', 'longitude', 'transaction_volume', 'user_id'])
df_demand.to_csv(f'{output_path}/demand_points.csv', index=False)

# ---------------------------------------------------------
# TABLO 3: atm_candidates
# ---------------------------------------------------------
atm_lat = np.random.uniform(low=38.30, high=38.50, size=num_candidates)
atm_lon = np.random.uniform(low=27.05, high=27.25, size=num_candidates)

candidates_data = []
for i in range(num_candidates):
    candidates_data.append([
        i + 1,
        f"Aday_Lokasyon_{i+1}",
        atm_lat[i],
        atm_lon[i],
        round(random.uniform(15000, 35000), 2)
    ])
df_candidates = pd.DataFrame(candidates_data, columns=['candidate_id', 'location_name', 'latitude', 'longitude', 'setup_cost'])
df_candidates.to_csv(f'{output_path}/atm_candidates.csv', index=False)

print(f"✅ Veritabanı ile %100 uyumlu CSV dosyaları {output_path} altına başarıyla oluşturuldu.")