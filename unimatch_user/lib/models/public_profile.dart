import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimatch_user/models/academic_catalog.dart';

class PublicProfile {
  const PublicProfile({
    required this.uid,
    required this.name,
    required this.age,
    required this.gender,
    required this.university,
    required this.career,
    required this.description,
    required this.avatarId,
    required this.interests,
    required this.animeGenres,
  });

  final String uid;
  final String name;
  final int age;
  final String gender;
  final String university;
  final String career;
  final String description;
  final int avatarId;
  final List<String> interests;
  final List<String> animeGenres;

  factory PublicProfile.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return PublicProfile(
      uid: data['uid'] as String? ?? snapshot.id,
      name: data['name'] as String? ?? '',
      age: data['age'] as int? ?? 0,
      gender: data['gender'] as String? ?? '',
      university: canonicalUniversityName(data['university'] as String? ?? ''),
      career: data['career'] as String? ?? '',
      description: data['description'] as String? ?? '',
      avatarId: data['avatarId'] as int? ?? 0,
      interests: List<String>.from(data['interests'] as List? ?? const []),
      animeGenres: List<String>.from(data['animeGenres'] as List? ?? const []),
    );
  }
}
