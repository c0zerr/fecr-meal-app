## Özet
Amaç: Uygulamadaki bazı ayetlerde görülen Arapça yazım hatalarını, tek tek kullanıcı bildirimi beklemeden, `assets/json/quran_full.json` içindeki tüm `metin` alanlarını güvenilir bir “kanonik Arapça mushaf metni” kaynağıyla **toplu olarak eşitleyerek** gidermek. Meal/dipnotlar değişmeden kalacak; sadece Arapça `metin` güncellenecek. Ardından sen, güncellenmiş `quran_full.json` dosyasını sunucuya yükleyip `version.json` içindeki `version` değerini 1 artırarak tüm kullanıcılara dağıtacaksın.

## Mevcut Sistem Analizi (Repo’dan)
### Veri kaynağı ve dağıtım
- Uygulama açılışında `QuranDataManager.checkAndUpdateData()` çalışır: [main.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/main.dart#L10-L14)
- Sunucudan `version.json` okunur; sunucu versiyonu yerelden büyükse `quran_full.json` indirilip cache’e yazılır: [quran_data_manager.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/core/services/quran_data_manager.dart#L16-L55)
- Mobilde ayet verisi okuma önceliği: cihaz dosyası (`Documents/quran_full.json`) → yoksa asset: [quran_data_manager.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/core/services/quran_data_manager.dart#L66-L92)
  - Bu yüzden sadece repo içindeki `assets/json/quran_full.json`’ı değiştirmek, kullanıcıda daha önce indirilen veriler varsa tek başına yeterli değildir; sunucu + version bump ile dağıtım gerekir.

### Arapça metnin ekranda nasıl gösterildiği
- Sure okuma ekranı Arapça’yı `_verses[ayetno].metin` ile direkt basıyor (ek bir “ayet numarası ekleme” yok). Bu nedenle `metin` içinde ayet numarası işaretlerinin (örn. `﴿ ٦٢ ﴾`) bulunması mevcut UI davranışı için önemlidir: [sureokupage.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/views/oku/sureokupage.dart)

## Problem
- Arapça metin tüm dünyada aynı olduğu için hatalı `metin` girişleri topluca “doğru mushaf metni” ile eşitlenebilir.
- JSON’da bazı satırlarda manuel müdahaleden kaynaklı bozulmalar (ör. latin karakter sızması) görülebiliyor.
- Bazı kayıtlar **birden fazla ayeti tek “verse” objesinde** birleştirmiş (ör. meal `[a:58, 59]` ve `metin` içinde `﴿ ٥٨ ﴾ ... ﴿ ٥٩ ﴾`). Dolayısıyla “ayetno=59 ise metin sadece 59” varsayımı her yerde geçerli değil.

## Önerilen Yöntem (Tek Seferde Düzeltme)
### 1) Kanonik Arapça kaynak seçimi
- Kaynak: Uthmani (harekeli) mushaf metni (en yakın eşleşme). Bu kaynak ayet ayet düz metin olarak gelir.
- Bu aşamada amaç: `idsure` + ayet numarası ile **114 sure / 6236 ayet** eşlemesi yapmak.

### 2) Repo’ya bir “dönüştürme script’i” eklemek
Yeni bir Python script’i eklenecek (örnek isim):
- `tools/update_arabic_metin.py`

Script’in yaptığı:
- `assets/json/quran_full.json` dosyasını okur.
- Kanonik Arapça kaynaktan (yerel dosya veya URL’den indirilen) 114 sureyi okur ve `(idsure, ayetno) -> arabic_text` map’i üretir.
- Her `verses[]` elemanı için:
  - `ayetno == 0` (sure açıklaması girişleri) ise `metin` boş bırakılır (mevcut davranış korunur).
  - Aksi halde “bu kaydın hangi ayet(ler)e karşılık geldiğini” belirler:
    - Öncelik 1: `meal` alanının başındaki `[a:...]` etiketini parse eder (örn. `[a:118]`, `[a:77, 78]`, `[a:1-6]`).
    - Bulamazsa fallback: sadece `ayetno`.
  - Bulduğu ayet listesindeki her ayet için kanonik Arapça metni alır ve şu formatla birleştirir:
    - `<ayet_arapça> ﴿ <ARAPÇA_RAKAM> ﴾`
    - Çoklu ayet ise araya bir boşluk konur.
  - Böylece tekil ve birleşik ayet metinleri tutarlı şekilde üretilir.
- Meal/dipnot/diğer alanlara dokunmaz.

### 3) Çıktı üretimi
- Güncellenmiş dosya:
  - Repo içinde `assets/json/quran_full.json` üzerine yazılır (veya güvenli olarak `assets/json/quran_full.updated.json` üretilip son adımda replace edilir).

## Kullanıcının (Senin) Yapacağı Şeyler
- Script çalıştırıldıktan sonra oluşan güncel `quran_full.json` dosyasını sunucuya yükle:
  - `https://www.anilakademi.com/kuran_aydinligi_api/quran_full.json`
- Sunucudaki `version.json` içindeki `version` değerini 1 artır:
  - `https://www.anilakademi.com/kuran_aydinligi_api/version.json`
- Böylece kullanıcılar uygulamayı açınca veya Ayarlar’dan “Güncelle” ile yeni Arapça metinleri indirir.

## Doğrulama (Acceptance)
- JSON parse doğrulaması (format bozulmadı).
- Rastgele 5–10 surede (baş/orta/son) Arapça metinler kontrol edilir; ayet numarası işaretleri korunur.
- “Birleşik ayet” örnekleri (örn. `[a:77, 78]`, `[a:58, 59]`) doğru biçimde birleştirilir.
- Dosyada latin harf sızıntısı (a–z/A–Z) kalmadığı doğrulanır.

## Senin Yardımcı Olabileceğin Noktalar
- Tercih edilen mushaf biçimi: “Uthmani (harekeli)” varsayacağım.
- İstersen 3–5 adet “kullanıcı şikayeti gelmiş” ayeti örnek olarak ver; doğrulama setine ekleyelim.

