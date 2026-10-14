import 'package:cloud_firestore/cloud_firestore.dart';

class DiscoveryFailure implements Exception {
  const DiscoveryFailure(this.message);

  final String message;

  factory DiscoveryFailure.fromFirebase(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const DiscoveryFailure(
        'No fue posible registrar el interes. Verifica que ambas cuentas esten activas.',
      ),
      'unavailable' => const DiscoveryFailure(
        'Firebase no esta disponible. Revisa tu conexion.',
      ),
      _ => const DiscoveryFailure(
        'No fue posible completar esta accion. Intenta de nuevo.',
      ),
    };
  }

  @override
  String toString() => message;
}
