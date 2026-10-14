import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/profile_providers.dart';
import 'package:unimatch_user/services/safety_service.dart';

final safetyServiceProvider = Provider<SafetyService>((ref) {
  return SafetyService(ref.watch(firebaseFirestoreProvider));
});

final blockedUserIdsProvider = StreamProvider<Set<String>>((ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return Stream.value(<String>{});
  return ref.watch(safetyServiceProvider).watchBlockedUserIds(uid);
});

final safetyControllerProvider = AsyncNotifierProvider<SafetyController, void>(
  SafetyController.new,
);

class SafetyController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> block(String blockedUserId) async {
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (uid == null) return false;
    return _run(
      () => ref
          .read(safetyServiceProvider)
          .block(uid: uid, blockedUserId: blockedUserId),
    );
  }

  Future<bool> report({
    required String reportedUserId,
    required String reason,
    required String description,
  }) async {
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (uid == null) return false;
    return _run(
      () => ref
          .read(safetyServiceProvider)
          .report(
            reporterId: uid,
            reportedUserId: reportedUserId,
            reason: reason,
            description: description,
          ),
    );
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
