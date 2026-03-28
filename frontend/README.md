# Flutter Frontend

Flutter app for the current Daily News build.

The frontend is no longer a mock-only assignment shell. The active app already ships a real hybrid article flow:

- published articles are read from Cloud Firestore
- external headlines are fetched from NewsAPI
- both sources are merged into a single home feed
- journalist-authored articles can be created, edited and archived
- thumbnails are uploaded to Firebase Storage
- saved articles and editor drafts are persisted locally with Floor/SQLite

Legacy fixtures and fake repositories still exist for tests, but they are intentionally kept outside the production dependency container.

## Current Product State

The screens and flows that are wired into `lib/main.dart` and `lib/config/routes/routes.dart` today are:

- `Home`: merged editorial feed with pull-to-refresh
- `Article details`: shared detail view for Firestore and NewsAPI articles
- `Saved Articles`: local reading list stored on device
- `Create article`: publish a new Firestore-backed article with a Storage thumbnail
- `Edit article`: update an existing authored article, optionally keeping the current thumbnail
- `My Articles`: author-scoped desk for published and archived articles

Important implementation details:

- the app only warms an anonymous Firebase session when `ENABLE_ANONYMOUS_AUTH=true`
- publishing and author-specific reads depend on a Firebase-authenticated user
- if anonymous auth is not enabled for the build or for the Firebase project, the public feed still works but publish and author-scoped flows fail with explicit Firebase auth guidance
- the home feed keeps Firestore articles first and appends NewsAPI headlines after them
- duplicate stories are filtered primarily by source URL

## Architecture Snapshot

The active production container is assembled in `lib/injection_container.dart` and currently wires:

- Firestore for article documents
- Firebase Storage for thumbnails
- Firebase Auth for the current author identity
- NewsAPI for external headlines
- Floor for local saved articles and draft persistence

The main feature lives under `lib/features/daily_news/` and is split into:

- `data/` for Firebase, NewsAPI and local data sources
- `domain/` for entities and use cases
- `presentation/` for BLoCs, pages and widgets

## Requirements

The checked-in project metadata currently expects:

- Flutter `>=3.38.0`
- Dart `>=3.10.0`
- JDK 17
- Android SDK
- Android NDK `27.0.12077973`

If the required NDK is missing, install it with:

```powershell
sdkmanager "ndk;27.0.12077973"
```

## Supported Platforms

Android is the only platform configured for the real app flow right now.

Why:

- `lib/firebase_options.dart` only contains Android Firebase options
- `bootstrapFirebaseForAndroidApp()` is the startup path used by `main()`
- the repo includes `android/app/google-services.json`

Web, iOS, macOS, Linux and Windows are not documented as supported targets for this Firebase-backed build yet.

## Firebase Setup

The repository already contains Android Firebase config for the current project:

- Firebase project id: `starter-project-a3191`
- Android app id: `1:842000705656:android:36dbe5071c89cb3f4ae58d`
- package name: `com.example.news_app_clean_architecture`

If you want to keep using the committed Firebase project, no extra setup is required beyond valid local Android tooling.

If you want to switch to another Firebase project:

1. Create or select a Firebase project.
2. Add an Android app with package name `com.example.news_app_clean_architecture`.
3. Replace `android/app/google-services.json`.
4. Regenerate `lib/firebase_options.dart` with FlutterFire CLI.
5. Update `frontend/firebase.json` if you use it as a local reference.
6. Deploy the backend rules and indexes from `../backend`.

FlutterFire CLI example:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

Firebase products expected by the current frontend:

- Authentication
- Cloud Firestore
- Cloud Storage

If you want article publishing to work without adding a custom sign-in screen, enable `Anonymous` in Firebase Authentication and run with:

```powershell
flutter run --dart-define=ENABLE_ANONYMOUS_AUTH=true
```

## NewsAPI Setup

The external headlines flow is active in production DI and currently uses:

- base URL: `https://newsapi.org/v2`
- endpoint: `/top-headlines`
- country: `us`
- category: `general`

The API key is injected at build/run time through `NEWS_API_KEY`.

Run with:

```powershell
flutter run --dart-define=NEWS_API_KEY=<your-key>
```

