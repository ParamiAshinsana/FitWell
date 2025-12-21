import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  User? get currentUser => _authRepository.currentUser;
  bool get isAuthenticated => currentUser != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _authRepository.authStateChanges.listen(
      (user) {
        notifyListeners();
      },
      onError: (error) {
        print('Auth state stream error: $error');
        _errorMessage = 'Authentication error occurred';
        notifyListeners();
      },
    );
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.signIn(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      String errorMessage = 'Login failed. Please try again.';
      
      final errorStr = e.toString();
      
      if (errorStr.contains('user-not-found')) {
        errorMessage = 'No account found with this email. Please sign up first.';
      } else if (errorStr.contains('wrong-password') || errorStr.contains('invalid-credential')) {
        errorMessage = 'Incorrect password. Please try again.';
      } else if (errorStr.contains('invalid-email')) {
        errorMessage = 'Invalid email address. Please check and try again.';
      } else if (errorStr.contains('user-disabled')) {
        errorMessage = 'This account has been disabled. Please contact support.';
      } else if (errorStr.contains('too-many-requests')) {
        errorMessage = 'Too many login attempts. Please try again later.';
      } else if (errorStr.contains('network-request-failed')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (errorStr.contains('permission-denied')) {
        errorMessage = 'Permission denied. Please check Firestore security rules.';
      } else if (errorStr.contains('Exception: ')) {
        final parts = errorStr.split('Exception: ');
        if (parts.length > 1) {
          errorMessage = parts[1].trim();
        }
      } else {
        errorMessage = errorStr;
      }
      
      _errorMessage = errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      final errorStr = e.toString().replaceAll('Exception: ', '');
      if (errorStr.contains('[cloud_firestore/permission-denied]')) {
        _errorMessage = 'Permission denied. Please check Firestore security rules.';
      } else if (errorStr.contains('permission-denied')) {
        _errorMessage = 'Permission denied. Please check Firestore security rules.';
      } else {
        _errorMessage = errorStr;
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.resetPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      final errorStr = e.toString().replaceAll('Exception: ', '');
      if (errorStr.contains('[cloud_firestore/permission-denied]')) {
        _errorMessage = 'Permission denied. Please check Firestore security rules.';
      } else if (errorStr.contains('permission-denied')) {
        _errorMessage = 'Permission denied. Please check Firestore security rules.';
      } else {
        _errorMessage = errorStr;
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

