import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Default Firebase configuration used by the Homiva app.
///
/// Replace every `REPLACE_WITH_...` value with the credentials generated for
/// your Firebase project. You can copy them from the Firebase console (Project
/// settings > Your apps) or let the FlutterFire CLI generate this file
/// automatically.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_WEB_API_KEY',
    appId: 'REPLACE_WITH_WEB_APP_ID',
    messagingSenderId: 'REPLACE_WITH_WEB_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    authDomain: 'REPLACE_WITH_AUTH_DOMAIN',
    storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
    measurementId: 'REPLACE_WITH_WEB_MEASUREMENT_ID',
    databaseURL: 'REPLACE_WITH_REALTIME_DB_URL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_ANDROID_API_KEY',
    appId: 'REPLACE_WITH_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_WITH_ANDROID_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
    databaseURL: 'REPLACE_WITH_REALTIME_DB_URL',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_IOS_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
    iosClientId: 'REPLACE_WITH_IOS_CLIENT_ID',
    iosBundleId: 'REPLACE_WITH_IOS_BUNDLE_ID',
    databaseURL: 'REPLACE_WITH_REALTIME_DB_URL',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_WITH_MACOS_API_KEY',
    appId: 'REPLACE_WITH_MACOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MACOS_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
    iosClientId: 'REPLACE_WITH_MACOS_CLIENT_ID',
    iosBundleId: 'REPLACE_WITH_MACOS_BUNDLE_ID',
    databaseURL: 'REPLACE_WITH_REALTIME_DB_URL',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_WITH_WINDOWS_API_KEY',
    appId: 'REPLACE_WITH_WINDOWS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_WINDOWS_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
    databaseURL: 'REPLACE_WITH_REALTIME_DB_URL',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'REPLACE_WITH_LINUX_API_KEY',
    appId: 'REPLACE_WITH_LINUX_APP_ID',
    messagingSenderId: 'REPLACE_WITH_LINUX_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
    databaseURL: 'REPLACE_WITH_REALTIME_DB_URL',
  );
}
