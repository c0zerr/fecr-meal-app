## Özet
- Sure detay sayfasındaki (SureOkuPage) AppBar sağ üstteki “Ayete Git” aksiyon ikonunu daha ince ve “kitap/okuma” metaforu taşıyan bir ikonla güncellemek.
- Seçilen ikon: `Icons.menu_book_outlined`.

## Mevcut Durum Analizi
- “Ayete Git” aksiyonu, [sureokupage.dart](file:///Users/coskun/%C4%B0%C5%9ELER/FECR_MEAL/APP/fecr-meal-app/lib/views/oku/sureokupage.dart#L864-L883) içinde `AppBar > actions > IconButton` olarak tanımlı.
- Şu an ikon `Icons.exit_to_app_rounded` kullanıyor (kalın/uyumsuz görünüyor) ve `onPressed` ile `_showAyeteGitModal(context)` çağrılıyor.
- Proje Material Icons kullanıyor (`uses-material-design: true`), ek paket/asset gerekmiyor.

## Önerilen Değişiklikler
1) Sure detay AppBar action ikonunu değiştir
   - Dosya: [sureokupage.dart](file:///Users/coskun/%C4%B0%C5%9ELER/FECR_MEAL/APP/fecr-meal-app/lib/views/oku/sureokupage.dart#L864-L883)
   - Değişiklik:
     - `Icons.exit_to_app_rounded` → `Icons.menu_book_outlined`
     - Renk `Colors.white` aynı kalacak
     - Boyut: `size: 30` aynı kalacak (görsel denge için gerekiyorsa 28’e indirilecek; tek karar olarak 30 uygulanacak)
   - Davranış değişmeyecek: `_showAyeteGitModal(context)` aynen çalışacak.

2) (Opsiyonel, kapsam dışı varsayılan) Tutarlılık kontrolü
   - Ana sayfada “Ayete Git” butonu metin + `Icons.arrow_forward_ios_rounded` ile çalışıyor. Bu görev kapsamında yalnızca sure detay AppBar ikonu değiştirilecek.

## Varsayımlar ve Kararlar
- Karar: Sağ üst ikon `Icons.menu_book_outlined` olacak (kullanıcı seçimi).
- Karar: İkon Material Icon olarak kalacak; yeni SVG/asset eklenmeyecek.
- Kapsam: Sadece sure detay sayfasındaki AppBar action ikonu.

## Doğrulama / Kabul Kriterleri
- Sure detay sayfasında sağ üstteki ikon artık “kitap” ikonudur (`menu_book_outlined`) ve önceki kalın/uyumsuz görünüm giderilmiştir.
- İkona basınca “Ayete Git” modalı açılmaya devam eder.
- `flutter analyze` hatasız çalışır.
