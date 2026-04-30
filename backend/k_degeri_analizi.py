import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
from scipy.spatial.distance import cdist

print("Farklı K Değerleri (ATM Sayısı) İçin Maliyet Analizi Başlatılıyor\n")

df_musteriler = pd.read_csv('veri/musteri_verisi.csv')
df_atm = pd.read_csv('veri/atm_adaylari.csv')

musteriler = df_musteriler[['X', 'Y']].values
aday_atmler = df_atm[['X', 'Y']].values

#  farklı K (Depo) sayıları
k_degerleri = [3, 5, 7, 10]
sonuclar = []

def maliyet_hesapla(secilenler):
    mesafeler = cdist(musteriler, secilenler)
    return np.sum(np.min(mesafeler, axis=1))

for k in k_degerleri:
    #  HİBRİT YÖNTEM
    kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
    kmeans.fit(musteriler)
    merkezler = kmeans.cluster_centers_
    
    hibrit_secilenler = []
    uygun_atmler = aday_atmler.copy()
    for merkez in merkezler:
        mesafeler = cdist([merkez], uygun_atmler)[0]
        indeks = np.argmin(mesafeler)
        hibrit_secilenler.append(uygun_atmler[indeks])
        uygun_atmler = np.delete(uygun_atmler, indeks, axis=0)
        
    hibrit_maliyeti = maliyet_hesapla(hibrit_secilenler)
    
    #  RANDOM SEARCH 
    random_maliyetler = []
    for _ in range(10):
        rastgele_indeksler = np.random.choice(len(aday_atmler), size=k, replace=False)
        random_maliyetler.append(maliyet_hesapla(aday_atmler[rastgele_indeksler]))
    random_maliyeti = np.mean(random_maliyetler)
    
    iyilesme = ((random_maliyeti - hibrit_maliyeti) / random_maliyeti) * 100
    
    sonuclar.append((k, random_maliyeti, hibrit_maliyeti, iyilesme))

# LaTeX Tablo Çıktısı
print(" HAZIR LATEX TABLOSU KODU:\n")
print(r"\begin{table}[htbp]")
print(r"\centering")
print(r"\caption{Farklı $K$ Değerleri İçin Random Search ve Hibrit Algoritma Maliyet Kıyaslaması}")
print(r"\begin{tabular}{|c|c|c|c|}")
print(r"\hline")
print(r"\textbf{Depo Sayısı (K)} & \textbf{Random Maliyet} & \textbf{Hibrit Maliyet} & \textbf{İyileşme Oranı (\%)} \\ \hline")

for k, r_maliyet, h_maliyet, yuzde in sonuclar:
    print(rf"{k} & {r_maliyet:.2f} & {h_maliyet:.2f} & \%{yuzde:.2f} \\ \hline")

print(r"\end{tabular}")
print(r"\label{tab:k_degerleri_analizi}")
print(r"\end{table}")