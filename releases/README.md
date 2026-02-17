# APK Release Alanı

Bu klasör, Android release APK dosyasını depolamak için ayrılmıştır.

Beklenen dosya adı:

- `app-release.apk`

Üretim komutu:

```bash
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk releases/app-release.apk
```
