import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unimatch_user/core/errors/auth_failure.dart';
import 'package:unimatch_user/presentation/app/unimatch_user_app.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/profile_providers.dart';
import 'package:unimatch_user/repositories/auth_repository.dart';
import 'package:unimatch_user/services/auth_service.dart';

class TestUser extends Fake implements User {
  bool verified = false;
  int sends = 0;
  int reloads = 0;
  int tokenRefreshes = 0;
  ActionCodeSettings? settings;
  @override
  String get uid => 'verification-test';
  @override
  String get email => 'estudiante@example.com';
  @override
  bool get emailVerified => verified;
  @override
  Future<void> sendEmailVerification([
    ActionCodeSettings? actionCodeSettings,
  ]) async {
    sends++;
    settings = actionCodeSettings;
  }

  @override
  Future<void> reload() async => reloads++;
  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async {
    if (forceRefresh) tokenRefreshes++;
    return 'test-token';
  }
}

class TestAuth extends Fake implements FirebaseAuth {
  TestAuth(this.user);
  final TestUser user;
  @override
  User get currentUser => user;
  @override
  Future<void> setLanguageCode(String? languageCode) async {}
}

void main() {
  test(
    'sends Firebase link with safe continue URL and limits resend',
    () async {
      final user = TestUser();
      final service = AuthService(TestAuth(user));
      await service.sendEmailVerification();
      expect(
        user.settings!.url,
        'https://unimatch-daniel-2026.web.app/email-verified/',
      );
      expect(user.settings!.handleCodeInApp, isFalse);
      await expectLater(
        service.sendEmailVerification(),
        throwsA(isA<AuthFailure>()),
      );
      expect(user.sends, 1);
    },
  );

  test('verification trusts Firebase and refreshes the server token', () async {
    final user = TestUser();
    final service = AuthService(TestAuth(user));
    expect(await service.refreshEmailVerification(), isFalse);
    user.verified = true;
    expect(await service.refreshEmailVerification(), isTrue);
    expect(user.reloads, 2);
    expect(user.tokenRefreshes, 2);
  });

  testWidgets('unverified session cannot open home or create a profile', (
    tester,
  ) async {
    final user = TestUser();
    final service = AuthService(TestAuth(user));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(TestAuth(user)),
          authRepositoryProvider.overrideWithValue(AuthRepository(service)),
          authStateChangesProvider.overrideWith((ref) => Stream.value(user)),
          adminAccessProvider.overrideWith((ref) async => false),
          // This would fail if a private-profile query started before verification.
          profileRepositoryProvider.overrideWith(
            (ref) => throw StateError('Private profile must not be queried'),
          ),
        ],
        child: const UniMatchUserApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Confirma tu correo'), findsOneWidget);
    expect(find.text('Ya confirmé mi correo'), findsOneWidget);
    expect(find.text('Descubrir'), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
