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

- Yerelde yukarıdaki komutla APK üretebilirsiniz.
- Alternatif olarak `.github/workflows/build-apk.yml` ile GitHub Actions üzerinden otomatik APK üretimi yapabilirsiniz.


## Firebase / Firestore (Paylaşımlı Tarifler)

Bu proje, kullanıcıların eklediği tariflerin herkes tarafından görülmesi için Firestore kullanır.

- Firebase ayarları `lib/firebase_options.dart` içinde `gidadedektifi-c7ba0` projesine göre güncellenmiştir.
- Firestore kuralları **tamamen public** olacak şekilde `firestore.rules` dosyasına eklendi.

Firebase CLI ile kuralları yayınlamak için:

```bash
firebase deploy --only firestore:rules
```


## GitHub Actions ile Otomatik APK

Depoda `Build Android APK` workflow'u vardır.

- `main` dalına her push'ta ve manuel tetiklemede çalışır.
- `flutter build apk --release` ile APK üretir.
- Çıktıyı `releases/app-release.apk` olarak repoya commit eder.


## APK Oluşturma (Adım Adım)

### Yöntem 1: GitHub üzerinden (önerilen)

1. GitHub reposunda **Actions** sekmesine girin.
2. Soldan **Build Android APK** workflow'unu seçin.
3. **Run workflow** butonuna basın ve çalıştırın.
4. İşlem bitince repoda `releases/app-release.apk` dosyası otomatik commit edilmiş olur.

> Not: Workflow'un APK'yı commit edebilmesi için repo ayarlarında Actions'ın yazma izni açık olmalıdır.

### Yöntem 2: Bilgisayarında lokal build

```bash
flutter pub get
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk releases/app-release.apk
```

Bu adım sonrası APK yolu:

```text
releases/app-release.apk
```
