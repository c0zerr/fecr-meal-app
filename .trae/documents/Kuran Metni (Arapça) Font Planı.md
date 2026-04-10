## Özet
- `KuranKerimFontHamdullah.ttf` fontunu Kur’an metni (Arapça) için kullan.
- Tüm ayetlere/surelere yaymak yerine, test edebilmen için sadece **Fâtiha suresinde** (tüm Fâtiha ayetleri) bu fontu uygula.

## Mevcut Durum Analizi (Repo’dan)
- Projede Arapça metin için özel bir font ailesi tanımlı:
  - `pubspec.yaml` içinde: `family: KuranFont`
  - Bağlı dosya: `assets/font/KuranKerimFontHamdullah.ttf`
- Sure detay sayfasında Arapça ayet metni `fontFamily: 'KuranFont'` ile çiziliyor:
  - `lib/views/oku/sureokupage.dart` içinde RichText/TextSpan stili
- Bazı ekranlarda `fontFamily: 'Kuranfont'` (farklı büyük/küçük harf) kullanımı da var:
  - `lib/views/favorisureler/favoripage.dart`
  - `lib/views/ayracsureler/ayracview.dart`

## Önerilen Değişiklikler
1) Fâtiha’da fontu aç / diğer surelerde kapalı bırak
   - Dosya: `lib/views/oku/sureokupage.dart`
   - Hedef: Arapça metnin çizildiği `TextStyle(fontFamily: 'KuranFont', ...)` kısmı
   - Uygulama:
     - `bool isFatiha = (surahId == 1) || (_normalize(sureadi) == _normalize('Fâtiha'));`
     - `fontFamily: isFatiha ? 'KuranFont' : null`
   - Not: `surahId` argümanı gelmezse isim normalizasyonu ile Fâtiha tespiti çalışacak.

2) (Kapsam dışı) `Kuranfont` / `KuranFont` tutarsızlığını tek isim altında toplama
   - Bu görevde yapılmayacak; sadece Fâtiha testine odaklanılacak.

## Varsayımlar ve Kararlar
- Karar: Font sadece Fâtiha’da aktif edilecek; diğer sureler mevcut davranışla devam edecek.
- Karar: Font ailesi adı `KuranFont` (pubspec’te tanımlı olan) kullanılacak.

## Doğrulama Adımları
- Uygulamayı çalıştır:
  - Fâtiha suresinde Arapça metnin `KuranFont` ile render edildiğini gözle doğrula.
  - Başka bir surede Arapça metnin mevcut (default) font ile render edildiğini doğrula.
- `flutter analyze` çalıştır (yeni hata eklenmemeli).
