# Homiva MVP — Smart Water Tank App

This Flutter project implements the Homiva smart water tank MVP described in
[`homiva_mvp_spec_flutter.md`](homiva_mvp_spec_flutter.md). It is built around
Firebase Authentication and the Firebase Realtime Database so that the water
level indicator and tank power toggle stay in sync across devices.

The steps below walk you through creating the Firebase project, wiring the app
to it, and running the build even if you are new to Flutter.

---

## 1. Prerequisites

1. **Install Flutter** (3.24 or newer) by following the official guide for your
   platform: <https://docs.flutter.dev/get-started/install>.
2. **Install the FlutterFire CLI** (needed to configure Firebase quickly):
   ```bash
   dart pub global activate flutterfire_cli
   ```
3. (Optional but recommended) **Install the Firebase CLI** for access to the
   Realtime Database emulator and extra tooling:
   <https://firebase.google.com/docs/cli>.
4. **Create a Firebase project** in the console (e.g. `homiva-mvp`). Enable
   **Email/Password Authentication** and set up the **Realtime Database** in
   test mode while you iterate.

> 📱 You will also need the normal platform tooling if you want to deploy to a
> specific device type (Android Studio + Android SDK, Xcode for iOS, Chrome for
> Web, etc.). Run `flutter doctor` to confirm everything is green.

---

## 2. Get the source code

Clone the repository and install the dependencies:

```bash
git clone <your-repo-url>
cd homivaappnew
flutter pub get
```

If you created this repository without the standard Flutter folders (`android/`,
`ios/`, etc.), restore them with:

```bash
flutter create .
```

This command keeps the `lib/` code intact but regenerates the platform runners
so the app can build everywhere.

---

## 3. Configure Firebase

### 3.1 Generate `firebase_options.dart`

1. Log in to Firebase in your terminal and run the FlutterFire wizard:
   ```bash
   flutterfire configure --project=<your-firebase-project-id>
   ```
2. Select the platforms you plan to target. The CLI will create or update
   `lib/firebase_options.dart` with the correct keys for each platform.

If you prefer to edit the file manually, open
[`lib/firebase_options.dart`](lib/firebase_options.dart) and replace every
`REPLACE_WITH_...` value with the credentials from **Project settings → Your
apps** in the Firebase console.

### 3.2 Add the native config files

| Platform | Required file | Where to place it |
| --- | --- | --- |
| Android | `google-services.json` | `android/app/google-services.json` |
| iOS / macOS | `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` and/or `macos/Runner/GoogleService-Info.plist` |
| Windows | `firebase_app_id_file.json` | Generated automatically by FlutterFire |

Follow the prompts from the Firebase console for each platform you enabled.

### 3.3 Prepare the Realtime Database

1. In the Firebase console, open **Build → Realtime Database**.
2. Make sure your database URL matches the one in `firebase_options.dart`.
3. Create the initial data structure:
   ```json
   {
     "tank": {
       "status": true,
       "water_level": 7.3
     }
   }
   ```
4. Set the rules for the MVP demo:
   ```json
   {
     "rules": {
       ".read": "auth != null",
       ".write": "auth != null"
     }
   }
   ```

---

## 4. Run the app

### 4.1 Launch a debug build

From the project root run one of the following commands:

```bash
# Android emulator or physical device
flutter run -d android

# iOS simulator (requires macOS + Xcode)
flutter run -d ios

# Chrome / Web
flutter run -d chrome
```

Flutter will compile the target, install the Firebase configuration you set up,
then open the Homiva login screen.

### 4.2 Create an account and test the tank controls

1. Tap **Create account** on the login page and register with an email +
   password. The Firebase Authentication console will show the new user.
2. After signing in, the **Dashboard** connects to the Realtime Database. The
   water level gauge and the tank power toggle show live readings from
   `/tank/water_level` and `/tank/status`.
3. Flipping the toggle writes back to Firebase so other devices can see the
   change instantly. If the ESP32 firmware listens to `/tank/status` it can turn
   the pump on/off in real time.

---

## 5. Build release artifacts

Once you are ready for a production build, use the standard Flutter commands:

```bash
# Android APK
flutter build apk --release

# iOS IPA (requires macOS)
flutter build ipa --release

# Web build
flutter build web --release
```

Be sure to review platform-specific release checklists in the Flutter docs to
configure signing, bundle identifiers, and store metadata.

---

## 6. Troubleshooting

- Run `flutter doctor` to verify your environment.
- Confirm the Firebase project ID and database URL in `firebase_options.dart`
  match the Firebase console exactly.
- If the dashboard never loads data, make sure you are authenticated and the
  Realtime Database rules allow the read/write operations described above.

Happy building! 🚰
