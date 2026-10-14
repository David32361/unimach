import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimatch_user/presentation/widgets/avatar_sprite.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/matches_providers.dart';
import 'package:unimatch_user/providers/messages_providers.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid ?? '';

    return conversations.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const _MessagesEmpty(
        icon: Icons.cloud_off_rounded,
        title: 'No se pudieron cargar tus mensajes',
      ),
      data: (items) {
        if (items.isEmpty) {
          return const _MessagesEmpty(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'No hay conversaciones',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final conversation = items[index];
            final otherUid = conversation.otherUserId(uid);
            final profile = ref.watch(matchedProfileProvider(otherUid));
            final unread = ref.watch(unreadCountProvider(conversation.id));
            return profile.when(
              loading: () => const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Cargando...'),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (person) {
                if (person == null) return const SizedBox.shrink();
                final unreadCount = unread.value ?? 0;
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: AvatarSprite(avatarId: person.avatarId, size: 56),
                    title: Text(
                      person.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      conversation.lastMessage.isEmpty
                          ? 'Nuevo match'
                          : conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: unreadCount > 0
                        ? Badge(label: Text('$unreadCount'))
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: () =>
                        context.push('/chat/${conversation.id}/$otherUid'),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _MessagesEmpty extends StatelessWidget {
  const _MessagesEmpty({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
