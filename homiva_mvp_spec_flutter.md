# Homiva MVP — Smart Water Tank App (Flutter + Firebase)

> **Scope**: This MVP is for the KSUM grant demo. **Only two interactive features actually work end‑to‑end**:
> 1) **Tank Power Toggle** (ON/OFF boolean)  
> 2) **Water Level Indicator** (float scale **0.0–10.0** with 0.1 precision)
>
> All other UI elements are **presentational placeholders** to showcase the full product vision, but **disabled**.

---

## 1) Feature List (MVP First)
### ✅ Working (E2E)
1. **Login / Sign-up (Email + Password)** via Firebase Authentication
2. **Dashboard**
   - **Real-time Water Level Indicator** (0–10 scale)
   - **Tank ON/OFF Toggle** (writes boolean to Firebase)
3. **Logout**

### 🚧 Non‑working (UI only, disabled)
- Automatic water level control (auto-fill/drain)
- Real-time multi-tank monitoring
- IoT device management (pairing/OTA)
- Water quality monitoring
- Usage analytics & AI reports
- Low-water alerts & emergency mode
- Manual bypass options (hardware)
- Self-cleaning assistance
- Solar-powered operation widgets
- Safety & security (leak/overflow) indicators
- Tank tampering alerts
- Modular upgrade kits
- Hard water conversion controls
- Built-in water purification controls
- Rainwater harvesting views

> All the above appear as **read-only cards** with “Coming soon” tooltips.

---

## 2) Firebase Setup (One-time)
1. Create a Firebase project (e.g., **homiva-mvp**) → Console.
2. **Enable Authentication** → Email/Password.
3. **Enable Realtime Database** → *Start in test mode* (for MVP only) → Region `asia-south1` (or closest).
4. **Add Web App Config** (for Flutter web target):
   ```dart
   const firebaseConfig = {
     "apiKey": "YOUR_API_KEY",
     "authDomain": "homiva-mvp.firebaseapp.com",
     "databaseURL": "https://homiva-mvp.firebaseio.com",
     "projectId": "homiva-mvp",
     "storageBucket": "homiva-mvp.appspot.com",
     "messagingSenderId": "1234567890",
     "appId": "1:1234567890:web:abcdef123456"
   };
   ```
5. **Realtime Database Structure**
   ```json
   {
     "tank": {
       "status": true,
       "water_level": 7.3
     }
   }
   ```
   - `status` → boolean (true=ON, false=OFF)
   - `water_level` → float (0.0–10.0)

6. **Database Rules (MVP)**
   ```json
   {
     "rules": {
       ".read": "auth != null",
       ".write": "auth != null"
     }
   }
   ```

> ESP32 side: push periodic updates to `/tank/water_level` and listen to `/tank/status` to switch the relay.

---

## 3) Flutter Project Definition

### 3.1 Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.0
  firebase_database: ^11.1.0
  provider: ^6.1.2
```

### 3.2 Folder Structure
```
lib/
├─ main.dart
├─ app.dart
├─ styles/
│  └─ theme.dart
├─ services/
│  ├─ auth_service.dart
│  └─ db_service.dart
├─ widgets/
│  ├─ water_level_gauge.dart
│  ├─ primary_button.dart
│  └─ card_placeholder.dart
└─ screens/
   ├─ auth/
   │  └─ login_screen.dart
   ├─ dashboard/
   │  └─ dashboard_screen.dart
   └─ tank/
      └─ tank_control_screen.dart
```

---

## 4) UI/UX Spec (All screens)

### 4.1 Design Language
- **Style**: Modern, minimalist, high-contrast
- **Primary**: `#0A84FF` (Deep Blue)
- **Background**: `#FFFFFF`
- **Surface**: `#F5F5F7`
- **Accents**: `#111827` for text
- **Elevation**: Soft shadows, 16px rounded corners
- **Typography**: Inter / SF Pro, 16/24/32/40 sizes
- **Motion**: 200–250ms fade/scale transitions
- **Icons**: Material Icons (outlined)

### 4.2 Screen: **Login / Sign-up**
- **Header**: Homiva logo + title “Sign in”
- **Fields**: Email, Password (validators)
- **Buttons**:
  - **Primary**: “Sign in”
  - **Text**: “Create account” → toggles to Sign-up mode
- **Footer**: “By continuing you accept our Terms” (non-interactive placeholder)
- **State**: Loading spinner during auth calls; error snackbars

### 4.3 Screen: **Dashboard**
- **AppBar**: “Homiva MVP” + Logout (icon button)
- **Top Card**: **Water Level Gauge**
  - Circular gauge 0→10
  - Center text: `X.Y / 10`
  - Subtext: “Live · syncing” with animated dot when connected
