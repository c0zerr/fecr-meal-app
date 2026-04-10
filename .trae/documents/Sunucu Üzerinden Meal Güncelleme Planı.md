## Özet
Amaç, kullanıcıların cihazındaki “meal verisi”nin uygulama güncellemesi beklemeden, **sunucudaki `quran_full.json` + `version.json`** mekanizmasıyla güncellenmesini sağlamak. Sen revize listesini veriyorsun; ben repo içindeki `assets/json/quran_full.json` üzerinde düzeltmeleri güvenli şekilde uyguluyorum; sen de aynı güncellenmiş dosyayı sunucuya yükleyip `version.json` içindeki `version` değerini 1 artırıyorsun.

## Mevcut Sistem Nasıl Çalışıyor? (Koddan Doğrulama)
### 1) Uygulama açılışında güncelleme kontrolü
- `main()` içinde `QuranDataManager.checkAndUpdateData()` çağrılıyor: [main.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/main.dart#L8-L14)
- Bu çağrı **await edilmediği** için güncelleme indirme/yazma işlemi arka planda yürür; kullanıcı hemen bir sure açarsa, o an henüz güncelleme bitmemiş olabilir.

### 2) Sunucu tarafı
- Sunucu kökü: `https://www.anilakademi.com/kuran_aydinligi_api/` : [quran_data_manager.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/core/services/quran_data_manager.dart#L9-L14)
- Beklenen dosyalar:
  - `version.json` (içinde `{"version": <int>}`): [quran_data_manager.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/core/services/quran_data_manager.dart#L12-L36)
  - `quran_full.json`: [quran_data_manager.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/core/services/quran_data_manager.dart#L34-L55)
- Mantık: Sunucudaki `version` > cihazdaki `quran_version` ise yeni JSON indirilir ve cihazda cache olarak saklanır.

### 3) Cihazda hangi JSON kullanılıyor?
- Okuma önceliği: [quran_data_manager.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/core/services/quran_data_manager.dart#L66-L92)
  - Web: `SharedPreferences` içindeki `quran_json_cache`
  - Mobil: app documents içindeki `quran_full.json`
  - Fallback: `assets/json/quran_full.json`
- Bu nedenle “assets’te güncelledim ama uygulamada gelmedi” durumunun tipik sebebi:
  - Cihazda daha önce indirilmiş bir JSON vardır ve uygulama onu okumaktadır.
  - Sunucudaki `version.json` artırılmadığı için cihaz “güncel” sanıp yeni JSON’u indirmez.

### 4) Dipnot nereden geliyor?
- Dipnot popup’ında gösterilen metin `aciklama_p_tags.tags[].content` alanından gelir: [sureokupage.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/views/oku/sureokupage.dart#L92-L167)
- `aciklama` alanını değiştirip `aciklama_p_tags` içeriğini değiştirmezsen, dipnot popup’ı beklediğin gibi değişmeyebilir.

## Planlanan İş Akışı
### A) Revize bilgisi formatı (senin vereceğin)
Her düzeltme için şu formatı kullanacağız:
- Sure adı veya `idsure` (tercihen `idsure`) + `ayetno`
- Değişecek alan:
  - `meal` (ayet meali)
  - `metin` (Arapça metin)
  - `aciklama_p_tags.tags[number].content` (dipnot içeriği)
- Eski metin (opsiyonel ama doğrulama için faydalı) + yeni metin

### B) Repo içinde düzeltmelerin uygulanması
- Dosya: [quran_full.json](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/assets/json/quran_full.json)
- Değişiklikleri “noktasal” yapacağım:
  - Doğru sure + ayet eşleşmesi (`idsure`, `ayetno`)
  - Sadece istenen alanlar güncellenecek
  - JSON yapısı bozulmayacak (encoding / kaçış karakterleri korunacak)

### C) Sunucuya dağıtım (senin yapacağın)
- Sunucuya şu iki dosyayı yükle:
  - `quran_full.json` (güncellenmiş)
  - `version.json` içindeki `version` değerini **1 artır**
- Böylece tüm kullanıcılar uygulamayı açtığında (veya Ayarlar > “Güncelle” butonuyla) yeni veriyi indirebilir.

## Varsayımlar ve Kararlar
- Öncelik mobil: kullanıcı kafasını karıştıracak yeni ayar eklemiyoruz.
- Dağıtım yöntemi: “sunucu + version bump” (assets-only değil).
- Kullanıcı tarafında anlık görünmeme riski: güncelleme arka planda olduğu için, ilk açılışta sure hemen açıldıysa eski veriyi görebilir; uygulamayı yeniden açınca veya Ayarlar’dan “Güncelle” ile netleşir.

## Doğrulama (Uygulama Davranış Testi)
1) Sunucuda `version` artırıldıktan sonra:
  - Cihazda uygulamayı kapat-aç
  - Ayarlar > “Kur'an Aydınlığı Meal” bölümünde “Güncelleme var” durumunu gör (sunucu > yerel)
  - “Güncelle” butonuna bas (isteğe bağlı ama en deterministik yol)
2) İlgili ayeti aç:
  - `meal` metni güncellendi mi?
  - Dipnot numarasına tıkla: popup içeriği `aciklama_p_tags` ile güncellendi mi?

