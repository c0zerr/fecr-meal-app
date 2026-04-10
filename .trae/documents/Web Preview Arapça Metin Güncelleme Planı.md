## Özet
- Amaç: Yeni güncellediğimiz `assets/json/quran_full.json` (Arapça `metin`) verisinin Web Preview’de görünmesi için hangi adımların gerektiğini netleştirmek.
- Kapsam: Web preview (localhost) ve “hosting/sunucu” (https://www.anilakademi.com/kuran_aydinligi_api/) senaryolarını ayırıp karar ağacı sunmak.

## Mevcut Durum Analizi (Repo’dan)
- Uygulama açılışında her platformda `QuranDataManager.checkAndUpdateData()` çalışıyor: [main.dart](file:///Users/coskun/%C4%B0%C5%9ELER/FECR_MEAL/APP/fecr-meal-app/lib/main.dart#L10-L14)
- Sunucu kaynağı sabit: `https://www.anilakademi.com/kuran_aydinligi_api/` ve burada `version.json` + `quran_full.json` kontrol ediliyor: [quran_data_manager.dart](file:///Users/coskun/%C4%B0%C5%9ELER/FECR_MEAL/APP/fecr-meal-app/lib/core/services/quran_data_manager.dart#L9-L65)
- Web’de veri okuma davranışı:
  - Eğer tarayıcıda `quran_version` kaydı varsa JSON’u URL’den çeker (tarayıcı cache kullanır): [getQuranJsonString](file:///Users/coskun/%C4%B0%C5%9ELER/FECR_MEAL/APP/fecr-meal-app/lib/core/services/quran_data_manager.dart#L69-L80)
  - Yoksa fallback olarak uygulama bundle’ındaki asset’i okur: [getQuranJsonString](file:///Users/coskun/%C4%B0%C5%9ELER/FECR_MEAL/APP/fecr-meal-app/lib/core/services/quran_data_manager.dart#L95-L97)
- Ayarlar ekranında “Meal güncelleme” akışı `checkAndUpdateData()` çağırıyor: [settings_page.dart](file:///Users/coskun/%C4%B0%C5%9ELER/FECR_MEAL/APP/fecr-meal-app/lib/views/settings/settings_page.dart#L46-L69)

## İstenen Sonuç
- Web preview’de Arapça metin olarak yeni güncellediğimiz kaynak görünsün.

## Plan (Karar Ağacı)
### A) Web preview “lokalde build/web’den servis” ise
- Bu durumda yeni `assets/json/quran_full.json` dosyası **build’e dahil olur**.
- Yapman gerekenler:
  1) Web’i yeniden build et (eski build/web ile bakıyorsan yeni asset görünmez).
  2) Tarayıcı cache/service worker yüzünden eski asset kalabiliyorsa “hard refresh” yap veya site verisini temizle.
  3) Eğer tarayıcıda `quran_version` set’li kaldıysa, uygulama asset yerine URL’den çekmeye çalışır; bu durumda aşağıdaki B senaryosuna düşersin.

### B) Web preview “sunucudaki quran_full.json’u okuyan” modda ise (quran_version mevcut)
- Bu durumda web tarafı **asset’i değil**, `https://www.anilakademi.com/kuran_aydinligi_api/quran_full.json` dosyasını okur.
- Yapman gerekenler:
  1) Yeni güncel `quran_full.json` dosyasını hosting’e yükle.
  2) Sunucudaki `version.json` içindeki `version` değerini 1 artır.
  3) Web preview’de tarayıcıyı yenile (gerekirse hard refresh).

### C) Sadece web preview’de asset’i zorlamak istiyorsan (sunucuya yüklemeden)
- Tarayıcıda `quran_version` kaydını temizlemek gerekir ki fallback tekrar asset’e düşsün.
- Yapman gerekenler:
  - Tarayıcı “Site data / Local storage” temizle (localhost için) veya uygulama içinde `deleteLocalData()` tetikleyen bir buton ekle (bu adım bu planın dışında).

## Varsayımlar ve Kararlar
- “Sadece metin” güncellemesi yapıldı; UI tarafı sadece JSON kaynağına bağlı.
- Web’de `quran_version` varsa kaynak **sunucu** olur; yoksa kaynak **asset** olur.

## Doğrulama
- Fâtiha gibi bilinen bir ayette, AçıkKuran’daki `verse` ile aynı metin göründüğünü kontrol et.
- Ayarlar ekranında versiyon bilgisi beklenmedik şekilde “sunucu daha yeni” gösteriyorsa, web’in asset yerine sunucudan okuduğunu kabul et.
