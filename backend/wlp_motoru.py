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
        
        # 1. DEĞİŞİKLİK: 'X' ve 'Y' yerine Ebru'nun veritabanındaki isimleri yazdık
        musteri_koordinatlar = df_musteriler[['latitude', 'longitude']].values
        uygun_atmler = df_atm[['latitude', 'longitude']].values
        
        # OPTİMİZASYON 1: Büyük veriler için RAM dostu MiniBatchKMeans
        kmeans = MiniBatchKMeans(n_clusters=kume_sayisi, random_state=42, batch_size=1000)
        kmeans.fit(musteri_koordinatlar)
        merkezler = kmeans.cluster_centers_
        
        secilen_atmler = []
        
        for i, merkez in enumerate(merkezler):
            # OPTİMİZASYON 2: Uzamsal Arama Ağacı (KD-Tree)
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
    # 2. DEĞİŞİKLİK: Eski dosyalar yerine yeni veritabanı CSV'lerinin yollarını verdik
    print(json.dumps(optimize_atm_lokasyonlari_v2('backend/veri/demand_points.csv', 'backend/veri/atm_candidates.csv'), indent=4))