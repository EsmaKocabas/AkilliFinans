import pandas as pd
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans

# 1. YENİ VERİ YOLLARI VE OKUMA
print("İzmir Müşteri Verisi Okunuyor...\n")
# Yol backend/veri/demand_points.csv olarak güncellendi
df = pd.read_csv('backend/veri/demand_points.csv')

# 2. K-MEANS ALGORİTMASINI KUR 
kume_sayisi = 5
kmeans = KMeans(n_clusters=kume_sayisi, random_state=42, n_init=10)

# Müşterileri kümelere ayır (X, Y yerine latitude, longitude kullanıyoruz)
koordinatlar = df[['latitude', 'longitude']]
df['Kume'] = kmeans.fit_predict(koordinatlar)
merkezler = kmeans.cluster_centers_

print(f" {kume_sayisi} adet ideal merkez (ATM noktası) bulundu:\n", merkezler)

# 3. SONUÇLARI GÖRSELLEŞTİR (PROFESYONEL DÜZENLEME)
plt.figure(figsize=(10, 6))

# Müşterileri yeni koordinat isimlerine göre renklendir
plt.scatter(df['latitude'], df['longitude'], c=df['Kume'], cmap='viridis', s=15, alpha=0.5, label='Müşteriler')

# Bulunan Merkezleri X ile işaretle
plt.scatter(merkezler[:, 0], merkezler[:, 1], c='red', marker='X', s=200, linewidths=3, label='İdeal Merkezler (K-Means)')

plt.title("WLP İçin K-Means Müşteri Kümeleme Sonuçları (İzmir)")
plt.xlabel("Enlem (Latitude)")
plt.ylabel("Boylam (Longitude)")
plt.legend()
plt.grid(True, linestyle='--', alpha=0.5)

# 4. YENİ YOLA KAYDET VE GÖSTER
plt.savefig('backend/veri/kmeans_grafik.png', bbox_inches='tight', dpi=300)
print(" Grafik 'backend/veri' klasörüne başarıyla kaydedildi.")
plt.show()