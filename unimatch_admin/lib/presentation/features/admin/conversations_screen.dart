import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_admin/models/admin_user.dart';
import 'package:unimatch_admin/presentation/widgets/admin_page.dart';
import 'package:unimatch_admin/providers/admin_providers.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(recentMessagesProvider);
    final users = {
      for (final user in ref.watch(adminUsersProvider).value ?? <AdminUser>[])
        user.uid: user.name,
    };
    final participants =
        ref.watch(conversationParticipantsProvider).value ??
        const <String, List<String>>{};
    return AdminPage(
      title: 'Conversaciones',
      subtitle:
          'Consulta de moderacion limitada a mensajes de los ultimos 3 dias.',
      child: messagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text('No fue posible cargar los mensajes: $error'),
        data: (messages) {
          if (messages.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Text('No hay mensajes recientes.'),
            );
          }
          return Column(
            children: messages.map((message) {
              final sender = users[message.senderId] ?? message.senderId;
              final conversationUsers =
                  participants[message.conversationId]
                      ?.map((uid) => users[uid] ?? uid)
                      .join(' y ') ??
                  message.conversationId;
              final date = message.timestamp;
              final dateText = date == null
                  ? 'Fecha no disponible'
                  : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: const CircleAvatar(
                  child: Icon(Icons.chat_bubble_outline),
                ),
                title: Text(conversationUsers),
                subtitle: Text('$sender: ${message.text}'),
                trailing: SizedBox(
                  width: 150,
                  child: Text(dateText, textAlign: TextAlign.end),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
