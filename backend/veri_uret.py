import numpy as np
import pandas as pd
import os

# Veri klasörü yoksa oluşturalım
if not os.path.exists('veri'):
    os.makedirs('veri')

#  Müşteri Verisi (Sentetik): Şehrin 3 farklı yoğunluk bölgesi 

bolge_1 = np.random.normal(loc=[20, 20], scale=5, size=(300, 2))
bolge_2 = np.random.normal(loc=[60, 75], scale=8, size=(400, 2))
bolge_3 = np.random.normal(loc=[85, 30], scale=6, size=(300, 2))

# Tüm müşterileri birleştir ve tablo  yap
musteriler = np.vstack([bolge_1, bolge_2, bolge_3])
df_musteriler = pd.DataFrame(musteriler, columns=['X', 'Y'])

#  ATM Aday Noktaları: Şehrin her yerine rastgele dağılmış 50 nokta
atm_adaylari = np.random.uniform(low=0, high=100, size=(50, 2))
df_atm = pd.DataFrame(atm_adaylari, columns=['X', 'Y'])

# Dosyaları CSV olarak kaydet
df_musteriler.to_csv('veri/musteri_verisi.csv', index=False)
df_atm.to_csv('veri/atm_adaylari.csv', index=False)

print(" Veriler başarıyla üretildi ve 'veri' klasörüne kaydedildi.")
