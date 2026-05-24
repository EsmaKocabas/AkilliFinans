import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
from scipy.spatial.distance import cdist

print("Kıyaslama Analizi Başlatılıyor: Hibrit Model vs Random Search\n")

# 1. Verileri Yükle 
df_musteriler = pd.read_csv('backend/veri/demand_points.csv')
df_atm = pd.read_csv('backend/veri/atm_candidates.csv')

# 2. Sütun İsimleri
musteriler = df_musteriler[['latitude', 'longitude']].values
aday_atmler = df_atm[['latitude', 'longitude']].values
kume_sayisi = 5

# TOPLAM MALİYET HESAPLAMA
def toplam_maliyet_hesapla(secilen_atm_koordinatlari):
    """Her müşterinin kendine en yakın ATM'ye olan mesafelerinin toplamını bulur."""
    # cdist, her müşteri ile her ATM arasındaki mesafeyi matris olarak verir
    mesafeler = cdist(musteriler, secilen_atm_koordinatlari)
    # Her müşteri için minimum mesafeyi bul ve topla
    en_kisa_mesafeler = np.min(mesafeler, axis=1)
    return np.sum(en_kisa_mesafeler)

# ==========================================
# 1. YÖNTEM: HİBRİT ALGORİTMA (K-Means + Greedy)
# ==========================================
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

hibrit_maliyeti = toplam_maliyet_hesapla(hibrit_secilenler)
print(f" HİBRİT YÖNTEM TOPLAM MALİYETİ: {hibrit_maliyeti:.2f} birim")

# ==========================================
# 2. YÖNTEM: RANDOM SEARCH (Rastgele Arama)
# ==========================================
deneme_sayisi = 100
random_maliyetler = []

for _ in range(deneme_sayisi):
    # Yeni veri setindeki aday sayısı üzerinden rastgele seçim yapıyoruz
    rastgele_indeksler = np.random.choice(len(aday_atmler), size=kume_sayisi, replace=False)
    rastgele_secilenler = aday_atmler[rastgele_indeksler]
    
    maliyet = toplam_maliyet_hesapla(rastgele_secilenler)
    random_maliyetler.append(maliyet)

random_ortalama_maliyet = np.mean(random_maliyetler)
print(f"⚠️ RANDOM SEARCH ORTALAMA MALİYETİ ({deneme_sayisi} Deneme): {random_ortalama_maliyet:.2f} birim")

# ==========================================
# 3. SONUÇ VE GRAFİK - GÜNCELLENMİŞ GÖRSEL
# ==========================================
iyilesme_orani = ((random_ortalama_maliyet - hibrit_maliyeti) / random_ortalama_maliyet) * 100
print(f"\nSONUÇ: Hibrit algoritma, rastgele seçime göre %{iyilesme_orani:.2f} daha verimlidir!")

yontemler = ['Random Search\n(Ortalama)', 'Hibrit Yöntem\n(K-Means+Greedy)']
maliyetler = [random_ortalama_maliyet, hibrit_maliyeti]

plt.figure(figsize=(9, 6)) 
bar_colors = ['#e74c3c', '#2ecc71']
bars = plt.bar(yontemler, maliyetler, color=bar_colors, width=0.4, edgecolor='black', linewidth=1)

for bar in bars:
    yval = bar.get_height()
    # yval * 0.02 ekleyerek orantılı bir boşluk bırak
    plt.text(bar.get_x() + bar.get_width()/2, yval + (yval * 0.02), 
             f'{yval:.1f}', 
             ha='center', va='bottom', fontweight='bold', fontsize=13)

# Grafiğin üst kısmında rakamların sıkışmaması için limit ekliyoruz
plt.ylim(0, max(maliyetler) * 1.2) 

plt.title("WLP Optimizasyonu: Algoritma Performans Kıyaslaması", fontweight='bold', fontsize=14, pad=20)
plt.ylabel("Toplam Mesafe Maliyeti (Daha düşük daha iyi)", fontsize=11)
plt.grid(axis='y', linestyle='--', alpha=0.6)

# Yeni Yola Kaydet
plt.savefig('backend/veri/algoritma_kiyaslama_raporu.png', bbox_inches='tight', dpi=300)
print(" Geliştirilmiş kıyaslama grafiği 'backend/veri' klasörüne kaydedildi.")
plt.show()