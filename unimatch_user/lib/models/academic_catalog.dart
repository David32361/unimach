class AcademicOption {
  const AcademicOption(this.name, {this.acronym = '', this.aliases = const []});

  final String name;
  final String acronym;
  final List<String> aliases;

  String get initials {
    if (acronym.isNotEmpty) return acronym;
    const ignored = {'de', 'del', 'en', 'la', 'las', 'los', 'y'};
    return name
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty && !ignored.contains(word))
        .map((word) => normalizeAcademicSearch(word)[0])
        .join()
        .toUpperCase();
  }
}

String normalizeAcademicSearch(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp('[áàäâ]'), 'a')
    .replaceAll(RegExp('[éèëê]'), 'e')
    .replaceAll(RegExp('[íìïî]'), 'i')
    .replaceAll(RegExp('[óòöô]'), 'o')
    .replaceAll(RegExp('[úùüû]'), 'u')
    .replaceAll('ñ', 'n')
    .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

List<AcademicOption> searchAcademicOptions(
  List<AcademicOption> options,
  String query,
) {
  final needle = normalizeAcademicSearch(query);
  if (needle.isEmpty) return options;
  final compactNeedle = needle.replaceAll(' ', '');
  return options
      .where((option) {
        final name = normalizeAcademicSearch(option.name);
        final initials = normalizeAcademicSearch(
          option.initials,
        ).replaceAll(' ', '');
        return needle.split(' ').every(name.contains) ||
            initials.contains(compactNeedle) ||
            option.aliases.any(
              (alias) => normalizeAcademicSearch(alias).contains(needle),
            );
      })
      .toList(growable: false);
}

AcademicOption? findAcademicOption(List<AcademicOption> options, String value) {
  final needle = normalizeAcademicSearch(value);
  for (final option in options) {
    if (normalizeAcademicSearch(option.name) == needle ||
        normalizeAcademicSearch(option.initials) == needle ||
        option.aliases.any(
          (alias) => normalizeAcademicSearch(alias) == needle,
        )) {
      return option;
    }
  }
  return null;
}

// Instituciones de educacion superior con sede en Hidalgo.
const hidalgoUniversities = <AcademicOption>[
  AcademicOption('Universidad Autónoma del Estado de Hidalgo', acronym: 'UAEH'),
  AcademicOption(
    'Universidad Digital del Estado de Hidalgo',
    acronym: 'UNIDEH',
  ),
  AcademicOption(
    'Universidad Intercultural del Estado de Hidalgo',
    acronym: 'UICEH',
  ),
  AcademicOption(
    'Universidad Pedagógica Nacional, Unidad Hidalgo',
    acronym: 'UPN',
  ),
  AcademicOption('Universidad Politécnica de la Energía', acronym: 'UPE'),
  AcademicOption(
    'Universidad Politécnica de Francisco I. Madero',
    acronym: 'UPFIM',
  ),
  AcademicOption('Universidad Politécnica de Huejutla', acronym: 'UPH'),
  AcademicOption('Universidad Politécnica de Pachuca', acronym: 'UPP'),
  AcademicOption('Universidad Politécnica de Tulancingo', acronym: 'UPT'),
  AcademicOption(
    'Universidad Politécnica Metropolitana de Hidalgo',
    acronym: 'UPMH',
  ),
  AcademicOption(
    'Universidad Tecnológica de la Huasteca Hidalguense',
    acronym: 'UTHH',
  ),
  AcademicOption(
    'Universidad Tecnológica de la Sierra Hidalguense',
    acronym: 'UTSH',
  ),
  AcademicOption(
    'Universidad Tecnológica de la Zona Metropolitana del Valle de México',
    acronym: 'UTVAM',
  ),
  AcademicOption(
    'Universidad Tecnológica de Mineral de la Reforma',
    acronym: 'UTMIR',
  ),
  AcademicOption('Universidad Tecnológica de Tula-Tepeji', acronym: 'UTTT'),
  AcademicOption('Universidad Tecnológica de Tulancingo', acronym: 'UTT'),
  AcademicOption(
    'Universidad Tecnológica del Valle del Mezquital',
    acronym: 'UTVM',
  ),
  AcademicOption('Universidad Tecnológica Minera de Zimapán', acronym: 'UTMZ'),
  AcademicOption('Instituto Tecnológico de Pachuca', acronym: 'ITP'),
  AcademicOption('Instituto Tecnológico de Huejutla', acronym: 'ITH'),
  AcademicOption(
    'Instituto Tecnológico Superior de Huichapan',
    acronym: 'ITESHU',
  ),
  AcademicOption(
    'Instituto Tecnológico Superior del Occidente del Estado de Hidalgo',
    acronym: 'ITSOEH',
  ),
  AcademicOption(
    'Instituto Tecnológico Superior del Oriente del Estado de Hidalgo',
    acronym: 'ITESA',
  ),
  AcademicOption('El Colegio del Estado de Hidalgo', acronym: 'CEH'),
  AcademicOption('Escuela de Música del Estado de Hidalgo', acronym: 'EMEH'),
  AcademicOption('Universidad La Salle Pachuca', acronym: 'ULSAP'),
  AcademicOption('Tecnológico de Monterrey, Campus Hidalgo', acronym: 'ITESM'),
  AcademicOption(
    'Universidad del Fútbol y Ciencias del Deporte',
    acronym: 'UFD',
  ),
];

