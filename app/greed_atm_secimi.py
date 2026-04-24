import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
from scipy.spatial.distance import cdist # Mesafe (maliyet) hesaplamak için

print("Veriler okunuyor ve Hibrit Algoritma başlatılıyor...")

# 1. Verileri Oku
df_musteriler = pd.read_csv('veri/musteri_verisi.csv')
df_atm = pd.read_csv('veri/atm_adaylari.csv')

# 2. K-Means (Önceki adım - Merkezleri tekrar alıyoruz)
kume_sayisi = 5
musteri_koordinatlar = df_musteriler[['X', 'Y']]
kmeans = KMeans(n_clusters=kume_sayisi, random_state=42, n_init=10)
df_musteriler['Kume'] = kmeans.fit_predict(musteri_koordinatlar)
merkezler = kmeans.cluster_centers_

# 3. GREEDY (AÇGÖZLÜ) YAKLAŞIM
secilen_atmler = []
# Aday ATM koordinatlarını bir listeye alalım
uygun_atmler = df_atm[['X', 'Y']].values.copy() 

print("\n--- Greedy Seçim Sonuçları ---")
for i, merkez in enumerate(merkezler):
    # Merkez ile tüm uygun ATM adayları arasındaki mesafeleri (maliyetleri) hesapla
    mesafeler = cdist([merkez], uygun_atmler)[0]
    
    # En kısa mesafeye (en düşük maliyete) sahip olan ATM'nin indeksini bul
    en_yakin_indeks = np.argmin(mesafeler)
    en_yakin_atm = uygun_atmler[en_yakin_indeks]
    
    # Seçilen ATM'yi kaydet
    secilen_atmler.append({
        'Kume_No': i + 1,
        'Sanal_Merkez_X': merkez[0],
        'Sanal_Merkez_Y': merkez[1],
        'Secilen_ATM_X': en_yakin_atm[0],
        'Secilen_ATM_Y': en_yakin_atm[1],
        'Mesafe_Maliyeti': mesafeler[en_yakin_indeks]
    })
    
    print(f"Bölge {i+1}: Merkeze en yakın ATM seçildi. Maliyet (Mesafe): {mesafeler[en_yakin_indeks]:.2f}")
    
    # Seçilen ATM'yi havuzdan çıkar (Başka bir bölge aynı ATM'yi almasın)
    uygun_atmler = np.delete(uygun_atmler, en_yakin_indeks, axis=0)

# Sonuçları DataFrame'e çevir ve kaydet
df_secilen_atmler = pd.DataFrame(secilen_atmler)
df_secilen_atmler.to_csv('veri/secilen_kesin_atmler.csv', index=False)

# 4. GÖRSELLEŞTİRME (Hocaya Sunulacak Nihai Rapor Grafiği)
plt.figure(figsize=(12, 7))

# Müşteriler (Arka planda soluk)
plt.scatter(df_musteriler['X'], df_musteriler['Y'], c=df_musteriler['Kume'], cmap='viridis', s=10, alpha=0.2, label='Müşteriler')

# Tüm Aday ATM'ler (Gri küçük kareler)
plt.scatter(df_atm['X'], df_atm['Y'], c='gray', marker='s', s=30, alpha=0.5, label='Aday ATM Noktaları (Kurulmayan)')

# K-Means'in İstediği Sanal Merkezler (Kırmızı X)
plt.scatter(merkezler[:, 0], merkezler[:, 1], c='red', marker='X', s=100, label='Sanal Merkezler (K-Means)')

# Greedy'nin Seçtiği Kesin ATM'ler (Büyük Yeşil Yıldızlar)
plt.scatter(df_secilen_atmler['Secilen_ATM_X'], df_secilen_atmler['Secilen_ATM_Y'], 
            c='green', marker='*', s=350, edgecolor='black', label='Kurulan Kesin ATM\'ler (Greedy)')

# Eşleşmeyi Gösteren Çizgiler (Sanal merkezden -> Gerçek ATM'ye)
for index, row in df_secilen_atmler.iterrows():
    plt.plot([row['Sanal_Merkez_X'], row['Secilen_ATM_X']], 
             [row['Sanal_Merkez_Y'], row['Secilen_ATM_Y']], 'k--', linewidth=1.5)

plt.title("Hibrit Algoritma (K-Means + Greedy) ATM Lokasyon Optimizasyonu")
plt.xlabel("X Koordinatı")
plt.ylabel("Y Koordinatı")
plt.legend(loc='lower right')
plt.grid(True, linestyle='--', alpha=0.5)

plt.savefig('veri/hibrit_wlp_sonuc.png')
print("\n✅ Algoritma tamamlandı! Kesin ATM listesi 'veri' klasörüne kaydedildi.")
plt.show()