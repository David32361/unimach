import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimatch_user/models/interest_catalog.dart';
import 'package:unimatch_user/presentation/features/discovery/discovery_screen.dart';
import 'package:unimatch_user/presentation/features/matches/matches_screen.dart';
import 'package:unimatch_user/presentation/features/messages/messages_screen.dart';
import 'package:unimatch_user/presentation/widgets/avatar_sprite.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/profile_providers.dart';

class AuthenticatedHomeScreen extends ConsumerStatefulWidget {
  const AuthenticatedHomeScreen({super.key});

  @override
  ConsumerState<AuthenticatedHomeScreen> createState() =>
      _AuthenticatedHomeScreenState();
}

class _AuthenticatedHomeScreenState
    extends ConsumerState<AuthenticatedHomeScreen> {
  int _selectedIndex = 0;

  static const _titles = ['Descubrir', 'Matches', 'Mensajes', 'Perfil'];

  @override
  Widget build(BuildContext context) {
    final operation = ref.watch(authControllerProvider);
    final views = [
      const DiscoveryScreen(),
      const MatchesScreen(),
      const MessagesScreen(),
      const _ProfileOverview(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: _selectedIndex == 3
            ? [
                IconButton(
                  tooltip: 'Editar perfil',
                  onPressed: () => context.push('/profile/edit'),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Cerrar sesion',
                  onPressed: operation.isLoading
                      ? null
                      : ref.read(authControllerProvider.notifier).signOut,
                  icon: const Icon(Icons.logout_rounded),
                ),
              ]
            : null,
      ),
      body: IndexedStack(index: _selectedIndex, children: views),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Descubrir',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Matches',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Mensajes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _ProfileOverview extends ConsumerWidget {
  const _ProfileOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(child: AvatarSprite(avatarId: profile.avatarId, size: 120)),
        const SizedBox(height: 18),
        Text(
          profile.name,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(user?.email ?? '', textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(
          '${profile.age} anos | ${profile.gender}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(profile.university, textAlign: TextAlign.center),
        Text(profile.career, textAlign: TextAlign.center),
        const SizedBox(height: 18),
        Text(profile.description, textAlign: TextAlign.center),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final interest in profile.interests)
              Chip(label: Text(interestLabels[interest] ?? interest)),
          ],
        ),
      ],
    );
  }
}
