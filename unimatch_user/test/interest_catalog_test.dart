import 'package:flutter_test/flutter_test.dart';
import 'package:unimatch_user/models/interest_catalog.dart';

void main() {
  test('interest identifiers are unique and mapped to labels', () {
    final options = [
      for (final category in interestCatalog) ...category.options,
    ];
    final ids = options.map((option) => option.id).toSet();

    expect(ids.length, options.length);
    expect(interestLabels.length, options.length);
    expect(options.length, 28);
    expect(interestLabels['anime'], 'Anime');
  });

  test('anime genres have unique identifiers', () {
    final ids = animeGenreCatalog.map((option) => option.id).toSet();
    expect(ids.length, animeGenreCatalog.length);
    expect(animeGenreLabels.length, animeGenreCatalog.length);
  });

  test('requires three distinct tastes', () {
    expect(
      validateInterestSelection([
        'movies_action',
        'movies_action',
        'music_rock',
      ], []),
      isNotNull,
    );
    expect(
      validateInterestSelection([
        'movies_action',
        'music_rock',
        'books_fantasy',
      ], []),
      isNull,
    );
  });

  test('anime requires three separate genres in addition to three tastes', () {
    const tastes = ['anime', 'music_rock', 'books_fantasy'];
    expect(
      validateInterestSelection(tastes, ['anime_action', 'anime_comedy']),
      isNotNull,
    );
    expect(
      validateInterestSelection(tastes, [
        'anime_action',
        'anime_action',
        'anime_comedy',
      ]),
      isNotNull,
    );
    expect(
      validateInterestSelection(tastes, [
        'anime_action',
        'anime_comedy',
        'anime_romance',
      ]),
      isNull,
    );
    expect(
      validateInterestSelection(
        ['anime', 'music_rock'],
        ['anime_action', 'anime_comedy', 'anime_romance'],
      ),
      isNotNull,
    );
    expect(
      validateInterestSelection(
        ['movies_action', 'music_rock', 'books_fantasy'],
        ['anime_action', 'anime_comedy', 'anime_romance'],
      ),
      isNotNull,
    );
  });
}
