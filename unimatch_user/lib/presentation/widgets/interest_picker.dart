import 'package:flutter/material.dart';
import 'package:unimatch_user/models/interest_catalog.dart';

class InterestPicker extends StatelessWidget {
  const InterestPicker({
    super.key,
    required this.interests,
    required this.animeGenres,
    required this.onInterestChanged,
    required this.onAnimeGenreChanged,
    this.enabled = true,
  });

  final Set<String> interests;
  final Set<String> animeGenres;
  final ValueChanged<(String, bool)> onInterestChanged;
  final ValueChanged<(String, bool)> onAnimeGenreChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gustos (${interests.length}, minimo 3)', style: titleStyle),
        const SizedBox(height: 12),
        for (final category in interestCatalog) ...[
          Text(category.name, style: titleStyle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in category.options)
                FilterChip(
                  label: Text(option.label),
                  selected: interests.contains(option.id),
                  onSelected: enabled
                      ? (selected) => onInterestChanged((option.id, selected))
                      : null,
                ),
            ],
          ),
          if (category.name == 'Anime' && interests.contains('anime')) ...[
            const SizedBox(height: 14),
            Text(
              'Generos de anime (${animeGenres.length}, minimo 3)',
              style: titleStyle,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final genre in animeGenreCatalog)
                  FilterChip(
                    label: Text(genre.label),
                    selected: animeGenres.contains(genre.id),
                    onSelected: enabled
                        ? (selected) =>
                              onAnimeGenreChanged((genre.id, selected))
                        : null,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}
