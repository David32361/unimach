class InterestOption {
  const InterestOption(this.id, this.label);

  final String id;
  final String label;
}

class InterestCategory {
  const InterestCategory(this.name, this.options);

  final String name;
  final List<InterestOption> options;
}

const interestCatalog = <InterestCategory>[
  InterestCategory('Películas', [
    InterestOption('movies_action', 'Acción'),
    InterestOption('movies_horror', 'Terror'),
    InterestOption('movies_comedy', 'Comedia'),
    InterestOption('movies_romance', 'Romance'),
    InterestOption('movies_fantasy', 'Fantasía'),
    InterestOption('movies_scifi', 'Ciencia ficción'),
  ]),
  InterestCategory('Música', [
    InterestOption('music_rock', 'Rock'),
    InterestOption('music_pop', 'Pop'),
    InterestOption('music_electronic', 'Electrónica'),
    InterestOption('music_rap', 'Rap'),
    InterestOption('music_regional', 'Regional'),
    InterestOption('music_classical', 'Clásica'),
  ]),
  InterestCategory('Deportes', [
    InterestOption('sports_soccer', 'Fútbol'),
    InterestOption('sports_basketball', 'Básquetbol'),
    InterestOption('sports_swimming', 'Natación'),
    InterestOption('sports_gym', 'Gimnasio'),
    InterestOption('sports_athletics', 'Atletismo'),
  ]),
  InterestCategory('Videojuegos', [
    InterestOption('games_rpg', 'RPG'),
    InterestOption('games_fps', 'FPS'),
    InterestOption('games_strategy', 'Estrategia'),
    InterestOption('games_moba', 'MOBA'),
    InterestOption('games_sports', 'Deportes'),
  ]),
  InterestCategory('Libros', [
    InterestOption('books_fantasy', 'Fantasía'),
    InterestOption('books_scifi', 'Ciencia ficción'),
    InterestOption('books_romance', 'Romance'),
    InterestOption('books_mystery', 'Misterio'),
    InterestOption('books_horror', 'Terror'),
  ]),
  InterestCategory('Anime', [InterestOption('anime', 'Anime')]),
];

const animeGenreCatalog = <InterestOption>[
  InterestOption('anime_action', 'Acción'),
  InterestOption('anime_adventure', 'Aventura'),
  InterestOption('anime_comedy', 'Comedia'),
  InterestOption('anime_drama', 'Drama'),
  InterestOption('anime_fantasy', 'Fantasía'),
  InterestOption('anime_horror', 'Terror'),
  InterestOption('anime_isekai', 'Isekai'),
  InterestOption('anime_mecha', 'Mecha'),
  InterestOption('anime_mystery', 'Misterio'),
  InterestOption('anime_romance', 'Romance'),
  InterestOption('anime_scifi', 'Ciencia ficción'),
  InterestOption('anime_slice_of_life', 'Vida cotidiana'),
  InterestOption('anime_sports', 'Deportes'),
  InterestOption('anime_supernatural', 'Sobrenatural'),
];

final interestLabels = <String, String>{
  for (final category in interestCatalog)
    for (final option in category.options) option.id: option.label,
};

final animeGenreLabels = <String, String>{
  for (final option in animeGenreCatalog) option.id: option.label,
};

String? validateInterestSelection(
  Iterable<String> interests,
  Iterable<String> animeGenres,
) {
  final selected = interests.toSet();
  final genres = animeGenres.toSet();
  if (selected.where(interestLabels.containsKey).length < 3) {
    return 'Selecciona al menos 3 gustos diferentes.';
  }
  if (selected.contains('anime')) {
    if (genres.where(animeGenreLabels.containsKey).length < 3) {
      return 'Selecciona al menos 3 géneros de anime.';
    }
  } else if (genres.isNotEmpty) {
    return 'Selecciona Anime para guardar sus géneros.';
  }
  return null;
}
