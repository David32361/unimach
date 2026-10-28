import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimatch_user/models/chat_message.dart';
import 'package:unimatch_user/presentation/features/safety/report_dialog.dart';
import 'package:unimatch_user/presentation/widgets/avatar_sprite.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/matches_providers.dart';
import 'package:unimatch_user/providers/messages_providers.dart';
import 'package:unimatch_user/providers/safety_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    required this.conversationId,
    required this.otherUserId,
    super.key,
  });

  final String conversationId;
  final String otherUserId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _markingRead = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;
    final sent = await ref
        .read(messagesControllerProvider.notifier)
        .send(
          conversationId: widget.conversationId,
          otherUserId: widget.otherUserId,
          text: text,
        );
    if (sent) {
      _messageController.clear();
    }
  }

  Future<void> _report() async {
    final draft = await showReportDialog(context);
    if (draft == null) return;
    final saved = await ref
        .read(safetyControllerProvider.notifier)
        .report(
          reportedUserId: widget.otherUserId,
          reason: draft.reason,
          description: draft.description,
        );
    if (saved && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reporte enviado.')));
    }
  }

  Future<void> _block(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquear usuario'),
        content: Text('¿Deseas bloquear a $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final blocked = await ref
        .read(safetyControllerProvider.notifier)
        .block(widget.otherUserId);
    if (blocked && mounted) context.pop();
  }

  void _markUnread(List<ChatMessage> messages, String uid) {
    if (_markingRead) return;
    final unread = messages
        .where((message) => message.senderId != uid && !message.read)
        .map((message) => message.id)
        .toList();
    if (unread.isEmpty) return;
    _markingRead = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref
            .read(messagesControllerProvider.notifier)
            .markAsRead(widget.conversationId, unread);
      } finally {
        _markingRead = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid ?? '';
    final messages = ref.watch(chatMessagesProvider(widget.conversationId));
    final person = ref.watch(matchedProfileProvider(widget.otherUserId)).value;
    final operation = ref.watch(messagesControllerProvider);
    final safetyOperation = ref.watch(safetyControllerProvider);

    ref.listen<AsyncValue<void>>(messagesControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('No se pudo enviar el mensaje.')),
          );
      }
    });

    final items = messages.value ?? const <ChatMessage>[];
    _markUnread(items, uid);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            if (person != null)
              AvatarSprite(avatarId: person.avatarId, size: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                person?.name ?? 'Conversacion',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Más opciones',
            enabled: !safetyOperation.isLoading,
            onSelected: (value) {
              if (value == 'report') _report();
              if (value == 'block') {
                _block(person?.name ?? 'este usuario');
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'report',
                child: ListTile(
                  leading: Icon(Icons.flag_outlined),
                  title: Text('Reportar'),
                ),
              ),
              PopupMenuItem(
                value: 'block',
                child: ListTile(
                  leading: Icon(Icons.block_rounded),
                  title: Text('Bloquear'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messages.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const Center(
                  child: Text('No se pudieron cargar los mensajes.'),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(child: Text('Inicia la conversacion.'));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final message = items[index];
                      final mine = message.senderId == uid;
                      return Align(
                        alignment: mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 300),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: mine
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(message.text),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 1000,
                      decoration: const InputDecoration(
                        hintText: 'Mensaje',
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Enviar',
                    onPressed: operation.isLoading ? null : _send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