If `NEWS_API_KEY` is not provided, the app still boots and the feed still works with Firestore-backed articles, but the external NewsAPI headlines are skipped.

## Local Persistence

The app uses Floor/SQLite for on-device state that should survive app restarts.

Current local tables:

- `article`: saved articles
- `article_draft`: autosaved editor drafts

Draft behavior in the current build:

- create and edit screens load a draft after the page opens
- text changes are autosaved with a short debounce
- selected thumbnails are also persisted in the draft state
- successful publish/update clears the persisted draft

## Run The App

From `frontend/`:

```powershell
flutter pub get
flutter doctor -v
flutter run
```

Run with anonymous Firebase auth enabled for a controlled/local project:

```powershell
flutter run --dart-define=ENABLE_ANONYMOUS_AUTH=true
```

Run with external NewsAPI headlines enabled:

```powershell
flutter run --dart-define=NEWS_API_KEY=<your-key>
```

Run with both:

```powershell
flutter run --dart-define=NEWS_API_KEY=<your-key> --dart-define=ENABLE_ANONYMOUS_AUTH=true
```

Run on a specific Android emulator or device:

```powershell
flutter devices
flutter run -d <device-id>
```

Launch an emulator first if needed:

```powershell
flutter emulators
flutter emulators --launch <emulator-id>
flutter run -d <device-id>
```

## Firebase Emulators

The backend folder already defines Auth, Firestore, Storage and Emulator UI ports, but the frontend does not currently call `useEmulator(...)`.

That means:

- the mobile app talks to the configured Firebase project by default
- starting the Emulator Suite alone does not redirect the app to local endpoints
- emulator support is a future wiring task, not a documented frontend feature yet

## Recommended Verification Commands

From `frontend/`:

```powershell
flutter analyze
flutter test test/features/daily_news
flutter test
```

## Manual Smoke Test

Use this checklist for the current build:

1. Launch the app on Android.
2. Confirm the home feed loads published Firestore articles and appends NewsAPI headlines when available.
3. Open a Firestore-backed article and verify the detail screen shows title, author, date, image and body.
4. Open a NewsAPI-backed article and verify the same detail screen can render it.
5. Save an article from the detail screen and confirm it appears in `Saved Articles`.
6. Remove a saved article and confirm the list refreshes correctly.
7. Open `Create article`, select a thumbnail, fill in the form, and publish.
8. Confirm the new article appears in the home feed ahead of NewsAPI headlines.
9. Open `My Articles` and verify the newly published article appears there.
10. Edit that article and confirm the updated version is reflected in the feed and detail page.
11. Archive the article from `My Articles` or the detail page and confirm it disappears from the public feed while remaining visible in the author desk as archived.
12. If anonymous auth is disabled in Firebase Auth, verify publish and `My Articles` fail with explicit auth guidance instead of crashing the app.

## Known Limitations

- There is no user-facing sign-in UI yet. The app relies on the current Firebase session and anonymous auth fallback.
- Non-Android Firebase targets are not configured.
- A valid `NEWS_API_KEY` must be provided at runtime if you want external headlines.
- Anonymous Firebase auth is disabled by default in the public build unless you opt in with `ENABLE_ANONYMOUS_AUTH=true`.
- Emulator Suite support is not wired into the frontend bootstrap layer yet.

## Public Repo Note

If this repository is published publicly, the safest setup is:

- keep `NEWS_API_KEY` out of git
- keep the default build without `ENABLE_ANONYMOUS_AUTH`
- avoid relying on `Anonymous` auth on a shared public Firebase project
- use your own Firebase project locally if you want to test the full create/edit/archive flow

The Firebase Android config files identify the client app, but the higher-risk part for this project is anonymous write access to Firestore and Storage when the shared backend stays enabled.

## Reference Docs

- [Contribution Guidelines](../docs/CONTRIBUTION_GUIDELINES.md)
- [Architecture Violations](../docs/ARCHITECTURE_VIOLATIONS.md)
- [Code Quality Violations](../docs/CODING_GUIDELINES.md)
- [App Architecture](../docs/APP_ARCHITECTURE.md)
