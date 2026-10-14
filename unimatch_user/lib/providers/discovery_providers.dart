import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_user/models/public_profile.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/profile_providers.dart';
import 'package:unimatch_user/repositories/discovery_repository.dart';
import 'package:unimatch_user/services/discovery_service.dart';

final discoveryServiceProvider = Provider<DiscoveryService>((ref) {
  return DiscoveryService(ref.watch(firebaseFirestoreProvider));
});

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepository(ref.watch(discoveryServiceProvider));
});

final publicProfilesProvider = StreamProvider<List<PublicProfile>>((ref) {
  return ref.watch(discoveryRepositoryProvider).watchPublicProfiles();
});

final outgoingLikesProvider = StreamProvider<Set<String>>((ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return Stream.value(<String>{});
  return ref.watch(discoveryRepositoryProvider).watchOutgoingLikes(uid);
});

final passesProvider = StreamProvider<Set<String>>((ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return Stream.value(<String>{});
  return ref.watch(discoveryRepositoryProvider).watchPasses(uid);
});

final discoveryControllerProvider =
    AsyncNotifierProvider<DiscoveryController, void>(DiscoveryController.new);

class DiscoveryController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> pass(String targetUid) async {
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (uid == null) return false;
    state = const AsyncLoading();
    try {
      await ref
          .read(discoveryRepositoryProvider)
          .pass(uid: uid, targetUid: targetUid);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool?> like(String targetUid) async {
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (uid == null) return null;
    state = const AsyncLoading();
    try {
      final matched = await ref
          .read(discoveryRepositoryProvider)
          .like(uid: uid, targetUid: targetUid);
      state = const AsyncData(null);
      return matched;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }
}
