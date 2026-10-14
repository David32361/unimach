import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code});

  final String message;
  final String? code;

  factory AuthFailure.fromFirebase(FirebaseAuthException error) {
    return AuthFailure(switch (error.code) {
      'invalid-email' => 'El correo no es valido.',
      'weak-password' => 'La contrasena debe tener al menos 6 caracteres.',
      'email-already-in-use' => 'Ya existe una cuenta con este correo.',
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Correo o contrasena incorrectos.',
      'user-disabled' => 'Esta cuenta se encuentra deshabilitada.',
      'too-many-requests' => 'Demasiados intentos. Intenta mas tarde.',
      'network-request-failed' => 'No fue posible conectarse a Firebase.',
      _ => 'No fue posible completar la autenticacion.',
    }, code: error.code);
  }

  factory AuthFailure.fromGoogle(GoogleSignInException error) {
    if (error.code == GoogleSignInExceptionCode.canceled) {
      return const AuthFailure(
        'Inicio de sesion con Google cancelado.',
        code: 'canceled',
      );
    }
    return const AuthFailure(
      'No fue posible iniciar sesion con Google.',
      code: 'google-sign-in-failed',
    );
  }

  @override
  String toString() => message;
}
