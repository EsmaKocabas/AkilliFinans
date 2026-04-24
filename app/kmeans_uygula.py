import pandas as pd
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans

# 1. Ürettiğimiz Müşteri Verisini Oku
print("Veri okunuyor...")
df = pd.read_csv('veri/musteri_verisi.csv')

# 2. K-Means Algoritmasını Kur (5 Farklı ATM/Şube Bölgesi İstediğimizi Varsayalım)
kume_sayisi = 5
kmeans = KMeans(n_clusters=kume_sayisi, random_state=42, n_init=10)

# Müşterileri kümelere ayır
df['Kume'] = kmeans.fit_predict(df)
merkezler = kmeans.cluster_centers_

print(f"✅ {kume_sayisi} adet ideal merkez (ATM noktası) bulundu:\n", merkezler)

# 3. Sonuçları Görselleştir (Bunu Raporuna Ekleyebilirsin)
plt.figure(figsize=(10, 6))

# Müşterileri renklendir
plt.scatter(df['X'], df['Y'], c=df['Kume'], cmap='viridis', s=15, alpha=0.6, label='Müşteriler')

# Bulunan Merkezleri Kırmızı X ile işaretle
plt.scatter(merkezler[:, 0], merkezler[:, 1], c='red', marker='X', s=200, linewidths=3, label='İdeal Merkezler (K-Means)')

plt.title("WLP İçin K-Means Müşteri Kümeleme Sonuçları")
plt.xlabel("X Koordinatı")
plt.ylabel("Y Koordinatı")
plt.legend()
plt.grid(True, linestyle='--', alpha=0.5)

# Grafiği kaydet ve göster
plt.savefig('veri/kmeans_grafik.png')
print("✅ Grafik 'veri' klasörüne kaydedildi.")
plt.show()