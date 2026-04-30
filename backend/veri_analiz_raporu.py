import pandas as pd
import numpy as np
import time
from sklearn.cluster import KMeans
from scipy.spatial.distance import cdist

print(" Performans ve Ölçeklenebilirlik Analizi Başlatılıyor\n")

# Test edilecek müşteri sayıları 
veri_boyutlari = [100, 1000, 10000]
kume_sayisi = 5
aday_atm_sayisi = 50

# Sonuçları tutacağımız liste
analiz_sonuclari = []

# Toplam maliyet hesaplama fonksiyonu (latitude/longitude uyumlu)
def toplam_maliyet_hesapla(musteriler, secilen_atmler):
    mesafeler = cdist(musteriler, secilen_atmler)
    en_kisa_mesafeler = np.min(mesafeler, axis=1)
    return np.sum(en_kisa_mesafeler)

# Her N değeri için test yapıyoruz
for n in veri_boyutlari:
    print(f"[{n} Müşteri] için testler çalıştırılıyor...")
    
    # İzmir Sınırlarında Gerçekçi Sentetik Veri Üretimi
    # Enlem: 38.3 - 38.5 | Boylam: 27.0 - 27.2
    musteriler = np.zeros((n, 2))
    musteriler[:, 0] = np.random.uniform(38.3, 38.5, size=n) # latitude
    musteriler[:, 1] = np.random.uniform(27.0, 27.2, size=n) # longitude
    
    aday_atmler = np.zeros((aday_atm_sayisi, 2))
    aday_atmler[:, 0] = np.random.uniform(38.3, 38.5, size=aday_atm_sayisi)
    aday_atmler[:, 1] = np.random.uniform(27.0, 27.2, size=aday_atm_sayisi)
    
    # ==========================================
    #      HİBRİT ALGORİTMA (K-Means + Greedy)
    # ==========================================
    baslangic_zamani_hibrit = time.time()
    
    kmeans = KMeans(n_clusters=kume_sayisi, random_state=42, n_init=10)
    kmeans.fit(musteriler)
    merkezler = kmeans.cluster_centers_
    
    hibrit_secilenler = []
    uygun_atmler_kopyasi = aday_atmler.copy()
    for merkez in merkezler:
        mesafeler_greed = cdist([merkez], uygun_atmler_kopyasi)[0]
        en_yakin_indeks = np.argmin(mesafeler_greed)
        hibrit_secilenler.append(uygun_atmler_kopyasi[en_yakin_indeks])
        uygun_atmler_kopyasi = np.delete(uygun_atmler_kopyasi, en_yakin_indeks, axis=0)
        
    bitis_zamani_hibrit = time.time()
    hibrit_sure = bitis_zamani_hibrit - baslangic_zamani_hibrit
    hibrit_maliyet = toplam_maliyet_hesapla(musteriler, hibrit_secilenler)
    
    # ==========================================
    #         RANDOM SEARCH (Rastgele Seçim)
    # ==========================================
    baslangic_zamani_random = time.time()
    
    # 10 deneme yapıp ortalamasını alıyoruz 
    deneme_sayisi = 10
    random_maliyetler = []
    for _ in range(deneme_sayisi):
        rastgele_indeksler = np.random.choice(aday_atm_sayisi, size=kume_sayisi, replace=False)
        rastgele_secilenler = aday_atmler[rastgele_indeksler]
        random_maliyetler.append(toplam_maliyet_hesapla(musteriler, rastgele_secilenler))
        
    bitis_zamani_random = time.time()
    random_sure = (bitis_zamani_random - baslangic_zamani_random) / deneme_sayisi
    random_maliyet = np.mean(random_maliyetler)
    
    # ==========================================
    #          SONUÇLARI KAYDET
    # ==========================================
    iyilesme = ((random_maliyet - hibrit_maliyet) / random_maliyet) * 100
    
    analiz_sonuclari.append({
        "Musteri_Sayisi (N)": n,
        "Hibrit_Maliyet": round(hibrit_maliyet, 4), # İzmir koordinatları yakın olduğu için hassasiyet artırıldı
        "Random_Maliyet": round(random_maliyet, 4),
        "Maliyet_Iyilesmesi (%)": round(iyilesme, 2),
        "Hibrit_Sure (sn)": round(hibrit_sure, 4),
        "Random_Sure (sn)": round(random_sure, 4)
    })

# DataFrame'e çevir ve YENİ YOLA kaydet
df_analiz = pd.DataFrame(analiz_sonuclari)
df_analiz.to_csv('backend/veri/performans_raporu.csv', index=False)

print("\n ANALİZ TAMAMLANDI! İşte LaTeX Tablosuna Koyacağınız Veriler:")
print("-" * 75)
print(df_analiz.to_string(index=False))
print("-" * 75)
print("Bu tablo 'backend/veri/performans_raporu.csv' olarak da kaydedildi.")