import 'package:cloud_firestore/cloud_firestore.dart';

class RecentMessage {
  const RecentMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime? timestamp;

  factory RecentMessage.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return RecentMessage(
      id: doc.id,
      conversationId: doc.reference.parent.parent?.id ?? '',
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
