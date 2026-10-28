import 'package:cloud_firestore/cloud_firestore.dart';

class DiscoveryFailure implements Exception {
  const DiscoveryFailure(this.message);

  final String message;

  factory DiscoveryFailure.fromFirebase(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const DiscoveryFailure(
        'No fue posible registrar el interés. Verifica que ambas cuentas estén activas.',
      ),
      'unavailable' => const DiscoveryFailure(
        'Firebase no está disponible. Revisa tu conexión.',
      ),
      _ => const DiscoveryFailure(
        'No fue posible completar esta acción. Intenta de nuevo.',
      ),
    };
  }

  @override
  String toString() => message;
}
