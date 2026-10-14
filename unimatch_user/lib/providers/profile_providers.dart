import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_user/models/user_profile.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/repositories/profile_repository.dart';
import 'package:unimatch_user/services/profile_service.dart';

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref.watch(firebaseFirestoreProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(profileServiceProvider));
});

final currentProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final user = authState.value;
  if (user == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watchProfile(user.uid);
});

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(ProfileController.new);

class ProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> createProfile({
    required String name,
    required int age,
    required String gender,
    required String university,
    required String career,
    required String description,
    required int avatarId,
  }) async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return false;

    state = const AsyncLoading();
    try {
      await ref
          .read(profileRepositoryProvider)
          .createProfile(
            user: user,
            name: name,
            age: age,
            gender: gender,
            university: university,
            career: career,
            description: description,
            avatarId: avatarId,
          );
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> updateInterests(List<String> interests) async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return false;

    state = const AsyncLoading();
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateInterests(user.uid, interests);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> updateProfile({
    required int avatarId,
    required String university,
    required String career,
    required String description,
    required List<String> interests,
  }) async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return false;
    state = const AsyncLoading();
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            uid: user.uid,
            avatarId: avatarId,
            university: university,
            career: career,
            description: description,
            interests: interests,
          );
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
