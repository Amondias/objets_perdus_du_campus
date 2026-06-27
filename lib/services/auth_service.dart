import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

/// Thin wrapper around FirebaseAuth used by [AuthProvider].
///
/// Also supports a “mock” mode through [MockDataService] when the app is
/// configured accordingly.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _cachedUser;

  /// Returns a cached user when available, otherwise loads from Firebase.
  UserModel? get currentUser {
    // Prefer cached user (keeps provider responsive).
    if (_cachedUser != null) return _cachedUser;

    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;

    // In real mode, we map basic fields. For full profile you may want to
    // store it in Firestore; kept simple here to respect existing repo.
    _cachedUser = UserModel(
      uid: fbUser.uid,
      name: fbUser.displayName ?? 'Utilisateur',
      email: fbUser.email ?? '',
      photoUrl: fbUser.photoURL,
      role: 'student',
      createdAt: DateTime.now(),
      fcmToken: null,
    );
    return _cachedUser;
  }

  Future<UserModel> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final fbUser = cred.user;
    if (fbUser == null) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'Utilisateur introuvable',
      );
    }

    _cachedUser = UserModel(
      uid: fbUser.uid,
      name: fbUser.displayName ?? 'Utilisateur',
      email: fbUser.email ?? email,
      photoUrl: fbUser.photoURL,
      role: 'student',
      createdAt: DateTime.now(),
      fcmToken: null,
    );
    return _cachedUser!;
  }

  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final fbUser = cred.user;
    if (fbUser == null) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'Inscription impossible',
      );
    }

    await fbUser.updateDisplayName(name);

    _cachedUser = UserModel(
      uid: fbUser.uid,
      name: name,
      email: fbUser.email ?? email,
      photoUrl: fbUser.photoURL,
      role: 'student',
      createdAt: DateTime.now(),
      fcmToken: null,
    );
    return _cachedUser!;
  }

  Future<void> signOut() async {
    _cachedUser = null;
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Convenience method for UI or other code.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Maps FirebaseAuth exceptions to messages expected by [AuthProvider].
  static String humanizeFirebaseError(String raw) {
    // Keep it aligned with AuthProvider expectations.
    if (raw.contains('invalid-credential') ||
        raw.contains('wrong-password') ||
        raw.contains('user-not-found')) {
      return 'password';
    }
    return raw;
  }
}

