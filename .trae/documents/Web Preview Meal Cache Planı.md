## Özet
Mü’minûn 118 (dipnot 36) gibi `assets/json/quran_full.json` içindeki güncellemelerin web preview’de görünmemesinin ana nedeni, uygulamanın web’de önce **LocalStorage/SharedPreferences cache**’ini okumasıdır. Ek olarak dipnot metni UI’da `aciklama` alanından değil `aciklama_p_tags.tags[].content` alanından gösterilir. Bu plan, web preview’de verinin kaynağını görünür kılmayı ve tek tıkla cache’i sıfırlamayı hedefler.

## Mevcut Durum Analizi
### Veri kaynağı ve cache önceliği
- Uygulama başlangıcında `QuranDataManager.checkAndUpdateData()` çağrılıyor: [main.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/main.dart)
- Veri okuma sırası: [quran_data_manager.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/core/services/quran_data_manager.dart#L66-L92)
  - Web: `SharedPreferences` (LocalStorage) içindeki `quran_json_cache` varsa **onu okur**
  - Mobil: documents dizinindeki `quran_full.json` varsa **onu okur**
  - Hiçbiri yoksa: `assets/json/quran_full.json` **fallback**
- Bu yüzden `assets/json/quran_full.json` güncellense bile, tarayıcıda `quran_json_cache` varsa uygulama eski veriyi göstermeye devam eder.

### Dipnot metninin gösterildiği alan
- Dipnot tıklanınca gösterilen metin `aciklama_p_tags.tags[index].content`’tir: [sureokupage.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/views/oku/sureokupage.dart#L92-L167)
- Dolayısıyla sadece `aciklama` alanını güncellemek, dipnot popup’ında değişiklik oluşturmayabilir.
- Mü’minûn 118 / dipnot 36 kaydı JSON içinde burada: [quran_full.json](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/assets/json/quran_full.json#L77846-L77874)

## Hedef (Başarı Kriterleri)
- Web preview’de (`http://localhost:8080`) JSON’da yapılan dipnot düzeltmesi **cache temizlendikten sonra** görünür.
- Uygulama içinde “Meal Verisi” bölümünde kullanıcı cache’i sıfırlayabilir ve hangi kaynağın kullanıldığını anlayabilir.

## Önerilen Değişiklikler
### 1) Ayarlar ekranına “Meal önbelleğini sıfırla” butonu
- Dosya: [settings_page.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/views/settings/settings_page.dart)
- Meal Verisi kartına ikinci bir buton eklenecek:
  - Etiket: “Önbelleği Sıfırla”
  - İşlev: `QuranDataManager.deleteLocalData()` çağıracak, sonra `_loadVersionInfo()` ile UI güncellenecek
  - Web’de ek olarak kullanıcıya “Sayfayı yenileyin” uyarısı gösterilecek (snackbar)

### 2) Ayarlar ekranında “Veri Kaynağı” bilgisini gösterme
- Dosya: [quran_data_manager.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/core/services/quran_data_manager.dart)
- Yeni, read-only bir helper eklenecek:
  - `getDataSourceLabel()` gibi bir metot (örn: “Web cache”, “Cihaz dosyası”, “Asset”)
- Dosya: [settings_page.dart](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/lib/views/settings/settings_page.dart)
  - Versiyon satırına ek olarak “Kaynak: …” satırı gösterilecek

### 3) Dipnot güncellemesinin doğru alana yapıldığını doğrulama (yazılı kontrol)
- Dipnot popup’ının kaynağı `aciklama_p_tags.tags[].content` olduğundan, ilgili dipnotun JSON’da bu alanda güncellendiği doğrulanacak.
- Bu aşama kod değişikliği gerektirmez; ancak planın kabulünden sonra uygulama içinde hızlı test akışı eklenecek/izlenecek.

## Varsayımlar ve Kararlar
- Kullanım senaryosu: “Sadece build içinde” ve “Web preview” (kullanıcı yanıtı).
- Bu nedenle sunucudaki `version.json/quran_full.json` güncellemesi kapsam dışıdır.

## Doğrulama / Test Prosedürü
- Web preview’i aç: `http://localhost:8080`
- Ayarlar > “Meal Verisi” bölümünde:
  - “Kaynak” satırında `Web cache`/`Asset` doğrula
  - “Önbelleği Sıfırla” butonuna bas
  - Sayfayı yenile (hard refresh)
- Mü’minûn 118’de dipnot 36’ya tıkla:
  - Popup içeriğinin JSON’daki `aciklama_p_tags.tags[].content` ile aynı olduğunu doğrula

