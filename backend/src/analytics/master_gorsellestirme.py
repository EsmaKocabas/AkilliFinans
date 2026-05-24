import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
from scipy.spatial.distance import cdist

print(" Akademik Görselleştirme (Master Plot) Hazırlanıyor")

# 1. VERİLERİ OKU 
df_musteriler = pd.read_csv('backend/veri/demand_points.csv')
df_atm = pd.read_csv('backend/veri/atm_candidates.csv')

# 2. SÜTUN İSİMLERİ
musteriler = df_musteriler[['latitude', 'longitude']].values
aday_atmler = df_atm[['latitude', 'longitude']].values
kume_sayisi = 5

# Algoritmaları Çalıştır 
kmeans = KMeans(n_clusters=kume_sayisi, random_state=42, n_init=10)
df_musteriler['Kume'] = kmeans.fit_predict(musteriler)
merkezler = kmeans.cluster_centers_

secilen_atmler = []
uygun_atmler_kopyasi = aday_atmler.copy()
for merkez in merkezler:
    mesafeler = cdist([merkez], uygun_atmler_kopyasi)[0]
    en_yakin_indeks = np.argmin(mesafeler)
    secilen_atmler.append(uygun_atmler_kopyasi[en_yakin_indeks])
    uygun_atmler_kopyasi = np.delete(uygun_atmler_kopyasi, en_yakin_indeks, axis=0)

secilen_atmler = np.array(secilen_atmler)

# ==========================================
# 3. YAN YANA GÖRSELLEŞTİRME 
# ==========================================
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))
fig.suptitle("Depo Yeri Seçimi (WLP) Optimizasyon Süreci - İzmir Örneği", fontsize=16, fontweight='bold', y=0.95)

# SOL GRAFİK: Sadece K-Means 
ax1.scatter(df_musteriler['latitude'], df_musteriler['longitude'], c=df_musteriler['Kume'], cmap='viridis', s=15, alpha=0.5)
ax1.scatter(merkezler[:, 0], merkezler[:, 1], c='red', marker='X', s=150, linewidths=3, label='Sanal Merkez (K-Means)')
ax1.scatter(aday_atmler[:, 0], aday_atmler[:, 1], c='gray', marker='s', s=20, alpha=0.4, label='Aday Noktalar')
ax1.set_title("(a) Adım 1: Müşteri Kümeleme ve Yoğunluk Merkezleri")
ax1.set_xlabel("Enlem (Latitude)")
ax1.set_ylabel("Boylam (Longitude)")
ax1.legend(loc='lower right')
ax1.grid(True, linestyle='--', alpha=0.5)

# SAĞ GRAFİK: Hibrit Model / Greedy 
ax2.scatter(df_musteriler['latitude'], df_musteriler['longitude'], c=df_musteriler['Kume'], cmap='viridis', s=15, alpha=0.2)
ax2.scatter(merkezler[:, 0], merkezler[:, 1], c='red', marker='X', s=150, linewidths=3)
ax2.scatter(aday_atmler[:, 0], aday_atmler[:, 1], c='gray', marker='s', s=20, alpha=0.4)
ax2.scatter(secilen_atmler[:, 0], secilen_atmler[:, 1], c='green', marker='*', s=400, edgecolor='black', label='Kesin ATM (Greedy)')

# Seçilen ATM ile Merkez arasındaki bağlantı çizgileri
for i in range(kume_sayisi):
    ax2.plot([merkezler[i, 0], secilen_atmler[i, 0]], 
             [merkezler[i, 1], secilen_atmler[i, 1]], 'k--', linewidth=2)

ax2.set_title("(b) Adım 2: Hibrit Algoritma ile Kesin ATM Seçimi")
ax2.set_xlabel("Enlem (Latitude)")
ax2.set_ylabel("Boylam (Longitude)")
ax2.legend(loc='lower right')
ax2.grid(True, linestyle='--', alpha=0.5)

# Grafikleri kaydet 
plt.tight_layout(rect=[0, 0.03, 1, 0.90]) 
plt.savefig('backend/veri/akademik_wlp_sureci.png', dpi=300, bbox_inches='tight') 
print("Yüksek çözünürlüklü master grafik 'backend/veri/akademik_wlp_sureci.png' olarak kaydedildi.")
plt.show()