import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.university,
    required this.career,
    required this.description,
    required this.avatarId,
    required this.interests,
    required this.accountStatus,
    required this.profileComplete,
    this.createdAt,
    this.lastActivity,
  });

  final String uid;
  final String name;
  final String email;
  final int age;
  final String gender;
  final String university;
  final String career;
  final String description;
  final int avatarId;
  final List<String> interests;
  final String accountStatus;
  final bool profileComplete;
  final DateTime? createdAt;
  final DateTime? lastActivity;

  factory UserProfile.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return UserProfile(
      uid: data['uid'] as String? ?? snapshot.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      age: data['age'] as int? ?? 0,
      gender: data['gender'] as String? ?? '',
      university: data['university'] as String? ?? '',
      career: data['career'] as String? ?? '',
      description: data['description'] as String? ?? '',
      avatarId: data['avatarId'] as int? ?? 0,
      interests: List<String>.from(data['interests'] as List? ?? const []),
      accountStatus: data['accountStatus'] as String? ?? 'active',
      profileComplete: data['profileComplete'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastActivity: (data['lastActivity'] as Timestamp?)?.toDate(),
    );
  }
}
