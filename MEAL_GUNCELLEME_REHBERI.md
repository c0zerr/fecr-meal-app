# 📖 Meal Güncelleme Rehberi (Basit Anlatım)

Bu dosya, uygulamanın ayetlerini ve dipnotlarını **yeni sürüm yayınlamadan** (build almadan) nasıl güncelleyeceğinizi anlatır.

## 📍 Sunucu Bilgileri
Dosyaları yükleyeceğiniz adres:
`https://www.anilakademi.com/kuran_aydinligi_api/quran_full.json`

## 🛠️ Güncelleme Nasıl Yapılır? (3 Adım)

1.  **JSON'u Düzenle:** Bilgisayarındaki `quran_full.json` dosyasını aç, istediğin düzeltmeyi yap ve kaydet.
2.  **Versiyonu Artır:** `version.json` dosyasını aç. İçindeki sayıyı **1 artır**. (Örneğin; `1` ise `2` yap).
3.  **Yükle:** Bu iki dosyayı (`quran_full.json` ve `version.json`) yukarıdaki URL adresine (eskilerinin üzerine) yükle.

**SONUÇ:** Uygulamayı açan herkes, saniyeler içinde senin yaptığın güncellemeyi otomatik olarak görecektir. ✨

---

## 💡 Önemli İpuçları
*   **İnternet Yoksa?** Uygulama ilk açılışta internet bulamazsa, projenin içindeki `assets/json/quran_full.json` dosyasını okur.
*   **Pro Tip:** Uygulamayı App Store'a yeni bir sürüm olarak göndereceğin zaman, projenin içindeki `assets/json/quran_full.json` dosyasını da o günkü en güncel haliyle değiştirmen tavsiye edilir (Yeni gelen kullanıcılar hemen güncel veriyi görsün diye).
*   **CORS Hatası?** Eğer tarayıcıda (Chrome) test ederken veri gelmezse, sunucuda `.htaccess` dosyasının olduğundan emin ol.

---
*Bu sistem Antigravity tarafından "Seçenek B" planına göre kurulmuştur.*
