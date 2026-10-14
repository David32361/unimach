import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimatch_user/core/errors/auth_failure.dart';
import 'package:unimatch_user/services/auth_service.dart';

class AuthRepository {
  AuthRepository(this._service);

  final AuthService _service;

  Stream<User?> authStateChanges() => _service.authStateChanges();

  Future<void> register(String email, String password) async {
    try {
      await _service.register(email, password);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure.fromFirebase(error);
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _service.signIn(email, password);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure.fromFirebase(error);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _service.signInWithGoogle();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure.fromFirebase(error);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _service.sendPasswordReset(email);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure.fromFirebase(error);
    }
  }

  Future<void> signOut() => _service.signOut();
}
