import 'package:get_it/get_it.dart';

import '../core/services/analytics_service.dart';
import '../core/services/firebase_service.dart';
import '../core/services/storage_service.dart';
import '../features/auth/services/auth_service.dart';
import '../features/projects/services/project_service.dart';
import '../features/editor/services/screen_service.dart';
import '../features/editor/services/screenshot_manager.dart';

final GetIt serviceLocator = GetIt.instance;

void setupDependencyInjection() {
  if (serviceLocator.isRegistered<FirebaseService>()) {
    return;
  }

  // Core services
  serviceLocator.registerLazySingleton<FirebaseService>(
    () => FirebaseService(),
  );
  serviceLocator.registerLazySingleton<StorageService>(
    () => StorageService(),
  );
  serviceLocator.registerLazySingleton<AnalyticsService>(
    () => AnalyticsService(),
  );

  // Feature services
  serviceLocator.registerLazySingleton<AuthService>(
    () => AuthService(firebaseService: serviceLocator<FirebaseService>()),
  );
  serviceLocator.registerLazySingleton<ProjectService>(
    () => ProjectService(firebaseService: serviceLocator<FirebaseService>()),
  );
  serviceLocator.registerLazySingleton<ScreenService>(
    () => ScreenService(firebaseService: serviceLocator<FirebaseService>()),
  );
  serviceLocator.registerLazySingleton<ScreenshotManager>(
    () => ScreenshotManager(
      storageService: serviceLocator<StorageService>(),
      firebaseService: serviceLocator<FirebaseService>(),
    ),
  );
}


