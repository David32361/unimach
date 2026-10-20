import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimatch_user/models/user_profile.dart';

class ProfileService {
  ProfileService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<UserProfile?> watchProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserProfile.fromSnapshot(snapshot);
    });
  }

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
    final privateData = {
      'uid': user.uid,
      'name': name.trim(),
      'email': user.email,
      'age': age,
      'gender': gender,
      'university': university.trim(),
      'career': career.trim(),
      'description': description.trim(),
      'avatarId': avatarId,
      'interests': <String>[],
      'animeGenres': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'lastActivity': FieldValue.serverTimestamp(),
      'accountStatus': 'active',
      'profileComplete': true,
    };
    final publicData = {
      'uid': user.uid,
      'name': name.trim(),
      'age': age,
      'gender': gender,
      'university': university.trim(),
      'career': career.trim(),
      'description': description.trim(),
      'avatarId': avatarId,
      'interests': <String>[],
      'animeGenres': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'accountStatus': 'active',
    };
    final batch = _firestore.batch();
    batch.set(_firestore.collection('users').doc(user.uid), privateData);
    batch.set(
      _firestore.collection('publicProfiles').doc(user.uid),
      publicData,
    );
    await batch.commit();
    await user.updateDisplayName(name.trim());
  }

  Future<void> updateInterests(
    String uid,
    List<String> interests,
    List<String> animeGenres,
  ) async {
    final batch = _firestore.batch();
    batch.update(_firestore.collection('users').doc(uid), {
      'interests': interests,
      'animeGenres': animeGenres,
      'lastActivity': FieldValue.serverTimestamp(),
    });
    batch.update(_firestore.collection('publicProfiles').doc(uid), {
      'interests': interests,
      'animeGenres': animeGenres,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
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
    final privateChanges = {
      'avatarId': avatarId,
      'university': university.trim(),
      'career': career.trim(),
      'description': description.trim(),
      'interests': interests,
      'animeGenres': animeGenres,
      'lastActivity': FieldValue.serverTimestamp(),
    };
    final publicChanges = {
      'avatarId': avatarId,
      'university': university.trim(),
      'career': career.trim(),
      'description': description.trim(),
      'interests': interests,
      'animeGenres': animeGenres,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final batch = _firestore.batch();
    batch.update(_firestore.collection('users').doc(uid), privateChanges);
    batch.update(
      _firestore.collection('publicProfiles').doc(uid),
      publicChanges,
    );
    await batch.commit();
  }
}
