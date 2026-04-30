import pandas as pd
import numpy as np
from sklearn.cluster import MiniBatchKMeans 
from scipy.spatial import KDTree 
import json

def optimize_atm_lokasyonlari_v2(musteri_csv, atm_csv, kume_sayisi=5):
    """
    Big-O Optimizasyonlu WLP Çözücüsü (MiniBatch + KDTree)
    Zaman Karmaşıklığı: O(N) -> O(N/batch_size + K log M)
    """
    try:
        df_musteriler = pd.read_csv(musteri_csv)
        df_atm = pd.read_csv(atm_csv)
        
        musteri_koordinatlar = df_musteriler[['X', 'Y']].values
        uygun_atmler = df_atm[['X', 'Y']].values
        
        # OPTİMİZASYON 1: Büyük veriler için RAM dostu MiniBatchKMeans
        # Normal KMeans O(N) iken, MiniBatch çok daha az iterasyonla sonucu bulur.
        kmeans = MiniBatchKMeans(n_clusters=kume_sayisi, random_state=42, batch_size=1000)
        kmeans.fit(musteri_koordinatlar)
        merkezler = kmeans.cluster_centers_
        
        secilen_atmler = []
        
        for i, merkez in enumerate(merkezler):
            # OPTİMİZASYON 2: Uzamsal Arama Ağacı (KD-Tree)
            # Tüm adaylara bakmak O(M) yerine, ağaçta aramak O(log M) sürer.
            agac = KDTree(uygun_atmler)
            
            # k=1: Sadece en yakın 1 komşuyu getir
            mesafe, en_yakin_indeks = agac.query(merkez, k=1)
            en_yakin_atm = uygun_atmler[en_yakin_indeks]
            
            secilen_atmler.append({
                "atm_id": f"ATM_{i+1}",
                "koordinat": {"lat": round(en_yakin_atm[0], 4), "lng": round(en_yakin_atm[1], 4)},
                "maliyet": round(mesafe, 2)
            })
            
            # Seçileni havuzdan çıkar
            uygun_atmler = np.delete(uygun_atmler, en_yakin_indeks, axis=0)
            
        return {"status": "success", "data": secilen_atmler, "optimization": "MiniBatch + KDTree"}

    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    print(json.dumps(optimize_atm_lokasyonlari_v2('veri/musteri_verisi.csv', 'veri/atm_adaylari.csv'), indent=4))