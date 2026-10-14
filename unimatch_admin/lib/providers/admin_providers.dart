import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_admin/models/admin_report.dart';
import 'package:unimatch_admin/models/admin_user.dart';
import 'package:unimatch_admin/models/recent_message.dart';
import 'package:unimatch_admin/repositories/admin_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(firestoreProvider)),
);
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);
final adminAccessProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return false;
  final token = await user.getIdTokenResult(true);
  return token.claims?['admin'] == true;
});

final adminUsersProvider = StreamProvider<List<AdminUser>>(
  (ref) => ref.watch(adminRepositoryProvider).watchUsers(),
);
final adminReportsProvider = StreamProvider<List<AdminReport>>(
  (ref) => ref.watch(adminRepositoryProvider).watchReports(),
);
final recentMessagesProvider = StreamProvider<List<RecentMessage>>(
  (ref) => ref.watch(adminRepositoryProvider).watchRecentMessages(),
);
final matchCountProvider = StreamProvider<int>(
  (ref) => ref.watch(adminRepositoryProvider).watchCollectionCount('matches'),
);
final conversationCountProvider = StreamProvider<int>(
  (ref) =>
      ref.watch(adminRepositoryProvider).watchCollectionCount('conversations'),
);
final usageSecondsProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(adminRepositoryProvider).watchUsageSeconds(),
);
final conversationParticipantsProvider =
    StreamProvider<Map<String, List<String>>>(
      (ref) =>
          ref.watch(adminRepositoryProvider).watchConversationParticipants(),
    );

final adminAuthControllerProvider =
    AsyncNotifierProvider<AdminAuthController, void>(AdminAuthController.new);

class AdminAuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      final credential = await ref
          .read(firebaseAuthProvider)
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      final token = await credential.user?.getIdTokenResult(true);
      if (token?.claims?['admin'] != true) {
        await ref.read(firebaseAuthProvider).signOut();
        throw FirebaseAuthException(
          code: 'admin-required',
          message: 'Esta cuenta no tiene permisos de administrador.',
        );
      }
      ref.invalidate(adminAccessProvider);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<void> signOut() => ref.read(firebaseAuthProvider).signOut();
}
