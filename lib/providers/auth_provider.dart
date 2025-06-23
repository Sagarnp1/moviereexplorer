import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  String? get userEmail => _user?.email;
  String? get userName => _user?.displayName;
  String? get userPhotoUrl => _user?.photoURL;
  String get userDisplayName => _user?.displayName ?? _user?.email?.split('@')[0] ?? 'User';

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = _authService.currentUser;

      _authService.authStateChanges.listen((User? user) {
        final bool wasAuthenticated = _user != null;
        final bool isNowAuthenticated = user != null;

        _user = user;
        _errorMessage = null;

        if (wasAuthenticated != isNowAuthenticated || !_isInitialized) {
          notifyListeners();
        }
      }, onError: (error) {
        _errorMessage = 'Authentication error: $error';
        notifyListeners();
      });

    } catch (e) {
      _errorMessage = 'Failed to initialize authentication: $e';
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      _errorMessage = 'Please enter both email and password';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
          email.trim(),
          password
      );

      if (userCredential != null && userCredential.user != null) {
        _user = userCredential.user;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = 'Sign in failed. Please try again.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> registerWithEmailAndPassword(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      _errorMessage = 'Please enter both email and password';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'Password must be at least 6 characters long';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final userCredential = await _authService.registerWithEmailAndPassword(
          email.trim(),
          password
      );

      if (userCredential != null && userCredential.user != null) {
        _user = userCredential.user;

        if (_user != null && !_user!.emailVerified) {
          await _user!.sendEmailVerification();
        }

        _setLoading(false);
        return true;
      } else {
        _errorMessage = 'Registration failed. Please try again.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        _user = userCredential.user;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = 'Google sign-in was cancelled or failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      _user = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      _errorMessage = 'Please enter your email address';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email.trim());
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile({String? displayName, String? photoURL}) async {
    if (_user == null) {
      _errorMessage = 'No user is currently signed in';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _user!.updateDisplayName(displayName);
      if (photoURL != null) {
        await _user!.updatePhotoURL(photoURL);
      }

      await _user!.reload();
      _user = _authService.currentUser;

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendEmailVerification() async {
    if (_user == null) {
      _errorMessage = 'No user is currently signed in';
      notifyListeners();
      return false;
    }

    if (_user!.emailVerified) {
      _errorMessage = 'Email is already verified';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _user!.sendEmailVerification();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send verification email: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> reloadUser() async {
    if (_user == null) return;

    try {
      await _user!.reload();
      _user = _authService.currentUser;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to reload user data: $e';
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    if (_user == null) {
      _errorMessage = 'No user is currently signed in';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _user!.delete();
      _user = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete account: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> reauthenticateWithPassword(String password) async {
    if (_user == null || _user!.email == null) {
      _errorMessage = 'No user is currently signed in';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: password,
      );

      await _user!.reauthenticateWithCredential(credential);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Reauthentication failed: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_user == null) {
      _errorMessage = 'No user is currently signed in';
      notifyListeners();
      return false;
    }

    if (newPassword.length < 6) {
      _errorMessage = 'New password must be at least 6 characters long';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final reauthSuccess = await reauthenticateWithPassword(currentPassword);
      if (!reauthSuccess) {
        return false;
      }

      await _user!.updatePassword(newPassword);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to change password: $e';
      _setLoading(false);
      return false;
    }
  }

  bool get isEmailVerified => _user?.emailVerified ?? false;

  DateTime? get userCreationTime => _user?.metadata.creationTime;

  DateTime? get lastSignInTime => _user?.metadata.lastSignInTime;

  List<String> get signInMethods {
    if (_user == null) return [];
    return _user!.providerData.map((info) => info.providerId).toList();
  }

  bool get isGoogleUser => signInMethods.contains('google.com');

  bool get isEmailUser => signInMethods.contains('password');

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String get userInitials {
    if (_user?.displayName != null && _user!.displayName!.isNotEmpty) {
      final names = _user!.displayName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else {
        return names[0][0].toUpperCase();
      }
    } else if (_user?.email != null) {
      return _user!.email![0].toUpperCase();
    }
    return 'U';
  }

  String get greeting {
    final hour = DateTime.now().hour;
    final name = userDisplayName;

    if (hour < 12) {
      return 'Good Morning, $name!';
    } else if (hour < 17) {
      return 'Good Afternoon, $name!';
    } else {
      return 'Good Evening, $name!';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}