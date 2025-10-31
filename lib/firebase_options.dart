import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Holds the Firebase configuration for each supported platform.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'macOS is not configured. Add Firebase options for macOS before enabling this platform.',
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'This platform is not configured for Firebase. Update firebase_options.dart to support it.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAoLf8Jvi4M5MMdCMjvZasl1uWuWlgeQhE',
    appId: '1:814599800607:web:bfcb3547eccf538294d22a',
    messagingSenderId: '814599800607',
    projectId: 'smartwatertank-3efdd',
    authDomain: 'smartwatertank-3efdd.firebaseapp.com',
    databaseURL: 'https://smartwatertank-3efdd-default-rtdb.firebaseio.com',
    storageBucket: 'smartwatertank-3efdd.firebasestorage.app',
    measurementId: 'G-W6B3P8T7B7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAIc78rxqia0zcf90dglcGdbIpSMpZXq1w',
    appId: '1:814599800607:android:93fe629edaf90aa594d22a',
    messagingSenderId: '814599800607',
    projectId: 'smartwatertank-3efdd',
    databaseURL: 'https://smartwatertank-3efdd-default-rtdb.firebaseio.com',
    storageBucket: 'smartwatertank-3efdd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA1FRJSavJEB95RtiBWUfZPRzpcD6TpzK0',
    appId: '1:814599800607:ios:58c93d218cbfa69b94d22a',
    messagingSenderId: '814599800607',
    projectId: 'smartwatertank-3efdd',
    databaseURL: 'https://smartwatertank-3efdd-default-rtdb.firebaseio.com',
    storageBucket: 'smartwatertank-3efdd.firebasestorage.app',
    iosBundleId: 'com.homiva.smarttank',
  );
}
