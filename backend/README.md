# Firebase Firestore Backend
In this folder are all the [Firebase Firestore](https://firebase.google.com/docs/firestore) related files. 
You will use this folder to add the schema of the *Articles* you want to upload for the app and to add the rules that enforce this schema. 

## DB Schema
The Firestore schema for this assignment is documented in [docs/DB_SCHEMA.md](./docs/DB_SCHEMA.md).

## Firestore Indexes
The `firestore.indexes.json` file contains composite indexes for the `articles` collection.

Why we add them:
- Firestore can store documents without these indexes, but more specific queries often require composite indexes to run efficiently.
- Our article schema is expected to support filtered and ordered reads such as:
  - published articles ordered by publication date,
  - published articles by category ordered by publication date,
  - articles created by one author ordered by creation date.

What this improves:
- It prepares the backend for real query patterns before the frontend data layer is connected.
- It avoids runtime query failures when Firestore requires a composite index.
- It makes reads more predictable and keeps the backend implementation aligned with the schema design.

## Getting Started
Before starting to work on the backend, you must have a Firebase project with the following technologies enabled:
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Firebase Cloud Storage](https://firebase.google.com/docs/storage)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Firebase Local Emulator Suite](https://firebase.google.com/docs/emulator-suite)

For this assignment, Authentication is useful because the article schema includes an `authorId` field that should map cleanly to a Firebase Auth user.


## Deploying the Project
In order to deploy the Firestore rules from this repository to the [Firebase console](https://firebase.google.com/)  of your project, follow these steps:

### 1. Install firebase CLI
```
npm install -g firebase-tools
```
### 2. Login to your account
```
firebase login
```

### 3. Add your project id to the .firebaserc file 
This corresponds to the project Id of the firebase project you created in the Firebase web-app.
[Change project id](.firebaserc)

### 4. Initialize the project
```
firebase init
```

You should leave everything as it is, choose:
- emulators
- firestore
- cloud storage

When configuring emulators, select:
- Authentication Emulator
- Firestore Emulator
- Storage Emulator
- Emulator UI

### 5. Deploy to firebase
```
firebase deploy
```
This will deploy all the rules you write in `firestore.rules` to your Firebase Firestore project.
It will also deploy the indexes declared in `firestore.indexes.json` and the rules declared in `storage.rules`.
Be careful because it will overwrite the existing Firebase configuration of your project for those resources.

## Running the project in a local emulator
To run the application locally, use the following command:

```firebase emulators:start```
