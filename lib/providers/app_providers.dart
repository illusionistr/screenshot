import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/services/analytics_service.dart';
import '../core/services/firebase_service.dart';
import '../core/services/storage_service.dart';
import '../features/auth/services/auth_service.dart';
import '../features/projects/services/project_service.dart';

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
);

@riverpod
StorageService storageService(Ref ref) => StorageService();

@riverpod
AnalyticsService analyticsService(Ref ref) => AnalyticsService();