import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// NOT: Bu dosya Firebase Console üzerinden otomatik olarak oluşturulabilir.
/// 'appId' ve 'projectId' alanlarını kendi Firebase projenize göre doldurmanız gerekmektedir.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web desteklenmiyor.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Bu platform desteklenmiyor.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyABTomIDlkfHmW_YrL0a5vpbnxNxeed3jg',
    appId: '1:1234567890:android:1234567890', // TODO: Firebase Console > Proje Ayarları kısmından gerçek App ID'yi buraya yapıştırın.
    messagingSenderId: '1234567890', // TODO: Firebase Console > Proje Ayarları kısmından gerçek Messaging Sender ID'yi buraya yapıştırın.
    projectId: 'gida-dedektifi', // TODO: Kendi Firebase Proje ID'nizi buraya yazın.
    storageBucket: 'gida-dedektifi.appspot.com',
  );
}