// Catalogo general: la oferta concreta depende de cada institucion.
const careerCatalog = <AcademicOption>[
  AcademicOption('Administración', acronym: 'ADM'),
  AcademicOption('Arquitectura', acronym: 'ARQ'),
  AcademicOption('Biología', acronym: 'BIO'),
  AcademicOption('Ciencias de la Comunicación', acronym: 'CC'),
  AcademicOption('Ciencias del Deporte', acronym: 'CD'),
  AcademicOption('Comercio Internacional', acronym: 'CI'),
  AcademicOption('Contaduría Pública', acronym: 'CP'),
  AcademicOption('Derecho', acronym: 'DER'),
  AcademicOption('Diseño Gráfico', acronym: 'DG'),
  AcademicOption('Educación', acronym: 'EDU'),
  AcademicOption('Enfermería', acronym: 'ENF'),
  AcademicOption('Gastronomía', acronym: 'GAS'),
  AcademicOption('Ingeniería Ambiental', acronym: 'IA'),
  AcademicOption('Ingeniería Biomédica', acronym: 'IB'),
  AcademicOption('Ingeniería Civil', acronym: 'IC'),
  AcademicOption('Ingeniería en Energía', acronym: 'IE'),
  AcademicOption('Ingeniería en Sistemas Computacionales', acronym: 'ISC'),
  AcademicOption('Ingeniería en Software', acronym: 'IS'),
  AcademicOption('Ingeniería Industrial', acronym: 'II'),
  AcademicOption('Ingeniería Mecánica', acronym: 'IM'),
  AcademicOption('Ingeniería Mecatrónica', acronym: 'IME'),
  AcademicOption('Ingeniería Minero Metalúrgica', acronym: 'IMM'),
  AcademicOption('Ingeniería Química', acronym: 'IQ'),
  AcademicOption('Lenguas Extranjeras', acronym: 'LE'),
  AcademicOption('Licenciatura en Turismo', acronym: 'LT'),
  AcademicOption('Matemáticas Aplicadas', acronym: 'MA'),
  AcademicOption('Medicina', acronym: 'MED'),
  AcademicOption('Mercadotecnia', acronym: 'MKT'),
  AcademicOption('Nutrición', acronym: 'NUT'),
  AcademicOption('Odontología', acronym: 'ODO'),
  AcademicOption('Pedagogía', acronym: 'PED'),
  AcademicOption('Psicología', acronym: 'PSI'),
  AcademicOption('Tecnologías de la Información', acronym: 'TI'),
  AcademicOption('Trabajo Social', acronym: 'TS'),
  AcademicOption('Veterinaria y Zootecnia', acronym: 'MVZ'),
];
