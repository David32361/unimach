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

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  final _scrollController = ScrollController();
  final _dismissed = <String>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadWhenNearEnd);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadWhenNearEnd() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > 600) {
      return;
    }
    final feed = ref.read(discoveryFeedProvider).value;
    if (feed != null &&
        feed.hasMore &&
        !feed.isLoadingMore &&
        feed.loadError == null) {
      ref.read(discoveryFeedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(discoveryFeedProvider);
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
      return _DiscoveryEmpty(
        icon: Icons.cloud_off_rounded,
        title: 'No se pudieron cargar los perfiles',
        onRefresh: () {
          ref.invalidate(discoveryFeedProvider);
          ref.invalidate(outgoingLikesProvider);
          ref.invalidate(passesProvider);
          ref.invalidate(blockedUserIdsProvider);
        },
      );
    }

    final feed = profiles.value!;
    final hidden = {
      ...?likes.value,
      ...?passes.value,
      ...?blocked.value,
      ..._dismissed,
    };
    final candidates = feed.profiles
        .where(
          (profile) => profile.uid != ownUid && !hidden.contains(profile.uid),
        )
        .toList(growable: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadWhenNearEnd();
    });
    if (candidates.isEmpty && !feed.hasMore && feed.loadError == null) {
      return _DiscoveryEmpty(
        icon: Icons.explore_outlined,
        title: 'No hay perfiles nuevos por ahora',
        onRefresh: () {
          _dismissed.clear();
          ref.invalidate(discoveryFeedProvider);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _dismissed.clear();
        ref.invalidate(discoveryFeedProvider);
        await ref.read(discoveryFeedProvider.future);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        itemCount: candidates.length + 1,
        itemBuilder: (context, index) {
          if (index == candidates.length) {
            if (feed.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (feed.loadError != null) {
              return Center(
                child: TextButton.icon(
                  onPressed: () =>
                      ref.read(discoveryFeedProvider.notifier).loadMore(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar carga de perfiles'),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                feed.hasMore ? '' : 'Ya viste todos los perfiles.',
                textAlign: TextAlign.center,
              ),
            );
          }
          final profile = candidates[index];
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: _ProfileCandidate(
                key: ValueKey(profile.uid),
                profile: profile,
                ownInterests: ownInterests,
                ownAnimeGenres: ownAnimeGenres,
                onDismissed: () => setState(() => _dismissed.add(profile.uid)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileCandidate extends ConsumerWidget {
  const _ProfileCandidate({
    super.key,
    required this.profile,
    required this.ownInterests,
    required this.ownAnimeGenres,
    required this.onDismissed,
  });

  final PublicProfile profile;
  final Set<String> ownInterests;
  final Set<String> ownAnimeGenres;
  final VoidCallback onDismissed;

  Future<void> _like(BuildContext context, WidgetRef ref) async {
    final matched = await ref
        .read(discoveryControllerProvider.notifier)
        .like(profile.uid);
    if (matched != null && context.mounted) onDismissed();
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

  Future<void> _pass(BuildContext context, WidgetRef ref) async {
    final saved = await ref
        .read(discoveryControllerProvider.notifier)
        .pass(profile.uid);
    if (saved && context.mounted) onDismissed();
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
      final blocked = await ref
          .read(safetyControllerProvider.notifier)
          .block(profile.uid);
      if (blocked && context.mounted) onDismissed();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operation = ref.watch(discoveryControllerProvider);
    final safetyOperation = ref.watch(safetyControllerProvider);
    return Card(
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
            Center(child: AvatarSprite(avatarId: profile.avatarId, size: 180)),
            const SizedBox(height: 20),
            Text(
              '${profile.name}, ${profile.age}',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
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
                    label: Text('Anime: ${animeGenreLabels[genre] ?? genre}'),
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
                      : () => _pass(context, ref),
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
    );
  }
}

class _DiscoveryEmpty extends StatelessWidget {
  const _DiscoveryEmpty({
    required this.icon,
    required this.title,
    required this.onRefresh,
  });

  final IconData icon;
  final String title;
  final VoidCallback onRefresh;

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
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
