import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.read,
    this.timestamp,
  });

  final String id;
  final String senderId;
  final String text;
  final bool read;
  final DateTime? timestamp;

  factory ChatMessage.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return ChatMessage(
      id: snapshot.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      read: data['read'] as bool? ?? false,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
