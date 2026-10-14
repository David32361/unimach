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
  InterestCategory('Peliculas', [
    InterestOption('movies_action', 'Accion'),
    InterestOption('movies_horror', 'Terror'),
    InterestOption('movies_comedy', 'Comedia'),
    InterestOption('movies_romance', 'Romance'),
    InterestOption('movies_fantasy', 'Fantasia'),
    InterestOption('movies_scifi', 'Ciencia ficcion'),
  ]),
  InterestCategory('Musica', [
    InterestOption('music_rock', 'Rock'),
    InterestOption('music_pop', 'Pop'),
    InterestOption('music_electronic', 'Electronica'),
    InterestOption('music_rap', 'Rap'),
    InterestOption('music_regional', 'Regional'),
    InterestOption('music_classical', 'Clasica'),
  ]),
  InterestCategory('Deportes', [
    InterestOption('sports_soccer', 'Futbol'),
    InterestOption('sports_basketball', 'Basquetbol'),
    InterestOption('sports_swimming', 'Natacion'),
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
    InterestOption('books_fantasy', 'Fantasia'),
    InterestOption('books_scifi', 'Ciencia ficcion'),
    InterestOption('books_romance', 'Romance'),
    InterestOption('books_mystery', 'Misterio'),
    InterestOption('books_horror', 'Terror'),
  ]),
];

final interestLabels = <String, String>{
  for (final category in interestCatalog)
    for (final option in category.options) option.id: option.label,
};
