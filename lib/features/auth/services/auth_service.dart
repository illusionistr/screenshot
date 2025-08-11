import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService({required this.firebaseService});

  final FirebaseService firebaseService;

  FirebaseAuth get _auth => firebaseService.auth;
  FirebaseFirestore get _db => firebaseService.firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user!;
    if (displayName != null && displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
    }
    final appUser = AppUser(
      id: user.uid,
      email: email,
      displayName: displayName ?? user.displayName,
      createdAt: DateTime.now(),
      exportCount: 0,
    );
    await _db.collection(ApiConstants.usersCollection).doc(user.uid).set(appUser.toFirestore());
    return appUser;
  }

  Future<AppUser> signInWithEmail({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = credential.user!;
    final doc = await _db.collection(ApiConstants.usersCollection).doc(user.uid).get();
    if (!doc.exists) {
      // Create a minimal user document if not present
      final appUser = AppUser(
        id: user.uid,
        email: user.email ?? email,
        displayName: user.displayName,
        createdAt: DateTime.now(),
        exportCount: 0,
      );
      await _db.collection(ApiConstants.usersCollection).doc(user.uid).set(appUser.toFirestore());
      return appUser;
    }
    return AppUser.fromFirestore(doc);
  }

  Future<void> signOut() => _auth.signOut();
}