- **Control Card**: **Tank Power**
  - Big segmented toggle: **OFF | ON**
  - Status chip: **ON** (green) / **OFF** (grey)
  - Timestamp: “Updated: hh:mm:ss”
- **Grid (2 columns)**: **Future Features** (disabled)
  - Water Quality • AI Analytics • Alerts • Solar • Safety • Purifier • RWH • Tamper, etc.
  - Each is a **CardPlaceholder** with a “Coming soon” tooltip

### 4.4 Screen: **Tank Control** (deep link from dashboard)
- Replicates **Power toggle** + expanded gauge
- Adds read-only labels:
  - **Recommended range**: 4.0–8.5
  - **Trend**: rising/falling/steady (placeholder icon only)
- Action: Toggle writes to `/tank/status`

---

## 5) Data Flow & State

### 5.1 Auth Flow
- `AuthService`: wraps `FirebaseAuth.instance`
  - `signIn(email, password)`, `signUp(...)`, `signOut()`
- On auth state change:
  - Autonavigate to **Dashboard** if logged in
  - Back to **Login** if logged out

### 5.2 Realtime Sync (Database)
- `DbService`:
  - `tankRef = FirebaseDatabase.instance.ref('tank')`
  - Listen: `tankRef.onValue` → parse `{status, water_level}`
  - Write: `tankRef.update({'status': bool})` on toggle
- UI subscribes via **Provider**:
  - `TankModel { bool status; double level; DateTime updatedAt; }`

### 5.3 Error Handling
- If snapshot null/malformed → show **Disconnected** banner
- If write fails → revert UI toggle and show snackbar

---

## 6) Code Snippets (Flutter UI Essentials)

### 6.1 Firebase Init (`main.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: 'YOUR_APP_ID',
      messagingSenderId: 'YOUR_SENDER_ID',
      projectId: 'homiva-mvp',
      databaseURL: 'https://homiva-mvp.firebaseio.com',
    ),
  );
  runApp(const HomivaApp());
}
```

### 6.2 Water Level Gauge (`widgets/water_level_gauge.dart`)
```dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaterLevelGauge extends StatelessWidget {
  final double level; // 0.0 – 10.0
  const WaterLevelGauge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final pct = (level.clamp(0, 10)) / 10.0;
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _GaugePainter(pct),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${level.toStringAsFixed(1)} / 10',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('Live · syncing',
                  style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double pct;
  _GaugePainter(this.pct);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.42;
    final stroke = 16.0;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFE5E7EB)
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFF0A84FF)
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * pct;

    canvas.drawArc(rect, 0, 2 * math.pi, false, bg);
    canvas.drawArc(rect, start, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) => oldDelegate.pct != pct;
}
```

### 6.3 Tank Toggle (write to Firebase)
```dart
import 'package:flutter/material.dart';

class TankToggle extends StatelessWidget {
  final bool isOn;
  final ValueChanged<bool> onChanged;
  const TankToggle({super.key, required this.isOn, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: false, label: Text('OFF'), icon: Icon(Icons.power_off_outlined)),
          ButtonSegment(value: true, label: Text('ON'), icon: Icon(Icons.power_outlined)),
        ],
        selected: <bool>{isOn},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}
```

---

## 7) Acceptance Criteria (for KSUM demo)
- User can **Sign up**, **Sign in**, **Sign out**.
- Dashboard shows **water level** in real time; changing in Firebase reflects in UI within ~1–2s.
- Tapping **ON/OFF** updates `/tank/status` and ESP32 relay follows within ~1–2s.
- Non-working features are clearly **disabled** but visible.
- Web, Android APK build succeeds (`flutter build web`, `flutter build apk`).

---

## 8) Demo Script (2 minutes)
1. Open app → Sign in.
2. Show dashboard: water level at “X.Y / 10” (ESP32 sends updates).
3. Toggle OFF → show database change and relay click.
4. Toggle ON → confirm hardware response.
5. Briefly scroll through disabled feature cards (“Coming soon”).

---

## 9) Roadmap (Post-MVP)
- Role-based access, multi-tank support, device binding
- Alerting (email/SMS/push), quality sensors, analytics
- Edge rules (auto fill/stop), OTA updates, secure comms
- Billing for premium features and modular upgrades

---

## 10) Build Commands
```bash
flutter clean && flutter pub get
flutter run -d chrome # for web
flutter build web
flutter build apk
```

---

## 11) ESP32 Contract (for your firmware dev)
- **Reads** `/tank/status` (bool) every 1s; applies relay state.
- **Writes** `/tank/water_level` (float 0.0–10.0) every 1–3s.
- **Network**: Stable Wi‑Fi; reconnect logic with exponential backoff.
- **Time**: Use NTP for timestamps if needed (optional).




 Homiva MVP — Smart Water Tank App (Flutter + Firebase)
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
