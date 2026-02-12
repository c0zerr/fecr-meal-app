
import urllib.request
import json
import time
import ssl

# SSL sertifika hatasını önlemek için
ssl._create_default_https_context = ssl._create_unverified_context

API_URL = "http://fecrapi.anilakademi.com/api/post-ayet-adi"

sure_listesi = [
    "Fatiha", "Bakara", "Âl-i İmran", "Nisa", "Maide", "En’âm", "A'raf", "Enfal", "Tevbe", "Yunus",
    "Hûd", "Yusuf", "Ra'd", "İbrahim", "Hicr", "Nahl", "İsrâ", "Kehf", "Meryem", "Tâhâ",
    "Enbiya", "Hac", "Müminun", "Nur", "Furkan", "Şuarâ", "Neml", "Kasas", "Ankebut", "Rum",
    "Lokman", "Secde", "Ahzab", "Sebe", "Fatır", "Yasin", "Saffat", "Sâd", "Zümer", "Mümin",
    "Fussilet", "Şûrâ", "Zuhruf", "Duhan", "Casiye", "Ahkâf", "Muhammed", "Fetih", "Hucurât", "Kâf",
    "Zâriyât", "Tur", "Necm", "Kamer", "Rahman", "Vâkıa", "Hadid", "Mücadele", "Haşr", "Mümtehine",
    "Saff", "Cuma", "Münafikun", "Teğabun", "Talak", "Tahrim", "Mülk", "Kalem", "Hâkka", "Meâric",
    "Nuh", "Cin", "Müzzemmil", "Müddessir", "Kıyamet", "İnsan", "Mürselat", "Nebe", "Nâziât", "Abese",
    "Tekvir", "İnfitar", "Mutaffifin", "İnşikak", "Buruc", "Tarık", "A'la", "Gaşiye", "Fecr", "Beled",
    "Şems", "Leyl", "Duhâ", "İnşirah", "Tîn", "Alak", "Kadir", "Beyyine", "Zilzal", "Âdiyât",
    "Kâria", "Tekasür", "Asr", "Hümeze", "Fil", "Kureyş", "Mâûn", "Kevser", "Kâfirun", "Nasr",
    "Mesed", "İhlas", "Felak", "Nas"
]

def normalize_name(name):
    # API'nin beklediği formata dönüştür
    name = name.lower()
    mapping = {
        'â': 'a', 'î': 'i', 'û': 'u',
        'ı': 'i', 'İ': 'i', 'i̇': 'i', # i with dot
        'ş': 's', 'ğ': 'g', 'ü': 'u', 'ö': 'o', 'ç': 'c',
        '’': "'", '’': "'",
        "en'âm": "en'am", # Özel durum
        "a'raf": "a'raf",
        "ra'd": "ra'd",
        "hûd": "hud",
        "mâûn": "maun",
        "kâfirun": "kafirun"
    }
    
    # Özel isim mappingleri (Failed olanlar için)
    full_match = {
        "âl-i imran": "ali imran",
        "ibrahim": "ibrahim", 
        "isrâ": "isra",
        "mümin": "mumin",
        "zuhruf": "zuhruf", # Normal
        "şuarâ": "suara",
        "kâf": "kaf",
        "nâziât": "naziat",
        "abese": "abese",
        "mâûn": "maun",
        "kâfirun": "kafirun",
        "müddessir": "muddessir",
        "müzzemmil": "muzzemmil",
        "hâkka": "hakka",
        "meâric": "mearic",
        "mürselat": "murselat",
        "tâhâ": "taha",
        "vâkıa": "vakia" # Veya vakıa
    }
    
    if name in full_match:
        return full_match[name]

    for k, v in mapping.items():
        name = name.replace(k, v)
    
    return name

def fetch_all_sures():
    all_data = []
    print("Toplam {} sure indirilecek...".format(len(sure_listesi)))

    for index, sure_adi in enumerate(sure_listesi):
        retries = 3
        success = False
        
        while retries > 0 and not success:
            try:
                api_sure_adi = normalize_name(sure_adi)
                print("[{}/{}] İndiriliyor: {} -> {} (Bakiye: {})".format(index+1, len(sure_listesi), sure_adi, api_sure_adi, retries))
                
                # Request payload
                data = json.dumps({'sure': api_sure_adi}).encode('utf-8')
                req = urllib.request.Request(API_URL, data=data, headers={
                    'Content-Type': 'application/json', 
                    'User-Agent': 'Mozilla/5.0'
                })
                
                with urllib.request.urlopen(req) as response:
                    if response.status == 200:
                        response_data = json.loads(response.read().decode('utf-8'))
                        
                        if isinstance(response_data, list) and len(response_data) > 0:
                            sure_data = response_data[0]
                            if 'verses' in sure_data:
                                for verse in sure_data['verses']:
                                    verse['sure_adi'] = sure_adi
                            all_data.append(sure_data)
                            success = True
                        else:
                            print("UYARI: {} ({}) için boş veri döndü.".format(sure_adi, api_sure_adi))
                            time.sleep(2)
                            retries -= 1
                    else:
                        print("HATA: {} - HTTP {}".format(sure_adi, response.status))
                        retries -= 1
                        time.sleep(2) 
            
            except urllib.error.HTTPError as e:
                print("HATA: {} - HTTP Error: {}".format(sure_adi, e.code))
                if e.code == 429: # Too Many Requests
                    print("Çok fazla istek, 5 saniye bekleniyor...")
                    time.sleep(5)
                else:
                    time.sleep(2)
                retries -= 1
            except Exception as e:
                print("HATA: {} - {}".format(sure_adi, str(e)))
                retries -= 1
                time.sleep(2)
        
        if not success:
             print("BAŞARISIZ: {} indirilemedi.".format(sure_adi))

        # Daha güvenli bir bekleme süresi
        time.sleep(1)

    output_path = "assets/json/quran_full.json"
    import os
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(all_data, f, ensure_ascii=False, indent=2)
    
    print("İşlem tamamlandı! Toplam {} sure kaydedildi.".format(len(all_data)))

if __name__ == "__main__":
    fetch_all_sures()
