import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
from scipy.spatial.distance import cdist 

print("Veriler okunuyor ve Hibrit Algoritma başlatılıyor...")

#  VERİ YOLLARI VE İSİMLER
df_musteriler = pd.read_csv('backend/veri/demand_points.csv')
df_atm = pd.read_csv('backend/veri/atm_candidates.csv')

# K-Means 
kume_sayisi = 5
# latitude ve longitude sütunlarını kullanarak K-Means kümeleme yapalım
musteri_koordinatlar = df_musteriler[['latitude', 'longitude']]
kmeans = KMeans(n_clusters=kume_sayisi, random_state=42, n_init=10)
df_musteriler['Kume'] = kmeans.fit_predict(musteri_koordinatlar)
merkezler = kmeans.cluster_centers_

# GREEDY YAKLAŞIM
secilen_atmler = []
# Aday ATM koordinatlarını listeye alalım
uygun_atmler = df_atm[['latitude', 'longitude']].values.copy() 

print("\n--- Greedy Seçim Sonuçları ---")
for i, merkez in enumerate(merkezler):
    # Merkez ile tüm uygun ATM adayları arasındaki mesafeleri (maliyetleri) hesapla
    mesafeler = cdist([merkez], uygun_atmler)[0]
    
    # En kısa mesafeye  sahip olan ATM'nin indeksini bul
    en_yakin_indeks = np.argmin(mesafeler)
    en_yakin_atm = uygun_atmler[en_yakin_indeks]
    
    # Seçilen ATM'yi kaydet ve sonuç listesine ekle
    secilen_atmler.append({
        'Kume_No': i + 1,
        'Sanal_Merkez_Lat': merkez[0],
        'Sanal_Merkez_Lng': merkez[1],
        'Secilen_ATM_Lat': en_yakin_atm[0],
        'Secilen_ATM_Lng': en_yakin_atm[1],
        'Mesafe_Maliyeti': mesafeler[en_yakin_indeks]
    })
    
    print(f"Bölge {i+1}: Merkeze en yakın ATM seçildi. Maliyet (Mesafe): {mesafeler[en_yakin_indeks]:.4f}")
    
    # Seçilen ATM'yi çıkar
    uygun_atmler = np.delete(uygun_atmler, en_yakin_indeks, axis=0)

# Sonuçları DataFrame'e çevir ve YENİ YOLA kaydet
df_secilen_atmler = pd.DataFrame(secilen_atmler)
df_secilen_atmler.to_csv('backend/veri/secilen_kesin_atmler.csv', index=False)

# 4. GÖRSELLEŞTİRME 
plt.figure(figsize=(12, 7))

# Müşteriler (latitude, longitude)
plt.scatter(df_musteriler['latitude'], df_musteriler['longitude'], c=df_musteriler['Kume'], cmap='viridis', s=10, alpha=0.2, label='Müşteriler')

# Tüm Aday ATM'ler 
plt.scatter(df_atm['latitude'], df_atm['longitude'], c='gray', marker='s', s=30, alpha=0.5, label='Aday ATM Noktaları (Kurulmayan)')

# K-Means'in İstediği Sanal Merkezler 
plt.scatter(merkezler[:, 0], merkezler[:, 1], c='red', marker='X', s=100, label='Sanal Merkezler (K-Means)')

# Greedy'nin Seçtiği Kesin ATM'ler 
plt.scatter(df_secilen_atmler['Secilen_ATM_Lat'], df_secilen_atmler['Secilen_ATM_Lng'], 
            c='green', marker='*', s=350, edgecolor='black', label='Kurulan Kesin ATM\'ler (Greedy)')

# Eşleşmeyi Gösteren Çizgiler 
for index, row in df_secilen_atmler.iterrows():
    plt.plot([row['Sanal_Merkez_Lat'], row['Secilen_ATM_Lat']], 
             [row['Sanal_Merkez_Lng'], row['Secilen_ATM_Lng']], 'k--', linewidth=1.5)

plt.title("Hibrit Algoritma (K-Means + Greedy) ATM Lokasyon Optimizasyonu (İzmir Koordinatları)")
plt.xlabel("Enlem (Latitude)")
plt.ylabel("Boylam (Longitude)")
plt.legend(loc='lower right')
plt.grid(True, linestyle='--', alpha=0.5)

# Yeni Yola Kaydet 
plt.savefig('backend/veri/hibrit_wlp_sonuc.png')
print("\nAlgoritma tamamlandı! Kesin ATM listesi ve YENİ Grafik 'backend/veri' klasörüne kaydedildi.")
plt.show()