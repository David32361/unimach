import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileFailure implements Exception {
  const ProfileFailure(this.message);

  final String message;

  factory ProfileFailure.fromFirebase(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const ProfileFailure(
        'No tienes permiso para guardar este perfil.',
      ),
      'unavailable' => const ProfileFailure(
        'Firebase no esta disponible. Revisa tu conexion.',
      ),
      _ => const ProfileFailure(
        'No fue posible guardar el perfil. Intenta de nuevo.',
      ),
    };
  }

  @override
  String toString() => message;
}
