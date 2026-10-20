import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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

class DiscoveryFeedState {
  const DiscoveryFeedState({
    required this.profiles,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadError,
  });

  final List<PublicProfile> profiles;
  final bool hasMore;
  final bool isLoadingMore;
  final String? loadError;

  DiscoveryFeedState copyWith({
    List<PublicProfile>? profiles,
    bool? hasMore,
    bool? isLoadingMore,
    String? loadError,
  }) => DiscoveryFeedState(
    profiles: profiles ?? this.profiles,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadError: loadError,
  );
}

final discoveryFeedProvider =
    AsyncNotifierProvider<DiscoveryFeedController, DiscoveryFeedState>(
      DiscoveryFeedController.new,
    );

class DiscoveryFeedController extends AsyncNotifier<DiscoveryFeedState> {
  QueryDocumentSnapshot<Map<String, dynamic>>? _lastDocument;

  @override
  Future<DiscoveryFeedState> build() async {
    final page = await ref
        .watch(discoveryRepositoryProvider)
        .loadProfilesPage();
    _lastDocument = page.lastDocument;
    return DiscoveryFeedState(profiles: page.profiles, hasMore: page.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await ref
          .read(discoveryRepositoryProvider)
          .loadProfilesPage(after: _lastDocument);
      if (!ref.mounted) return;
      _lastDocument = page.lastDocument;
      final seen = current.profiles.map((profile) => profile.uid).toSet();
      final profiles = [
        ...current.profiles,
        for (final profile in page.profiles)
          if (seen.add(profile.uid)) profile,
      ];
      state = AsyncData(
        DiscoveryFeedState(profiles: profiles, hasMore: page.hasMore),
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadError: error.toString()),
      );
    }
  }
}

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
