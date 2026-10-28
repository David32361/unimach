import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimatch_user/models/interest_catalog.dart';
import 'package:unimatch_user/presentation/widgets/interest_picker.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/profile_providers.dart';

class InterestSelectionScreen extends ConsumerStatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  ConsumerState<InterestSelectionScreen> createState() =>
      _InterestSelectionScreenState();
}

class _InterestSelectionScreenState
    extends ConsumerState<InterestSelectionScreen> {
  final _selected = <String>{};
  final _animeGenres = <String>{};

  @override
  void initState() {
    super.initState();
    _selected.addAll(
      ref.read(currentProfileProvider).value?.interests ?? const [],
    );
    _animeGenres.addAll(
      ref.read(currentProfileProvider).value?.animeGenres ?? const [],
    );
  }

  Future<void> _save() async {
    final validationError = validateInterestSelection(_selected, _animeGenres);
    if (validationError != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }
    final saved = await ref
        .read(profileControllerProvider.notifier)
        .updateInterests(
          _selected.toList()..sort(),
          _animeGenres.toList()..sort(),
        );
    if (saved && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final operation = ref.watch(profileControllerProvider);
    ref.listen<AsyncValue<void>>(profileControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus intereses'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: operation.isLoading
                ? null
                : ref.read(authControllerProvider.notifier).signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  Text(
                    'Selecciona lo que disfrutas',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Esto ayudara a encontrar personas con gustos en comun.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  InterestPicker(
                    interests: _selected,
                    animeGenres: _animeGenres,
                    enabled: !operation.isLoading,
                    onInterestChanged: (change) {
                      final (id, selected) = change;
                      setState(() {
                        if (selected) {
                          _selected.add(id);
                        } else {
                          _selected.remove(id);
                          if (id == 'anime') _animeGenres.clear();
                        }
                      });
                    },
                    onAnimeGenreChanged: (change) {
                      final (id, selected) = change;
                      setState(() {
                        if (selected) {
                          _animeGenres.add(id);
                        } else {
                          _animeGenres.remove(id);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: FilledButton.icon(
                onPressed: operation.isLoading ? null : _save,
                icon: operation.isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text('Continuar (${_selected.length})'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
