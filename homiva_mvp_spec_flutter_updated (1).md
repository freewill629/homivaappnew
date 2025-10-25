# Homiva MVP — Smart Water Tank App (Flutter + Firebase)
(Addition)
---

## 🔥 Updated Firebase Config (from user project)

Replace the default FirebaseOptions in `main.dart` with the following snippet:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCh1rISQVZzXbIZ_diIOYb88RnZOChgVqE",
      authDomain: "homiva-63bb7.firebaseapp.com",
      projectId: "homiva-63bb7",
      storageBucket: "homiva-63bb7.firebasestorage.app",
      messagingSenderId: "823522876319",
      appId: "1:823522876319:web:9a95916e6d85e6abd63baa",
      databaseURL: "https://homiva-63bb7-default-rtdb.firebaseio.com", // Important
    ),
  );
  runApp(const HomivaApp());
}
```

> ✅ **Note:** Always double-check your `databaseURL` inside Firebase Console → *Build → Realtime Database*.
> For Homiva MVP, your full database path will be:  
> `https://homiva-63bb7-default-rtdb.firebaseio.com/tank`

---
