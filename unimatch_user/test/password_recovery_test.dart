import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unimatch_user/core/errors/auth_failure.dart';
import 'package:unimatch_user/presentation/features/auth/forgot_password_screen.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/repositories/auth_repository.dart';
import 'package:unimatch_user/services/auth_service.dart';

class _FakeAuthService implements AuthService {
  _FakeAuthService(this.onReset);

  final Future<void> Function(String) onReset;

  @override
  Future<void> sendPasswordReset(String email) => onReset(email);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('sends the reset request for an email account', () async {
    String? requestedEmail;
    final repository = AuthRepository(
      _FakeAuthService((email) async => requestedEmail = email),
    );

    await repository.sendPasswordReset('persona@universidad.mx');

    expect(requestedEmail, 'persona@universidad.mx');
  });

  test('does not disclose an unknown email address', () async {
    final repository = AuthRepository(
      _FakeAuthService(
        (_) async => throw FirebaseAuthException(code: 'user-not-found'),
      ),
    );

    await expectLater(
      repository.sendPasswordReset('inexistente@ejemplo.mx'),
      completes,
    );
  });

  test('still surfaces service failures', () async {
    final repository = AuthRepository(
      _FakeAuthService(
        (_) async => throw FirebaseAuthException(code: 'too-many-requests'),
      ),
    );

    await expectLater(
      repository.sendPasswordReset('persona@universidad.mx'),
      throwsA(
        isA<AuthFailure>().having(
          (failure) => failure.code,
          'code',
          'too-many-requests',
        ),
      ),
    );
  });

  for (final unknownEmail in [false, true]) {
    testWidgets(
      unknownEmail
          ? 'unknown email gets the same recovery confirmation'
          : 'email account gets recovery confirmation',
      (tester) async {
        final repository = AuthRepository(
          _FakeAuthService((_) async {
            if (unknownEmail) {
              throw FirebaseAuthException(code: 'user-not-found');
            }
          }),
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [authRepositoryProvider.overrideWithValue(repository)],
            child: const MaterialApp(home: ForgotPasswordScreen()),
          ),
        );

        expect(find.text('Recuperar cuenta de Google'), findsOneWidget);
        await tester.enterText(
          find.byType(TextFormField),
          'persona@universidad.mx',
        );
        await tester.tap(find.text('Enviar enlace'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Solicitud recibida'), findsOneWidget);
        expect(find.text('Reenviar enlace'), findsOneWidget);
      },
    );
  }
}
