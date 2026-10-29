import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code});

  final String message;
  final String? code;

  factory AuthFailure.fromFirebase(FirebaseAuthException error) {
    return AuthFailure(switch (error.code) {
      'invalid-email' => 'El correo no es válido.',
      'weak-password' || 'password-does-not-meet-requirements' =>
        'Usa de 8 a 128 caracteres, mayúscula, minúscula, número y símbolo.',
      'expired-action-code' => 'El enlace venció. Solicita uno nuevo.',
      'invalid-action-code' => 'El enlace no es válido o ya se utilizó.',
      'unauthorized-continue-uri' || 'invalid-continue-uri' =>
        'No se pudo enviar el enlace. Intenta más tarde.',
      'email-already-in-use' => 'Ya existe una cuenta con este correo.',
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Correo o contraseña incorrectos.',
      'user-disabled' =>
        'Tu cuenta no está disponible. Puedes solicitar una revisión en unimatch7@gmail.com.',
      'requires-recent-login' =>
        'Confirma tu identidad iniciando sesión de nuevo.',
      'too-many-requests' => 'Demasiados intentos. Intenta más tarde.',
      'network-request-failed' => 'No fue posible conectarse a Firebase.',
      _ => 'No fue posible completar la autenticación.',
    }, code: error.code);
  }

  factory AuthFailure.fromGoogle(GoogleSignInException error) {
    if (error.code == GoogleSignInExceptionCode.canceled) {
      return const AuthFailure(
        'Inicio de sesión con Google cancelado.',
        code: 'canceled',
      );
    }
    return const AuthFailure(
      'No fue posible iniciar sesión con Google.',
      code: 'google-sign-in-failed',
    );
  }

  @override
  String toString() => message;
}
