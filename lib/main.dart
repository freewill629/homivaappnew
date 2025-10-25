import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const defaultFirebaseAppName = '[DEFAULT]';
  final hasDefaultApp = Firebase.apps.any(
    (app) => app.name == defaultFirebaseAppName,
  );

  if (!hasDefaultApp) {
    await Firebase.initializeApp(
      name: defaultFirebaseAppName,
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const HomivaApp());
}
