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
    expect(options.length, 27);
  });
}
