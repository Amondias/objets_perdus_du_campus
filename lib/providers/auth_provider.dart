import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/mock_data_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

/// ViewModel for authentication state.
class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAdmin => _user?.isAdmin ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Restore session from MockDataService (already seeded)
    final currentUser = AuthService.instance.currentUser;
    if (currentUser != null) {
      _user = currentUser;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading();
    try {
      _user = await AuthService.instance.signInWithEmail(email, password);
      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanizeError(e.toString());
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      _user = await AuthService.instance.signUpWithEmail(
        name: name, email: email, password: password,
      );
      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanizeError(e.toString());
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await AuthService.instance.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _error = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _setLoading();
    try {
      await AuthService.instance.resetPassword(email);
      _status = _user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _humanizeError(e.toString());
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  void updateUser(UserModel updated) {
    _user = updated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
  }

  String _humanizeError(String raw) {
    if (raw.contains('introuvable')) return 'Aucun compte avec cet email.';
    if (raw.contains('déjà utilisé')) return 'Cet email est déjà utilisé.';
    if (raw.contains('password')) return 'Mot de passe incorrect.';
    return 'Une erreur est survenue. Veuillez réessayer.';
  }
}
