import 'package:flutter_test/flutter_test.dart';
import 'package:unimatch_user/models/academic_catalog.dart';

void main() {
  test('university search accepts names, accents and official acronyms', () {
    expect(
      searchAcademicOptions(hidalgoUniversities, 'uaeh').single.name,
      'Universidad Autónoma del Estado de Hidalgo',
    );
    expect(
      searchAcademicOptions(hidalgoUniversities, 'tecnologica tula').first.name,
      'Universidad Tecnológica de Tula-Tepeji',
    );
    expect(
      searchAcademicOptions(hidalgoUniversities, 'UTTT').single.name,
      'Universidad Tecnológica de Tula-Tepeji',
    );
    expect(searchAcademicOptions(hidalgoUniversities, 'UNAM'), isEmpty);
  });

  test('career search accepts name and initials', () {
    expect(
      searchAcademicOptions(careerCatalog, 'ISC').single.name,
      'Ingeniería en Sistemas Computacionales',
    );
    expect(
      searchAcademicOptions(
        careerCatalog,
        'ingenieria en sistemas',
      ).single.name,
      'Ingeniería en Sistemas Computacionales',
    );
    expect(findAcademicOption(careerCatalog, 'MED')?.name, 'Medicina');
  });

  test('catalog entries have unique names and university acronyms', () {
    expect(
      hidalgoUniversities.map((option) => option.name).toSet().length,
      hidalgoUniversities.length,
    );
    expect(
      hidalgoUniversities.map((option) => option.acronym).toSet().length,
      hidalgoUniversities.length,
    );
    expect(
      careerCatalog.map((option) => option.name).toSet().length,
      careerCatalog.length,
    );
  });
}
