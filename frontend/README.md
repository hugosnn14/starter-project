# Flutter Frontend

Flutter app for the news MVP. The active production flow is Firebase-backed:

- published articles are loaded from Cloud Firestore
- article thumbnails are uploaded to Firebase Storage
- publishing requires a Firebase-authenticated user
- production DI only wires the current MVP article flow

Legacy and test-only fixtures stay outside the production container. Test helpers live under `test/helpers`.

## Requirements

- Flutter `>=3.38.0`
- Dart `>=3.10.0`
- JDK 17
- Android SDK
- Android NDK `27.0.12077973`

If the required NDK is missing, install it with:

```powershell
sdkmanager "ndk;27.0.12077973"
```

## Android Setup

1. From `frontend/`, install dependencies:

```powershell
flutter pub get
```

2. Verify the Android toolchain:

```powershell
flutter doctor -v
```

3. Confirm the Android SDK contains NDK `27.0.12077973`.

## Firebase Setup

The repo currently includes Android Firebase config for the existing project. If you want to use a different Firebase project, replace the committed config with your own:

1. Create or select a Firebase project.
2. Add an Android app with package name `com.example.news_app_clean_architecture`.
3. Download `google-services.json` and place it at `android/app/google-services.json`.
4. Regenerate `lib/firebase_options.dart` with FlutterFire CLI:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

5. Enable the Firebase products used by the MVP:

- Authentication
- Cloud Firestore
- Cloud Storage

6. If you want publishing to work without implementing a custom sign-in flow, enable `Anonymous` in Firebase Authentication.

If Anonymous Auth is disabled, the app still boots and the read flow still works, but article publishing will fail with a clear error message.

## Run The App

Run on a connected Android device:

```powershell
flutter run
```

Run on a specific Android emulator/device:

```powershell
flutter devices
flutter run -d <device-id>
```

Launch an Android emulator first if needed:

```powershell
flutter emulators
flutter emulators --launch <emulator-id>
flutter run -d <device-id>
```

## Firebase Emulators

This repo does not currently call `useEmulator(...)` for Auth, Firestore, or Storage. That means:

- Android emulators work out of the box against a real Firebase project
- Firebase Emulator Suite requires additional wiring before the app will talk to local emulator endpoints

If you decide to use Firebase emulators, add explicit emulator configuration in the Firebase bootstrap layer before treating that setup as supported.

## Verification

Static analysis:

```powershell
flutter analyze
```

Relevant MVP test suite:

```powershell
flutter test test/features/daily_news
```

Run the full frontend tests:

```powershell
flutter test
```

## Manual Smoke Test

Use this checklist before review:

1. Start the app on an Android device or emulator.
2. Confirm the home feed loads published articles from Firestore.
3. Open an article and verify the detail screen renders correctly.
4. Save an article and confirm it appears in `Saved Articles`.
5. Remove the saved article and confirm the list updates.
6. Open `Create article`, select a thumbnail, fill in the form, and publish.
7. Confirm the new article appears in the home feed.
8. Open the new article from the feed and verify its detail page.
9. If Anonymous Auth is disabled, verify publish fails with the explicit Firebase auth guidance instead of crashing the app.

## Reference Docs

- [Contribution Guidelines](./docs/CONTRIBUTION_GUIDELINES.md)
- [Architecture Violations](./docs/ARCHITECTURE_VIOLATIONS.md)
- [Code Quality Violations](./docs/CODING_GUIDELINES.md)
- [App Architecture](./docs/APP_ARCHITECTURE.md)
