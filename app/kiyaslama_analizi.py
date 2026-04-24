import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
from scipy.spatial.distance import cdist

print("Kıyaslama Analizi Başlatılıyor: Hibrit Model vs Random Search...\n")

# 1. Verileri Yükle
df_musteriler = pd.read_csv('veri/musteri_verisi.csv')
df_atm = pd.read_csv('veri/atm_adaylari.csv')

musteriler = df_musteriler[['X', 'Y']].values
aday_atmler = df_atm[['X', 'Y']].values
kume_sayisi = 5

# --- FONKSİYON: TOPLAM MALİYET (MESAFE) HESAPLAMA ---
def toplam_maliyet_hesapla(secilen_atm_koordinatlari):
    """Her müşterinin kendine en yakın ATM'ye olan mesafelerinin toplamını bulur."""
    # cdist, her müşteri ile her ATM arasındaki mesafeyi matris olarak verir
    mesafeler = cdist(musteriler, secilen_atm_koordinatlari)
    # Her müşteri için minimum mesafeyi (en yakın ATM'yi) bul ve topla
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
print(f"✅ HİBRİT YÖNTEM TOPLAM MALİYETİ: {hibrit_maliyeti:.2f} birim")

# ==========================================
# 2. YÖNTEM: RANDOM SEARCH (Rastgele Arama)
# ==========================================
# Adil bir kıyaslama için rastgele seçimi 100 kere yapıp ortalamasını alıyoruz.
deneme_sayisi = 100
random_maliyetler = []

for _ in range(deneme_sayisi):
    # 50 aday arasından rastgele 5 tanesini (indeksini) seç
    rastgele_indeksler = np.random.choice(len(aday_atmler), size=kume_sayisi, replace=False)
    rastgele_secilenler = aday_atmler[rastgele_indeksler]
    
    maliyet = toplam_maliyet_hesapla(rastgele_secilenler)
    random_maliyetler.append(maliyet)

random_ortalama_maliyet = np.mean(random_maliyetler)
print(f"⚠️ RANDOM SEARCH ORTALAMA MALİYETİ ({deneme_sayisi} Deneme): {random_ortalama_maliyet:.2f} birim")

# ==========================================
# 3. SONUÇ VE GRAFİK (LaTeX Bildirisi İçin)
# ==========================================
iyilesme_orani = ((random_ortalama_maliyet - hibrit_maliyeti) / random_ortalama_maliyet) * 100
print(f"\n🚀 SONUÇ: Hibrit algoritma, rastgele seçime göre %{iyilesme_orani:.2f} daha verimlidir!")

# Sütun Grafiği Çizdirme
yontemler = ['Random Search (Ortalama)', 'Hibrit Yöntem (K-Means+Greedy)']
maliyetler = [random_ortalama_maliyet, hibrit_maliyeti]

plt.figure(figsize=(8, 5))
bar_colors = ['#e74c3c', '#2ecc71']
bars = plt.bar(yontemler, maliyetler, color=bar_colors, width=0.5)

# Barların üzerine değerleri yazdırma
for bar in bars:
    yval = bar.get_height()
    plt.text(bar.get_x() + bar.get_width()/2, yval + 100, f'{yval:.0f}', ha='center', va='bottom', fontweight='bold')

plt.title("WLP Optimizasyonu: Algoritma Performans Kıyaslaması", fontweight='bold')
plt.ylabel("Toplam Mesafe Maliyeti (Daha düşük daha iyi)")
plt.grid(axis='y', linestyle='--', alpha=0.7)

plt.savefig('veri/algoritma_kiyaslama_raporu.png')
print("✅ Kıyaslama grafiği 'veri' klasörüne kaydedildi.")
plt.show()