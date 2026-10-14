import 'package:cloud_firestore/cloud_firestore.dart';

class UserMatch {
  const UserMatch({
    required this.id,
    required this.userIds,
    required this.status,
    this.createdAt,
  });

  final String id;
  final List<String> userIds;
  final String status;
  final DateTime? createdAt;

  factory UserMatch.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return UserMatch(
      id: snapshot.id,
      userIds: List<String>.from(data['userIds'] as List? ?? const []),
      status: data['status'] as String? ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  String otherUserId(String currentUid) {
    return userIds.firstWhere((uid) => uid != currentUid, orElse: () => '');
  }
}
