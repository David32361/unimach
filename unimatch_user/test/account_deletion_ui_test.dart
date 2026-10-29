import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unimatch_admin/core/support.dart';
import 'package:unimatch_user/presentation/features/auth/delete_account_screen.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/repositories/auth_repository.dart';

class _Info extends Fake implements UserInfo {
  _Info(this.providerId);
  @override
  final String providerId;
}

class _User extends Fake implements User {
  _User({this.googleOnly = false});
  final bool googleOnly;
  @override
  List<UserInfo> get providerData => [
    _Info(googleOnly ? 'google.com' : 'password'),
  ];
}

class _Auth extends Fake implements FirebaseAuth {
  _Auth(this.user);
  final User user;
  @override
  User get currentUser => user;
}

class _Repository extends Fake implements AuthRepository {
  int calls = 0;
  String? submittedPassword;
  bool? submittedGoogle;
  Completer<void>? pending;
  @override
  Future<void> deleteOwnAccount({
    String? password,
    bool withGoogle = false,
  }) async {
    calls++;
    submittedPassword = password;
    submittedGoogle = withGoogle;
    if (pending != null) await pending!.future;
  }
}

void main() {
  Future<void> show(
    WidgetTester tester,
    _Repository repository, {
    bool google = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(
            _Auth(_User(googleOnly: google)),
          ),
          authRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: DeleteAccountScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  if (!accountManagementBackendEnabled) {
    testWidgets(
      'Spark build exposes the contact without pretending to delete an account',
      (tester) async {
        final repository = _Repository();
        await show(tester, repository);
        expect(find.text(supportEmail), findsOneWidget);
        expect(
          find.textContaining(
            'La eliminación automática aún no está disponible',
          ),
          findsOneWidget,
        );
        expect(find.text('Eliminar definitivamente'), findsNothing);
        expect(find.byType(TextField), findsNothing);
        expect(repository.calls, 0);
      },
    );
  } else {
    testWidgets(
      'deletion requires the exact confirmation and prevents duplicate requests',
      (tester) async {
        final repository = _Repository()..pending = Completer<void>();
        await show(tester, repository);
        final button = find.widgetWithText(
          FilledButton,
          'Eliminar definitivamente',
        );
        expect(tester.widget<FilledButton>(button).onPressed, isNull);
        await tester.enterText(find.byType(TextField).first, 'Test-password1!');
        await tester.enterText(find.byType(TextField).last, 'eliminar');
        await tester.pump();
        expect(tester.widget<FilledButton>(button).onPressed, isNull);
        await tester.enterText(find.byType(TextField).last, 'ELIMINAR');
        await tester.pump();
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pump();
        expect(repository.calls, 1);
        expect(tester.widget<FilledButton>(button).onPressed, isNull);
        repository.pending!.complete();
        await tester.pumpAndSettle();
        expect(repository.submittedPassword, 'Test-password1!');
        expect(find.textContaining('Eliminación solicitada.'), findsOneWidget);
      },
    );
    testWidgets(
      'Google-only account confirms with Google without asking for a password',
      (tester) async {
        final repository = _Repository();
        await show(tester, repository, google: true);
        expect(find.byType(TextField), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'ELIMINAR');
        await tester.pump();
        final button = find.widgetWithText(
          FilledButton,
          'Eliminar definitivamente',
        );
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(repository.submittedGoogle, isTrue);
      },
    );
  }
}
