# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Essential Commands
- **Run the app**: `flutter run -d chrome` (web development)
- **Analyze code**: `flutter analyze` (lint checking and static analysis)
- **Run tests**: `flutter test`
- **Clean build**: `flutter clean && flutter pub get`
- **Install dependencies**: `flutter pub get`
- **Generate Riverpod code**: `dart run build_runner build` (generates provider files)

### Firebase Commands
- **Deploy Firestore rules**: `firebase deploy --only firestore:rules`
- **Deploy Storage rules**: `firebase deploy --only storage`
- **Configure Firebase**: `flutterfire configure` (generates firebase_options.dart)

## Architecture Overview

### Core Architecture
This is a Flutter web application following a **feature-driven architecture** with clean separation of concerns:

- **State Management**: Riverpod with code generation and AsyncNotifier pattern
- **Dependency Injection**: Riverpod providers (no external DI container needed)
- **Routing**: GoRouter with authentication guards and route protection
- **Backend**: Firebase (Auth, Firestore, Storage)

### Directory Structure
```
lib/
├── config/                    # App configuration
│   └── routes.dart               # GoRouter configuration with auth guards
├── core/                      # Shared utilities and services
│   ├── services/              # Core services (Firebase, Storage, Analytics)
│   ├── theme/                 # App theme configuration
│   ├── utils/                 # Helpers, validators, extensions
│   └── widgets/               # Reusable UI components
├── features/                  # Feature modules
│   ├── auth/                  # Authentication (login/signup/providers)
│   ├── editor/                # Screenshot editor with frame rendering
│   ├── projects/              # Project management (CRUD, UI)
│   └── shared/                # Shared feature components and services
├── providers/                 # Global Riverpod providers
│   └── app_providers.dart        # Service providers (Firebase, Auth, etc.)
├── firebase_options.dart      # Auto-generated Firebase config
└── main.dart                  # App entry point with ProviderScope
```

### Key Patterns

**Service Layer**: All business logic is encapsulated in services (AuthService, ProjectService, UploadService, StorageService, AnalyticsService) that interact with Firebase through the FirebaseService abstraction.

**Riverpod Pattern**: UI state is managed through AsyncNotifier providers with AsyncValue for loading/error states. Providers use code generation for type safety.

**Feature Organization**: Each feature (auth, projects, editor) contains its own models, providers, screens, services, and widgets in isolated directories.

**Dependency Injection**: Services are provided through Riverpod providers in `app_providers.dart` and accessed via ref throughout the app.

**Frame System**: Advanced device frame rendering with automatic fallback to generic frames when real frame assets are unavailable. Supports dynamic asset validation and smart frame selection.

## Firebase Integration

### Firestore Structure
- `users/{userId}`: User profiles with email, displayName, createdAt, exportCount, lastExportAt
- `projects/{projectId}`: Project data with userId, appName, platforms[], devices{}, timestamps

### Authentication Flow
- AuthWrapper checks authentication state and redirects appropriately
- Route guards prevent access to protected routes (/dashboard, /projects/*) when not authenticated
- AuthProvider manages user state and exposes authentication status to routing system

### Storage Configuration
- Firebase Storage for screenshot and project asset uploads
- Custom CORS configuration in `cors.json` for web compatibility
- Upload service handles file management and storage operations

## Development Notes

### Firebase Setup Required
1. Create Firebase project
2. Run `flutterfire configure` to generate firebase_options.dart
3. Deploy Firestore rules: `firebase deploy --only firestore:rules`
4. Deploy Storage rules: `firebase deploy --only storage`
5. Configure CORS for Storage: `gsutil cors set cors.json gs://your-bucket-name`

### Theme Customization
Modify colors and typography in `lib/core/theme/app_theme.dart` as needed.

### Adding New Features
1. Create feature directory under `lib/features/`
2. Follow existing patterns: models, providers, screens, services, widgets
3. Add new service providers to `app_providers.dart` using `@riverpod` annotation
4. Add routes in `routes.dart` with appropriate guards
5. Run `dart run build_runner build` after adding new providers

### Riverpod Usage Patterns
- Use `@riverpod` for service providers and data providers
- Use stream providers for reactive data (auth state, projects list)
- Use `AsyncNotifier` for simple action providers (signIn, createProject, etc.)
- Use `ConsumerWidget` for widgets that read providers
- Use `ConsumerStatefulWidget` for stateful widgets with providers
- Handle async state with `AsyncValue.when()` pattern
- Use `ref.watch()` for reactive dependencies
- Use `ref.read()` for one-time operations
- Use `ref.listen()` for side effects (navigation, snackbars)
- Use `ref.invalidate()` to refresh data after mutations

### Common Patterns
- **Stream Data**: Use direct stream providers for real-time data
- **Actions**: Use simple notifiers that call services and invalidate data
- **Error Handling**: Use try/catch in UI and show SnackBar for errors
- **Loading States**: Let stream providers handle loading, actions should be fast

## Frame System Architecture

### Core Features
- **Asset Validation**: Runtime checking of frame asset availability with automatic fallback
- **Smart Selection**: Prioritizes real device frames over generic alternatives
- **Visual Indicators**: Clear UI distinction between real and generic frames
- **Performance**: Asset availability caching to minimize repeated checks

### Key Services
- **FrameAssetService**: Handles asset validation and availability checking
- **DeviceService**: Manages device-specific frame variants and fallback logic
- **FrameRenderer**: Renders device frames with smart fallback to generic borders

### Asset Organization
Frame assets follow a consistent structure in `assets/frames/` with device-specific folders using kebab-case naming (e.g., `iphone-15-pro/`, `pixel-8-pro/`). Generic frames provide fallbacks when real frame assets are unavailable.
