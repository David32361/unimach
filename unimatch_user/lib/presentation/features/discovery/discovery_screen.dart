import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_user/models/interest_catalog.dart';
import 'package:unimatch_user/models/public_profile.dart';
import 'package:unimatch_user/presentation/features/safety/report_dialog.dart';
import 'package:unimatch_user/presentation/widgets/avatar_sprite.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/discovery_providers.dart';
import 'package:unimatch_user/providers/profile_providers.dart';
import 'package:unimatch_user/providers/safety_providers.dart';

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(publicProfilesProvider);
    final likes = ref.watch(outgoingLikesProvider);
    final passes = ref.watch(passesProvider);
    final blocked = ref.watch(blockedUserIdsProvider);
    final ownUid = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final ownInterests =
        ref.watch(currentProfileProvider).value?.interests.toSet() ?? {};
    final ownAnimeGenres =
        ref.watch(currentProfileProvider).value?.animeGenres.toSet() ?? {};

    ref.listen<AsyncValue<void>>(discoveryControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    if (profiles.isLoading ||
        likes.isLoading ||
        passes.isLoading ||
        blocked.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (profiles.hasError ||
        likes.hasError ||
        passes.hasError ||
        blocked.hasError) {
      return const _DiscoveryEmpty(
        icon: Icons.cloud_off_rounded,
        title: 'No se pudieron cargar los perfiles',
      );
    }

    final hidden = {...?likes.value, ...?passes.value, ...?blocked.value};
    final candidates = (profiles.value ?? const <PublicProfile>[])
        .where(
          (profile) => profile.uid != ownUid && !hidden.contains(profile.uid),
        )
        .toList(growable: false);
    if (candidates.isEmpty) {
      return const _DiscoveryEmpty(
        icon: Icons.explore_outlined,
        title: 'No hay perfiles nuevos por ahora',
      );
    }

    return _ProfileCandidate(
      profile: candidates.first,
      ownInterests: ownInterests,
      ownAnimeGenres: ownAnimeGenres,
    );
  }
}

class _ProfileCandidate extends ConsumerWidget {
  const _ProfileCandidate({
    required this.profile,
    required this.ownInterests,
    required this.ownAnimeGenres,
  });

  final PublicProfile profile;
  final Set<String> ownInterests;
  final Set<String> ownAnimeGenres;

  Future<void> _like(BuildContext context, WidgetRef ref) async {
    final matched = await ref
        .read(discoveryControllerProvider.notifier)
        .like(profile.uid);
    if (matched == true && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Nuevo match con ${profile.name}.')),
        );
    } else if (matched == false && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Interes guardado.')));
    }
  }

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    final draft = await showReportDialog(context);
    if (draft == null) return;
    final saved = await ref
        .read(safetyControllerProvider.notifier)
        .report(
          reportedUserId: profile.uid,
          reason: draft.reason,
          description: draft.description,
        );
    if (saved && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reporte enviado.')));
    }
  }

  Future<void> _block(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquear usuario'),
        content: Text('¿Deseas bloquear a ${profile.name}?'),
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
    if (confirmed == true) {
      await ref.read(safetyControllerProvider.notifier).block(profile.uid);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operation = ref.watch(discoveryControllerProvider);
    final safetyOperation = ref.watch(safetyControllerProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: PopupMenuButton<String>(
                        tooltip: 'Mas opciones',
                        enabled: !safetyOperation.isLoading,
                        onSelected: (value) {
                          if (value == 'report') _report(context, ref);
                          if (value == 'block') _block(context, ref);
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
                    ),
                    Center(
                      child: AvatarSprite(
                        avatarId: profile.avatarId,
                        size: 180,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${profile.name}, ${profile.age}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${profile.university}\n${profile.career}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(profile.description, textAlign: TextAlign.center),
                    const SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final interest in profile.interests)
                          Chip(
                            avatar: ownInterests.contains(interest)
                                ? const Icon(Icons.check_rounded, size: 16)
                                : null,
                            label: Text(interestLabels[interest] ?? interest),
                          ),
                        for (final genre in profile.animeGenres)
                          Chip(
                            avatar: ownAnimeGenres.contains(genre)
                                ? const Icon(Icons.check_rounded, size: 16)
                                : null,
                            label: Text(
                              'Anime: ${animeGenreLabels[genre] ?? genre}',
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'No me interesa',
                          onPressed: operation.isLoading
                              ? null
                              : () => ref
                                    .read(discoveryControllerProvider.notifier)
                                    .pass(profile.uid),
                          icon: const Icon(Icons.close_rounded),
                          iconSize: 30,
                        ),
                        const SizedBox(width: 24),
                        IconButton.filled(
                          tooltip: 'Me interesa',
                          onPressed: operation.isLoading
                              ? null
                              : () => _like(context, ref),
                          icon: const Icon(Icons.favorite_rounded),
                          iconSize: 30,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DiscoveryEmpty extends StatelessWidget {
  const _DiscoveryEmpty({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
