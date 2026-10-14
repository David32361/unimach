import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_user/models/chat_message.dart';
import 'package:unimatch_user/models/conversation.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/profile_providers.dart';
import 'package:unimatch_user/services/messages_service.dart';

final messagesServiceProvider = Provider<MessagesService>((ref) {
  return MessagesService(ref.watch(firebaseFirestoreProvider));
});

final conversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return Stream.value(const <Conversation>[]);
  return ref.watch(messagesServiceProvider).watchConversations(uid);
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((
  ref,
  conversationId,
) {
  return ref.watch(messagesServiceProvider).watchMessages(conversationId);
});

final unreadCountProvider = StreamProvider.family<int, String>((
  ref,
  conversationId,
) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return Stream.value(0);
  return ref
      .watch(messagesServiceProvider)
      .watchMessages(conversationId)
      .map(
        (messages) => messages
            .where((message) => message.senderId != uid && !message.read)
            .length,
      );
});

final messagesControllerProvider =
    AsyncNotifierProvider<MessagesController, void>(MessagesController.new);

class MessagesController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> send({
    required String conversationId,
    required String otherUserId,
    required String text,
  }) async {
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (uid == null || text.trim().isEmpty) return false;
    state = const AsyncLoading();
    try {
      await ref
          .read(messagesServiceProvider)
          .sendMessage(
            conversationId: conversationId,
            senderId: uid,
            otherUserId: otherUserId,
            text: text,
          );
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<void> markAsRead(String conversationId, Iterable<String> messageIds) {
    return ref
        .read(messagesServiceProvider)
        .markAsRead(conversationId, messageIds);
  }
}
