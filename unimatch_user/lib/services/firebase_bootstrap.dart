import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase_options.dart';

final firebaseStartupStateProvider = Provider<FirebaseStartupState>(
  (ref) => const FirebaseStartupState.notInitialized(),
);

class FirebaseStartupState {
  const FirebaseStartupState({required this.initialized, this.errorMessage});

  const FirebaseStartupState.notInitialized()
    : initialized = false,
      errorMessage = null;

  final bool initialized;
  final String? errorMessage;
}

class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static Future<FirebaseStartupState> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return const FirebaseStartupState(initialized: true);
    } on Object catch (error) {
      return FirebaseStartupState(
        initialized: false,
        errorMessage: error.toString(),
      );
    }
  }
}
