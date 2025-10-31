import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAoLf8Jvi4M5MMdCMjvZasl1uWuWlgeQhE',
      authDomain: 'smartwatertank-3efdd.firebaseapp.com',
      projectId: 'smartwatertank-3efdd',
      storageBucket: 'smartwatertank-3efdd.firebasestorage.app',
      messagingSenderId: '814599800607',
      appId: '1:814599800607:web:bfcb3547eccf538294d22a',
      databaseURL: 'https://smartwatertank-3efdd-default-rtdb.firebaseio.com',
    ),
  );
  runApp(const HomivaApp());
}
