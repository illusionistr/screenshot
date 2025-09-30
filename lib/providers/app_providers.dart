import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/services/analytics_service.dart';
import '../core/services/firebase_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/translation_service.dart';
import '../features/auth/services/auth_service.dart';
import '../features/projects/services/project_service.dart';
import '../features/shared/services/upload_service.dart';

part 'app_providers.g.dart';

@riverpod
FirebaseService firebaseService(Ref ref) => FirebaseService();

@riverpod
AuthService authService(Ref ref) => AuthService(
  firebaseService: ref.read(firebaseServiceProvider),
);

@riverpod
ProjectService projectService(Ref ref) => ProjectService(
  firebaseService: ref.read(firebaseServiceProvider),
  storageService: ref.read(storageServiceProvider),
  uploadService: ref.read(uploadServiceProvider),
);

@riverpod
StorageService storageService(Ref ref) => StorageService();

@riverpod
AnalyticsService analyticsService(Ref ref) => AnalyticsService();

@riverpod
UploadService uploadService(Ref ref) => UploadService(
  ref.read(firebaseServiceProvider).storage,
);

@riverpod
TranslationService translationService(Ref ref) {
  print('[AppProviders] Creating TranslationService instance');
  final service = TranslationService();
  print('[AppProviders] TranslationService created, initializing...');
  // Initialize the service asynchronously
  service.initialize().then((_) {
    print('[AppProviders] TranslationService initialization completed');
  }).catchError((error) {
    print('[AppProviders] TranslationService initialization failed: $error');
  });
  return service;
}