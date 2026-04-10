## Özet
Ayet detay sayfasındaki alt navigasyon menüsünde yer alan "Paylaş" butonuna basıldığında iOS ve Android cihazların yerel (native) paylaşma menüsünün sorunsuz açılması sağlanacak.

## Mevcut Durum Analizi
- `lib/views/oku/sureokupage.dart` dosyasında `Share.share` metodu çağrılarak paylaşım yapılıyor.
- iOS platformunda (özellikle iPad'lerde), `share_plus` paketi ile paylaşım yapılırken `sharePositionOrigin` parametresi verilmezse uygulama çökebilir veya paylaşım menüsü hiç açılmayabilir. "Paylaş butonu çalışmıyor" sorununun temel kaynağı bu parametrenin eksikliğidir.

## Önerilen Değişiklikler
- Dosya: `lib/views/oku/sureokupage.dart`
- İlgili Satırlar: 1482 ve 1816 civarındaki `Share.share` çağrıları.
- Yapılacak İşlem:
  `Share.share` çağrılarına `sharePositionOrigin` parametresi eklenecek. Bu parametre, butonun ekrandaki konumunu (RenderBox) baz alarak paylaşım menüsünün doğru yerden açılmasını sağlayacak.

Değişiklik örneği:
```dart
final box = context.findRenderObject() as RenderBox?;
final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

await Share.share(
  shareText,
  subject: "...",
  sharePositionOrigin: origin,
);
```

## Varsayımlar ve Kararlar
- Sorunun iPad veya bazı iOS cihazlarda `sharePositionOrigin` eksikliğinden kaynaklandığı varsayılmıştır (en yaygın `share_plus` hatası).
- `kIsWeb` kontrolü korunarak web tarafında bu özelliğin devre dışı kalması sağlanacaktır.

## Doğrulama Adımları
- `flutter analyze` ile kodun hatasız derlendiği kontrol edilecek.
- (Eğer mümkünse) `Share.share` metoduna `sharePositionOrigin`'in başarıyla eklendiği doğrulanacak.
