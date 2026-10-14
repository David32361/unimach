import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUser {
  const AdminUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.university,
    required this.career,
    required this.avatarId,
    required this.accountStatus,
    required this.createdAt,
    required this.lastActivity,
  });

  final String uid;
  final String name;
  final String email;
  final int age;
  final String gender;
  final String university;
  final String career;
  final int avatarId;
  final String accountStatus;
  final DateTime? createdAt;
  final DateTime? lastActivity;

  factory AdminUser.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return AdminUser(
      uid: doc.id,
      name: data['name'] as String? ?? 'Sin nombre',
      email: data['email'] as String? ?? '',
      age: data['age'] as int? ?? 0,
      gender: data['gender'] as String? ?? '',
      university: data['university'] as String? ?? '',
      career: data['career'] as String? ?? '',
      avatarId: data['avatarId'] as int? ?? 0,
      accountStatus: data['accountStatus'] as String? ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastActivity: (data['lastActivity'] as Timestamp?)?.toDate(),
    );
  }
}
