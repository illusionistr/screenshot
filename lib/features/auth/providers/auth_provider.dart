import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/app_providers.dart';
import '../models/user_model.dart';

part 'auth_provider.g.dart';

// Main auth state stream provider
@riverpod
Stream<AppUser?> authStateStream(Ref ref) {
  final authService = ref.read(authServiceProvider);
  
  return authService.authStateChanges().map((firebaseUser) {
    if (firebaseUser == null) {
      return null;
    } else {
      // Lightweight current user representation; details loaded via sign-in/up
      return AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        createdAt: DateTime.now(),
        exportCount: 0,
      );
    }
  });
}

// Auth notifier for auth actions (sign in, sign up, sign out)
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  String build() {
    return 'ready'; // Simple state tracker
  }

  Future<void> signUp(String email, String password, {String? displayName}) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmail(
        email: email,
        password: password,
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
    } catch (error) {
      rethrow;
    }
  }
}

// Computed providers for convenience
@riverpod
bool isAuthenticated(Ref ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
}

@riverpod
AppUser? currentUser(Ref ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
}