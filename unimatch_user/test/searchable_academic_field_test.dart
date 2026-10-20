import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unimatch_user/models/academic_catalog.dart';
import 'package:unimatch_user/presentation/widgets/searchable_academic_field.dart';

void main() {
  testWidgets('shows a list and saves only a selected university', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    AcademicOption? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: SearchableAcademicField(
              label: 'Universidad',
              icon: Icons.school_outlined,
              options: hidalgoUniversities,
              onSelected: (option) => selected = option,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    expect(
      find.text('Universidad Autónoma del Estado de Hidalgo'),
      findsOneWidget,
    );
    expect(formKey.currentState!.validate(), isFalse);

    await tester.enterText(find.byType(TextFormField), 'uaeh');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Universidad Autónoma del Estado de Hidalgo'));
    await tester.pumpAndSettle();
    expect(selected?.acronym, 'UAEH');
    expect(formKey.currentState!.validate(), isTrue);

    await tester.enterText(find.byType(TextFormField), 'Otra universidad');
    await tester.pumpAndSettle();
    expect(selected, isNull);
    expect(formKey.currentState!.validate(), isFalse);
  });
}
