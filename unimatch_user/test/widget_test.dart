import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unimatch_user/presentation/app/unimatch_user_app.dart';
import 'package:unimatch_user/providers/auth_providers.dart';

void main() {
  testWidgets('shows authentication options while signed out', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const UniMatchUserApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.text('Continuar con Google'), findsOneWidget);
    expect(find.text('Regístrate'), findsOneWidget);
    expect(find.text('Política de privacidad'), findsOneWidget);
  });
}
