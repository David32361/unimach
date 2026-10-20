import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimatch_user/core/errors/profile_failure.dart';
import 'package:unimatch_user/models/user_profile.dart';
import 'package:unimatch_user/services/profile_service.dart';

class ProfileRepository {
  ProfileRepository(this._service);

  final ProfileService _service;

  Stream<UserProfile?> watchProfile(String uid) => _service.watchProfile(uid);

  Future<void> createProfile({
    required User user,
    required String name,
    required int age,
    required String gender,
    required String university,
    required String career,
    required String description,
    required int avatarId,
  }) async {
    try {
      await _service.createProfile(
        user: user,
        name: name,
        age: age,
        gender: gender,
        university: university,
        career: career,
        description: description,
        avatarId: avatarId,
      );
    } on FirebaseException catch (error) {
      throw ProfileFailure.fromFirebase(error);
    }
  }

  Future<void> updateInterests(
    String uid,
    List<String> interests,
    List<String> animeGenres,
  ) async {
    try {
      await _service.updateInterests(uid, interests, animeGenres);
    } on FirebaseException catch (error) {
      throw ProfileFailure.fromFirebase(error);
    }
  }

  Future<void> updateProfile({
    required String uid,
    required int avatarId,
    required String university,
    required String career,
    required String description,
    required List<String> interests,
    required List<String> animeGenres,
  }) async {
    try {
      await _service.updateProfile(
        uid: uid,
        avatarId: avatarId,
        university: university,
        career: career,
        description: description,
        interests: interests,
        animeGenres: animeGenres,
      );
    } on FirebaseException catch (error) {
      throw ProfileFailure.fromFirebase(error);
    }
  }
}
