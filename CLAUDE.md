# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is "App Screenshot Studio" - a Flutter web application for creating and managing app screenshot projects, similar to Appure. The app uses Firebase for backend services and is currently in Phase 1 development with basic authentication and project management features.

## Development Commands

### Running the App
```bash
flutter run -d chrome
```

### Code Quality
```bash
flutter analyze
flutter test
```

### Building
```bash
flutter build web
```

### Firebase Management
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Configure Firebase (after creating a new Firebase project)
flutterfire configure
```

## Architecture

### Core Structure
- **Provider + GetIt**: State management with Provider, dependency injection with GetIt
- **Go Router**: Declarative routing with authentication guards
- **Firebase**: Authentication, Firestore for data, Storage for file uploads
- **Feature-based**: Organized by features (auth, projects, editor) with shared core utilities

### Key Directories
- `lib/features/`: Feature modules (auth, projects, editor)
- `lib/core/`: Shared services, themes, widgets, utilities
- `lib/config/`: App configuration (DI setup, routing)
- `assets/`: Device mockups, fonts, images

### Firebase Architecture
- **Collections**: `users/{userId}`, `projects/{projectId}`
- **Authentication**: Email/password via Firebase Auth
- **Generic Service**: `FirebaseService` provides CRUD operations and file uploads

### State Management Pattern
- `AuthProvider`: Global authentication state
- `ProjectProvider`: Project management, depends on `AuthProvider`
- Services registered in `dependency_injection.dart` and accessed via `serviceLocator<T>()`

### Routing
- Authentication guards redirect unauthenticated users to `/login`
- Main routes: `/`, `/login`, `/signup`, `/dashboard`, `/projects/create`, `/projects/:id/editor`
- Router refreshes when `AuthProvider` state changes

## Data Models

### ProjectModel
- Single platform selection (android/ios)
- Multiple device selection per platform
- Firebase integration with `fromFirestore()` and `toFirestore()` methods

## Setup Requirements

1. Flutter SDK with web support enabled
2. Firebase CLI and FlutterFire CLI installed
3. Firebase project configured with generated `firebase_options.dart`
4. Firestore rules deployed (currently open for development)

## Development Notes

- App targets web platform primarily
- Device mockups stored in `assets/` for different platforms
- Custom font (Darlington) included in assets
- Firestore rules are currently permissive for development (expire 2025-09-09)
- Firebase project ID: `screenshot-saas`