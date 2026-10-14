import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimatch_user/models/interest_catalog.dart';
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

  @override
  void initState() {
    super.initState();
    _selected.addAll(
      ref.read(currentProfileProvider).value?.interests ?? const [],
    );
  }

  Future<void> _save() async {
    if (_selected.length < 3) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Selecciona al menos 3 intereses.')),
        );
      return;
    }
    final saved = await ref
        .read(profileControllerProvider.notifier)
        .updateInterests(_selected.toList()..sort());
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
            tooltip: 'Cerrar sesion',
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
                  for (final category in interestCatalog) ...[
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final option in category.options)
                          ChoiceChip(
                            label: Text(option.label),
                            selected: _selected.contains(option.id),
                            onSelected: operation.isLoading
                                ? null
                                : (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selected.add(option.id);
                                      } else {
                                        _selected.remove(option.id);
                                      }
                                    });
                                  },
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
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
