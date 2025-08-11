# App Screenshot Studio (Phase 1)

Foundation for a Flutter Web app to create and manage app screenshot projects (similar to Appure).

## Features (Phase 1)
- Email/password authentication (Firebase Auth)
- User profile documents in Firestore
- Projects: create and list with platforms and devices
- Routing with guards, DI with GetIt, state with Provider

## Setup
1) Install Flutter (stable) and enable web: `flutter config --enable-web`
2) Install Firebase CLI and FlutterFire CLI:
   - `npm i -g firebase-tools`
   - `dart pub global activate flutterfire_cli`
3) Create a Firebase project and run:
   - `flutterfire configure`
   - This generates `lib/firebase_options.dart`. Replace the placeholder already in this repo.
4) Apply Firestore rules:
   - `firebase deploy --only firestore:rules`
5) Run the app:
   - `flutter run -d chrome`

## Firestore Structure
- `users/{userId}`: email, displayName, createdAt, exportCount, lastExportAt
- `projects/{projectId}`: userId, appName, platforms[], devices{platform:[]}, createdAt, updatedAt

## Routes
- `/` wrapper, `/login`, `/signup`, `/dashboard`, `/projects/create`

## Notes
- Replace color/typography as needed in `lib/core/theme/app_theme.dart`.
- Firebase service provides generic CRUD and upload helpers for future phases.
