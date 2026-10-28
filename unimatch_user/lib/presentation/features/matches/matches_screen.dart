import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimatch_user/presentation/widgets/avatar_sprite.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/matches_providers.dart';
import 'package:unimatch_user/presentation/features/matches/sent_interests_tab.dart';

class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Matches'),
              Tab(text: 'Intereses enviados'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [_buildMatches(context, ref), const SentInterestsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatches(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchesProvider);
    final currentUid = ref.watch(firebaseAuthProvider).currentUser?.uid ?? '';

    return matches.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const _MatchesEmpty(
        icon: Icons.cloud_off_rounded,
        title: 'No se pudieron cargar tus matches',
      ),
      data: (items) {
        if (items.isEmpty) {
          return const _MatchesEmpty(
            icon: Icons.favorite_border_rounded,
            title: 'Aún no tienes matches',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final match = items[index];
            final otherUid = match.otherUserId(currentUid);
            final profile = ref.watch(matchedProfileProvider(otherUid));
            return profile.when(
              loading: () => const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Cargando...'),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (person) {
                if (person == null) return const SizedBox.shrink();
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: AvatarSprite(avatarId: person.avatarId, size: 58),
                    title: Text(
                      person.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Interés mutuo · ${person.university}\n${person.career}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chat_bubble_outline_rounded),
                    onTap: () => context.push('/chat/${match.id}/$otherUid'),
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

class _MatchesEmpty extends StatelessWidget {
  const _MatchesEmpty({required this.icon, required this.title});

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
