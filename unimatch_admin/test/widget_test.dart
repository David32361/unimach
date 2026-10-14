import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unimatch_admin/presentation/app/unimatch_admin_app.dart';
import 'package:unimatch_admin/providers/admin_providers.dart';

void main() {
  testWidgets('shows the protected administrator login', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          adminAccessProvider.overrideWith((ref) async => false),
        ],
        child: const UniMatchAdminApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('UniMatch Admin'), findsOneWidget);
    expect(find.text('Acceso administrativo'), findsOneWidget);
    expect(find.text('Iniciar sesion'), findsOneWidget);
  });
}
