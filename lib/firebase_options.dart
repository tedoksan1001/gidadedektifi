import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Bu platform için Firebase seçenekleri tanımlı değil.');
    }
  }

  // Kullanıcının paylaştığı Firebase projesi yapılandırması.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyABTomIDlkfHmW_YrL0a5vpbnxNxeed3jg',
    appId: '1:431708591289:web:916bf854aad5765c7ef768',
    messagingSenderId: '431708591289',
    projectId: 'gidadedektifi-c7ba0',
    storageBucket: 'gidadedektifi-c7ba0.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyABTomIDlkfHmW_YrL0a5vpbnxNxeed3jg',
    appId: '1:431708591289:web:916bf854aad5765c7ef768',
    messagingSenderId: '431708591289',
    projectId: 'gidadedektifi-c7ba0',
    storageBucket: 'gidadedektifi-c7ba0.firebasestorage.app',
    authDomain: 'gidadedektifi-c7ba0.firebaseapp.com',
    measurementId: 'G-C40V5H7Q6Z',
  );
}
