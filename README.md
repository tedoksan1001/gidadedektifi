# Gıda Dedektifi (Flutter Mobil Prototip)

Gıda Dedektifi, gıda israfını azaltmayı hedefleyen Android odaklı bir mobil uygulama prototipidir.

## Ana Özellikler

- **Barkod Okuyucu + SKT Takibi**
  - Ürün barkodu okutulur.
  - Ürün adı ve son kullanma tarihi kaydedilir.
  - Son kullanma tarihine **2 gün kala** yerel bildirim planlanır.
- **Artan Yemek Tarifi Önerisi**
  - Evdeki malzemeler girilir.
  - Uygun tarifler eşleşme puanına göre listelenir.
  - Ortak malzemeler için hızlı ekleme çipleri vardır.
- **eTwinning Katkısı**
  - Ülkeler geleneksel “artan yemek değerlendirme” tariflerini ekleyebilir.
  - Geleneksel tarifler ayrı akışta listelenir.

## Çevrimdışı Çalışma Desteği

Uygulama Firebase'e bağlanamadığında da demo/prototip olarak çalışmaya devam eder:

- Yerel örnek tarifler otomatik yüklenir.
- Tarif arama ve listeleme yerel verilerle sürer.
- Ürün/tarif ekleme işlemleri kullanıcı akışını kesmeden devam eder.

## Kurulum

```bash
flutter pub get
flutter run
```

## Android APK Alma

```bash
flutter build apk --release
```

APK dosyası varsayılan olarak:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Releases Klasörü

`releases/` klasörü depo içinde ayrılmıştır.

- Bu ortamda `flutter` CLI kurulu olmadığı için APK otomatik üretilemedi.
- Flutter kurulu bir makinede yukarıdaki komut ile üretip `releases/app-release.apk` olarak ekleyebilirsiniz.
