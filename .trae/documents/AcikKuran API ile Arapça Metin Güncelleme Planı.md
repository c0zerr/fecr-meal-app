## Özet
- Amaç: Uygulamadaki Arapça ayet metinlerindeki yazım hatalarını tek seferde düzeltmek için, `assets/json/quran_full.json` içindeki tüm `verses[].metin` alanlarını AçıkKuran API’den alınan kanonik Arapça metinle eşitlemek.
- Kapsam: Sadece `metin` güncellenecek; meal/dipnotlar ve diğer alanlara dokunulmayacak. Metin içinde ayet numarası işaretleri (`﴿ ١ ﴾`) mevcut formatta korunacak/yeniden üretilecek.
- Kaynak: AçıkKuran API (`https://api.acikkuran.com`) ve Arapça alan olarak `verse` kullanılacak.
- Lisans notu: AçıkKuran API verisi CC BY-NC-SA; kullanım non-commercial olduğundan uygun.

## Mevcut Durum Analizi (Repo’dan)
- Ana veri dosyası: [quran_full.json](file:///Users/coskun/%C4%B0%C5%9ELER/FECR_MEAL/APP/fecr-meal-app/assets/json/quran_full.json)
  - Sure listesi şeklinde; her surede `verses` listesi bulunuyor.
  - `ayetno == 0` olan kayıtlar sure açıklaması/başlık gibi görünüyor; metin bazen boş kalıyor.
  - `metin` alanında ayet numarası işaretleri mevcut (örn. `﴿ ١ ﴾`) ve UI bununla uyumlu: [quran_full.json:53-365](file:///Users/coskun/%C4%B0%C5%9ELER/FECR_MEAL/APP/fecr-meal-app/assets/json/quran_full.json#L53-L365)
- Uygulama veri okuma önceliği: cihaz dosyası → yoksa asset: [quran_data_manager.dart](file:///Users/coskun/%C4%B0%C5%9ELER/FECR_MEAL/APP/fecr-meal-app/lib/core/services/quran_data_manager.dart#L69-L97)
  - Repo içindeki `assets/json/quran_full.json` güncellense de, kullanıcı cihazında daha yeni bir kopya varsa sunucu + versiyon artırımı gerekebilir (bu plan, repo dosyasını güncellemeye odaklanır).
- Repo’da mevcut bir çekme script’i var: [fetch_quran.py](file:///Users/coskun/%C4%B0%C5%9ELER/FECR_MEAL/APP/fecr-meal-app/fetch_quran.py) (başka bir API’den tüm dosyayı üretmek için). Bizim ihtiyacımız “sadece metin güncelleme”, bu yüzden ayrı bir script daha güvenli.

## API Gerçekleri (AçıkKuran)
- Endpoint: `GET https://api.acikkuran.com/surah/{surah_id}` (sure detay + ayet listesi)
- Her ayette Arapça metin alanı: `verse` (harekeli/işaretli).
- Not: API metni ayet numarası işaretlerini (`﴿ ... ﴾`) içermiyor; bunları biz mevcut formatta ekleyeceğiz.

## Önerilen Değişiklikler
### 1) Yeni bir güncelleme script’i ekle
- Yeni dosya: `tools/update_arabic_metin_from_acikkuran.py`
- Sorumluluk:
  1. `assets/json/quran_full.json` dosyasını oku (UTF-8).
  2. AçıkKuran’dan 114 sureyi **sure bazında** çek:
     - Döngü: `surah_id = 1..114`
     - `GET /surah/{id}` → `data.verses[]` içinden `verse_number` → `verse` map’i üret.
  3. Her sure ve her `verse` kaydı için `metin` güncelle:
     - `ayetno == 0` ise `metin` değiştirme (mevcut davranış korunur).
     - Aksi halde, ilgili kaydın hangi ayet(ler)e karşılık geldiğini belirle:
       - Öncelik: `meal` alanının başındaki `[a:...]` etiketini parse et (örn. `[a:58, 59]`, `[a:1-6]`, `[a:118]`).
       - Yoksa fallback: sadece `ayetno`.
     - Her ayet numarası için:
       - API’den `verse` metnini al.
       - Mevcut UI formatına uygun numara işaretini ekle: `"<arabic> ﴿ <ARAPÇA_RAKAM> ﴾"`
       - Çoklu ayet ise araya tek boşluk koyarak birleştir.
     - API’de eksik ayet bulunursa:
       - O kaydın `metin`ini değiştirme ve rapora yaz (script çıktı log’u).
  4. Güvenli yazım:
     - Önce yedek al: `assets/json/quran_full.backup_YYYYMMDD_HHMMSS.json`
     - Sonra güncellenmiş içeriği `assets/json/quran_full.json` üzerine yaz.
  5. Özet raporu yazdır:
     - Güncellenen `metin` sayısı, atlanan kayıt sayısı, eksik eşleşme sayısı.

### 2) (Opsiyonel) Dağıtım için versiyon artırımı
- Eğer kullanıcıların cihazında sunucudan indirilmiş veri varsa:
  - Sunucuya güncel `quran_full.json` yükleme
  - `assets/json/version.json` ve sunucu `version.json` versiyonunu artırma
- Bu adım, bu planın uygulama aşamasında “opsiyonel” olarak yapılacak; önce repo dosyasını doğru üretmek hedef.

## Varsayımlar ve Kararlar
- Arapça kaynak alanı: AçıkKuran `data.verses[].verse` (seçim net).
- Sadece `metin` alanları güncellenecek; meal/dipnotlar korunacak.
- Ayet numarası işaretleri mevcut formata uygun üretilecek (`﴿ ١ ﴾`).
- Lisans: CC BY-NC-SA koşulları proje kullanımına uygun (non-commercial).

## Doğrulama / Kabul Kriterleri
- Script çalıştıktan sonra:
  - `assets/json/quran_full.json` JSON olarak parse edilebilir.
  - `ayetno > 0` olan kayıtların `metin` alanları AçıkKuran’dan gelen Arapça metinle uyumludur ve `﴿ n ﴾` işaretlerini içerir.
  - Rastgele örneklem: 1, 2, 36, 55, 78, 114. surelerden birkaç ayet manuel kontrol edilir.
  - “Birleştirilmiş ayet” örnekleri (meal içinde `[a:...]` olanlar) doğru biçimde birleştirilir.
  - `flutter analyze` mevcut hatalar dışında yeni hata üretmez.
