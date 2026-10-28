import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_user/presentation/widgets/avatar_sprite.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/discovery_providers.dart';
import 'package:unimatch_user/providers/matches_providers.dart';
import 'package:unimatch_user/providers/safety_providers.dart';

class SentInterestsTab extends ConsumerWidget {
  const SentInterestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likes = ref.watch(outgoingLikesProvider);
    final matches = ref.watch(matchesProvider);
    final blocked = ref.watch(blockedUserIdsProvider);
    if (likes.isLoading || matches.isLoading || blocked.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (likes.hasError || matches.hasError || blocked.hasError) {
      return Center(
        child: TextButton.icon(
          onPressed: () {
            ref.invalidate(outgoingLikesProvider);
            ref.invalidate(matchesProvider);
            ref.invalidate(blockedUserIdsProvider);
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar cargar intereses'),
        ),
      );
    }
    final uid = ref.watch(authStateChangesProvider).value?.uid ?? '';
    final matched = matches.value!
        .map((match) => match.otherUserId(uid))
        .toSet();
    final pending =
        likes.value!.difference(matched).difference(blocked.value!).toList()
          ..sort();
    if (pending.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No tienes intereses pendientes. Los intereses mutuos aparecen en Matches.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Tu interés quedó guardado. Habrá un match si la otra persona también muestra interés.',
            ),
          );
        }
        final otherUid = pending[index - 1];
        final person = ref.watch(matchedProfileProvider(otherUid));
        return person.when(
          loading: () => const ListTile(title: Text('Cargando perfil…')),
          error: (_, _) => ListTile(
            title: const Text('No se pudo cargar este perfil'),
            trailing: IconButton(
              tooltip: 'Reintentar',
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(matchedProfileProvider(otherUid)),
            ),
          ),
          data: (profile) => profile == null
              ? const SizedBox.shrink()
              : Card(
                  child: ListTile(
                    leading: AvatarSprite(avatarId: profile.avatarId, size: 48),
                    title: Text(profile.name),
                    subtitle: const Text(
                      'Interés enviado · Esperando interés mutuo',
                    ),
                    trailing: const Icon(
                      Icons.favorite,
                      color: Color(0xFFB83A55),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
