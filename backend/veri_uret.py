import numpy as np
import pandas as pd
import random
from faker import Faker
import hashlib
import os

# Türkçe dil desteği
fake = Faker('tr_TR')

if not os.path.exists('veri'):
    os.makedirs('veri')

print(" Veritabanı Şemasına Uygun Veriler Üretiliyor...")

num_users = 1900
num_candidates = 120

# ---------------------------------------------------------
# TABLO 1: users (Müşteri Kimlik ve Finans Bilgileri)
# ---------------------------------------------------------
users_data = []
for i in range(1, num_users + 1):
    users_data.append([
        i,                                              # id
        fake.name(),                                    # full_name
        fake.unique.email(),                            # email
        hashlib.sha256(fake.password().encode()).hexdigest(), # password_hash
        round(random.uniform(1000, 50000), 2)           # budget
    ])
df_users = pd.DataFrame(users_data, columns=['id', 'full_name', 'email', 'password_hash', 'budget'])
df_users.to_csv('veri/users.csv', index=False)

# ---------------------------------------------------------
# TABLO 2: demand_points (İşlem Noktaları ve Koordinatlar)
# ---------------------------------------------------------
# Koordinatları İzmir (38.4, 27.1) çevresinde gerçekçi dağıtıyoruz
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
        i + 1,                         # point_id
        koordinatlar[i][0],            # latitude
        koordinatlar[i][1],            # longitude
        random.randint(10, 500),       # transaction_volume
        i + 1                          # user_id
    ])
df_demand = pd.DataFrame(demand_points_data, columns=['point_id', 'latitude', 'longitude', 'transaction_volume', 'user_id'])
df_demand.to_csv('veri/demand_points.csv', index=False)

# ---------------------------------------------------------
# TABLO 3: atm_candidates (Aday Kurulum Noktaları)
# ---------------------------------------------------------
atm_lat = np.random.uniform(low=38.30, high=38.50, size=num_candidates)
atm_lon = np.random.uniform(low=27.05, high=27.25, size=num_candidates)

candidates_data = []
for i in range(num_candidates):
    candidates_data.append([
        i + 1,                                       # candidate_id
        f"Aday_Lokasyon_{i+1}",                      # location_name
        atm_lat[i],                                  # latitude
        atm_lon[i],                                  # longitude
        round(random.uniform(15000, 35000), 2)       # setup_cost
    ])
df_candidates = pd.DataFrame(candidates_data, columns=['candidate_id', 'location_name', 'latitude', 'longitude', 'setup_cost'])
df_candidates.to_csv('veri/atm_candidates.csv', index=False)

print(" Veritabanı ile %100 uyumlu CSV dosyaları başarıyla oluşturuldu")