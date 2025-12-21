import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  User? get currentUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
    );
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }
}

