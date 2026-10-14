import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_user/repositories/auth_repository.dart';
import 'package:unimatch_user/services/auth_service.dart';
import 'package:unimatch_user/services/notification_service.dart';
import 'package:unimatch_user/services/usage_session_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(authServiceProvider));
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final adminAccessProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return false;
  final token = await user.getIdTokenResult(true);
  return token.claims?['admin'] == true;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    FirebaseMessaging.instance,
    FirebaseFirestore.instance,
  );
});

final usageSessionServiceProvider = Provider<UsageSessionService>((ref) {
  return UsageSessionService(FirebaseFirestore.instance);
});

final notificationRegistrationProvider = Provider<void>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    return;
  }

  final service = ref.watch(notificationServiceProvider);
  unawaited(service.registerDevice(user.uid).catchError((_) {}));
  final subscription = FirebaseMessaging.instance.onTokenRefresh.listen(
    (token) => service.saveToken(user.uid, token).catchError((_) {}),
  );
  ref.onDispose(subscription.cancel);
});

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> register(String email, String password) {
    return _run(
      () => ref.read(authRepositoryProvider).register(email, password),
    );
  }

  Future<bool> signIn(String email, String password) {
    return _run(() => ref.read(authRepositoryProvider).signIn(email, password));
  }

  Future<bool> signInWithGoogle() {
    return _run(ref.read(authRepositoryProvider).signInWithGoogle);
  }

  Future<bool> sendPasswordReset(String email) {
    return _run(
      () => ref.read(authRepositoryProvider).sendPasswordReset(email),
    );
  }

  Future<bool> signOut() {
    return _run(() async {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user != null) {
        try {
          await ref.read(usageSessionServiceProvider).endSession();
        } catch (_) {
          // Session metrics must not prevent sign out.
        }
        try {
          await ref
              .read(notificationServiceProvider)
              .unregisterDevice(user.uid);
        } catch (_) {
          // A notification cleanup failure must not prevent sign out.
        }
      }
      await ref.read(authRepositoryProvider).signOut();
    });
  }

  Future<bool> _run(Future<void> Function() operation) async {
    state = const AsyncLoading();
    try {
      await operation();
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
