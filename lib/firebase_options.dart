import 'package:firebase_core/firebase_core.dart';

/// Placeholder FirebaseOptions.
///
/// Replace this file by running:
/// dart pub global activate flutterfire_cli
/// flutterfire configure
///
/// Then import DefaultFirebaseOptions.currentPlatform in main.dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // TODO: Replace with values from FlutterFire CLI
    return const FirebaseOptions(
      apiKey: 'REPLACE_WITH_API_KEY',
      appId: 'REPLACE_WITH_APP_ID',
      messagingSenderId: 'REPLACE_WITH_SENDER_ID',
      projectId: 'REPLACE_WITH_PROJECT_ID',
      storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
    );
  }
}


