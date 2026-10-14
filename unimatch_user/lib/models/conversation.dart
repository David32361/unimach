import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastSenderId,
    this.lastMessageAt,
  });

  final String id;
  final List<String> participants;
  final String lastMessage;
  final String lastSenderId;
  final DateTime? lastMessageAt;

  factory Conversation.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return Conversation(
      id: snapshot.id,
      participants: List<String>.from(
        data['participants'] as List? ?? const [],
      ),
      lastMessage: data['lastMessage'] as String? ?? '',
      lastSenderId: data['lastSenderId'] as String? ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }

  String otherUserId(String currentUid) {
    return participants.firstWhere(
      (uid) => uid != currentUid,
      orElse: () => '',
    );
  }
}
