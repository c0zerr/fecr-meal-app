## Özet
- Fâtiha suresi (Sure 1) için Arapça metin eşleştirmesini düzeltmek (Besmeleyi ayet saymayıp, AçıkKuran'daki 2-7. ayetleri bizim 1-6. ayetlerimizle eşleştirmek).
- TestFlight'ta neden güncel metinlerin görünmediğini açıklamak ve hosting (anilakademi.com) tarafına yüklenmesi gereken dosyaları (versiyon artırarak) hazırlamak.

## Mevcut Durum Analizi
- Önceki çalıştırdığımız Python script'i AçıkKuran'dan Fâtiha için 7 ayet çekti (1. ayet Besmeleydi). Bizim mealimizde ise Fâtiha 6 ayet (Besmele ayet olarak numaralandırılmıyor) olduğu için Arapça metinler meal ile kaydı.
- Uygulama mimarisinde (`QuranDataManager`), cihaz bir kez internetten `quran_full.json` indirdiğinde artık uygulama içine (assets) gömülü olan dosyayı DEĞİL, cihaz hafızasına kaydettiği dosyayı okur. Bu yüzden GitHub'a push edip yeni build alsan bile, cihazdaki eski dosya silinmediği sürece yeni Arapça metinler TestFlight'ta görünmez.

## Önerilen Değişiklikler
1) **Python Script'ini Güncellemek:**
   - Dosya: [update_arabic_metin_from_acikkuran.py](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/tools/update_arabic_metin_from_acikkuran.py)
   - Fâtiha (surah_id = 1) için özel kural eklenecek: API'den gelen 1. ayet (Besmele) atlanacak, 2. ayet 1'e, 3. ayet 2'ye ... 7. ayet 6'ya kaydırılacak.
2) **Veriyi Yeniden Üretmek:**
   - Güncellenen script çalıştırılarak [quran_full.json](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/assets/json/quran_full.json) dosyası Fâtiha 6 ayet olacak şekilde düzeltilecek.
3) **Versiyon Numarasını Artırmak:**
   - Dosya: [version.json](file:///Users/coskun/İŞLER/FECR_MEAL/APP/fecr-meal-app/assets/json/version.json)
   - Uygulamanın yeni dosyayı indirmesini tetiklemek için `version: 1` değeri `version: 2` (veya uygun bir sonraki sayı) olarak güncellenecek.

## Varsayımlar ve Kararlar
- Fâtiha'nın Arapça metin numaralandırması `﴿ ١ ﴾` ile `﴿ ٦ ﴾` arasında olacak ve meal ile tam eşleşecek.
- Uygulamadaki kullanıcıların (TestFlight dâhil) güncellemeyi alabilmesi için senin bu iki dosyayı (`quran_full.json` ve `version.json`) **anilakademi.com** sunucusundaki (API klasörüne) atman gerekiyor.

## Doğrulama Adımları
- `assets/json/quran_full.json` içinde Fâtiha'nın 1. ayetinin "Elhamdu lillahi..." (Arapça) ile başladığı teyit edilecek.
- Uygulama kodunda hata olmadığını doğrulamak için `flutter analyze` çalıştırılacak.
