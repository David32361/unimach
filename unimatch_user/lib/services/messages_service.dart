import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimatch_user/models/chat_message.dart';
import 'package:unimatch_user/models/conversation.dart';

class MessagesService {
  MessagesService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<Conversation>> watchConversations(String uid) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
          final conversations = snapshot.docs
              .map(Conversation.fromSnapshot)
              .toList();
          conversations.sort(
            (a, b) => (b.lastMessageAt ?? DateTime(1970)).compareTo(
              a.lastMessageAt ?? DateTime(1970),
            ),
          );
          return conversations;
        });
  }

  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp')
        .limit(200)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ChatMessage.fromSnapshot)
              .toList(growable: false),
        );
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String otherUserId,
    required String text,
  }) async {
    final conversation = _firestore
        .collection('conversations')
        .doc(conversationId);
    final message = conversation.collection('messages').doc();
    final participants = [senderId, otherUserId]..sort();

    await _firestore.runTransaction((transaction) async {
      final conversationSnapshot = await transaction.get(conversation);
      final conversationData = <String, dynamic>{
        'conversationId': conversationId,
        'matchId': conversationId,
        'participants': participants,
        'lastMessage': text.trim(),
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': senderId,
      };
      if (!conversationSnapshot.exists) {
        conversationData['createdAt'] = FieldValue.serverTimestamp();
      }
      transaction.set(
        conversation,
        conversationData,
        SetOptions(merge: conversationSnapshot.exists),
      );
      transaction.set(message, {
        'senderId': senderId,
        'text': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    });
  }

  Future<void> markAsRead(
    String conversationId,
    Iterable<String> messageIds,
  ) async {
    final ids = messageIds.toList(growable: false);
    if (ids.isEmpty) return;
    final batch = _firestore.batch();
    for (final messageId in ids) {
      batch.update(
        _firestore
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .doc(messageId),
        {'read': true},
      );
    }
    await batch.commit();
  }
}
