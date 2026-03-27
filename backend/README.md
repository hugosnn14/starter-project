# Firebase Backend

This folder contains the Firebase resources used by the current Daily News app.

Today this backend is responsible for:

- the Firestore article schema contract
- Firestore security rules for article ownership and publication state
- Storage rules for article thumbnails under `media/articles/...`
- Firestore composite indexes required by the active queries
- Emulator Suite configuration for Auth, Firestore and Storage

There are no Cloud Functions in this repository at the moment. The mobile app writes directly to Firebase.

## Files In This Folder

- `docs/DB_SCHEMA.md`: article document schema and rationale
- `firestore.rules`: document-level validation and access control
- `storage.rules`: thumbnail upload and read access rules
- `firestore.indexes.json`: composite indexes for current query patterns
- `firebase.json`: Firebase resource wiring plus emulator ports
- `.firebaserc`: default Firebase project selection for this repo

## Current Data Contract

The Firestore schema for journalist-created articles is documented in [docs/DB_SCHEMA.md](./docs/DB_SCHEMA.md).

The important fields used by the current frontend are:

- `authorId`
- `authorName`
- `title`
- `description`
- `content`
- `category`
- `thumbnailPath`
- `status`
- `publishedAt`
- `createdAt`
- `updatedAt`
- `sourceUrl`
- `tags`

Thumbnail files must live in Firebase Storage under:

```text
media/articles/{articleId}/thumbnail.{extension}
```

## How The Frontend Uses This Backend

The active Flutter app uses these backend query patterns:

- public feed:
  - `where('status', isEqualTo: 'published')`
  - `orderBy('publishedAt', descending: true)`
- author desk:
  - `where('authorId', isEqualTo: currentUserId)`
  - `orderBy('createdAt', descending: true)`
- archive:
  - update article `status` to `archived`
- thumbnails:
  - upload to `media/articles/{articleId}/thumbnail.{extension}`

The frontend can use anonymous Firebase auth for publishing, but only when the app is run with:

```powershell
flutter run --dart-define=ENABLE_ANONYMOUS_AUTH=true
```

## Firestore Rules Summary

The current rules enforce that:

- anyone can read published articles
- authors can read their own unpublished or archived articles
- only the authenticated owner can create, update or delete an article
- article documents must match the schema described in `docs/DB_SCHEMA.md`
- `createdAt` and `updatedAt` are expected to be written with server timestamps
- `thumbnailPath` must follow the expected `media/articles/{articleId}/thumbnail.*` convention

## Storage Rules Summary

The current Storage rules enforce that:

- thumbnails live under `media/articles/{articleId}/`
- only the article owner can upload, replace or delete the thumbnail
- published article thumbnails are publicly readable
- unpublished thumbnails are only readable by their owner
- uploads must be images
- uploads must be smaller than 5 MB

## Firestore Indexes

`firestore.indexes.json` already contains the composite indexes needed by the current app:

- `status ASC, publishedAt DESC`
- `category ASC, status ASC, publishedAt DESC`
- `authorId ASC, createdAt DESC`

These indexes support the active read flows and prevent Firestore query failures once the frontend hits real data.

## Prerequisites

Before deploying or emulating this backend, make sure your Firebase project has:

- Cloud Firestore
- Cloud Storage
- Firebase Authentication
- Firebase Local Emulator Suite

If you want the current frontend publishing flow to work without adding a custom login UI:

1. enable `Anonymous` in Firebase Authentication
2. run the app with `--dart-define=ENABLE_ANONYMOUS_AUTH=true`

## Current Project Selection

`.firebaserc` currently points to:

```json
{
  "projects": {
    "default": "starter-project-a3191"
  }
}
```

If you want to use a different Firebase project:

1. Update `.firebaserc` or run `firebase use --add`.
2. Redeploy the rules and indexes from this folder.
3. Update the Android frontend config in `../frontend/android/app/google-services.json`.
4. Regenerate `../frontend/lib/firebase_options.dart`.

## Deploy Rules And Indexes

Run these commands from `backend/`:

```powershell
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Use a full deploy only if you really want to push every configured Firebase resource:

```powershell
firebase deploy
```

This repository is already initialized, so `firebase init` is not required unless you intentionally want to replace the existing Firebase configuration.

## Run The Emulator Suite

From `backend/`:

```powershell
firebase emulators:start
```

The current emulator ports defined in `firebase.json` are:

- Auth: `9099`
- Firestore: `8080`
- Storage: `9199`
- Emulator UI: enabled

Important limitation:

- the frontend does not currently call `useEmulator(...)`
- starting emulators does not automatically redirect the mobile app to local Firebase services
- emulator support is available for backend validation and future local wiring, but is not yet a finished end-to-end app workflow

## Public Repo Note

If this repository is public, the safer default is to keep the shared/public build without `ENABLE_ANONYMOUS_AUTH`.

That way:

- the shared app configuration can still be used for read-oriented review flows
- anonymous write access is not attempted by default from the mobile app
- reviewers who want to test the full publishing flow can do so against their own controlled Firebase project

## Notes For Backend Changes

Keep the following frontend assumptions in mind when editing rules or schema:

- published articles must remain queryable by `publishedAt`
- author-scoped reads must remain queryable by `authorId` and `createdAt`
- article ids are used as the canonical link between Firestore documents and Storage folders
- the mobile app resolves `thumbnailPath` into a download URL at read time
- if thumbnail upload fails after article creation, the frontend repository currently attempts a best-effort Firestore rollback

## Reference Docs

- [DB Schema](./docs/DB_SCHEMA.md)
