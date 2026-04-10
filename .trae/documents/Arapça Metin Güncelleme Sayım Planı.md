## Özet
- Amaç: “3974 updated” sayısının ne anlama geldiğini ve “eksik ayet var mı?” sorusunu netleştirmek.
- Sonuç hedefi: Dataset’teki toplam kayıt sayısını (ayetno bazında) çıkarıp, `missing: 0` değerinin “AçıkKuran’da bulunamayan ayet yok” anlamına geldiğini doğrulamak.

## Mevcut Durum Analizi (Repo’dan, salt-okunur)
- `assets/json/quran_full.json` içinde `ayetno` alanı toplam **6349** kez geçiyor.
- Bunun **114** tanesi `ayetno: 0` (sure açıklaması/başlık kaydı gibi; ayet değil).
- Dolayısıyla `ayetno > 0` olan **kayıt sayısı 6235**.
  - Not: Bu repo’daki JSON bazı yerlerde bir “verse” objesinde birden fazla ayeti birleştirebildiği için (meal içinde `[a:58, 59]` gibi), “kayıt sayısı” ile “ayet sayısı” birebir aynı olmak zorunda değildir.

## “3974 updated” Ne Demek?
- Script, her `verses[]` objesindeki `metin` alanını yeniden üretir; ancak:
  - Üretilen metin eskisiyle aynıysa “updated” sayılmaz.
  - `ayetno == 0` kayıtları güncellenmez.
- Bu yüzden “updated: 3974” = **metni gerçekten değişen kayıt sayısı**dır; “toplam ayet” sayısı değildir.

## “missing: 0” Ne Demek?
- Script, her kayıt için kullanılacak ayet numaralarını (meal içindeki `[a:...]` veya fallback `ayetno`) belirler ve AçıkKuran’dan `verse` metnini arar.
- `missing: 0` = script’in referans aldığı tüm ayet numaraları için AçıkKuran’da karşılık bulundu; yani güncelleme sırasında “API’den metin bulunamadığı için atlanan” ayet yok.

## Varsayımlar ve Kararlar
- Kullanıcı beklentisi olan “6666” sayısı, yaygın kullanılan “ayet sayısı” değildir; Kur’an ayet sayısı genelde **6236** olarak geçer. Bu projedeki JSON ise bazı ayetleri tek kayıt altında birleştirdiği için kayıt sayısı farklı olabilir.
- Bu aşamada kod çalıştırma/değişiklik yok; sadece sayım ve anlam netleştirme.

## Doğrulama Adımları (Uygulama Moduna Geçilince)
- Script çıktısına ek bir rapor eklemek:
  - `total_records_ayetno_gt_0`, `total_records_ayetno_eq_0`, `total_distinct_ayet_numbers_covered` gibi alanlar.
- Rastgele birkaç surede:
  - Birleştirilmiş `[a:...]` kayıtların metninde tüm ayetlerin `﴿ n ﴾` ile geldiğini manuel kontrol etmek.
