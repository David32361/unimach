import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unimatch_admin/core/support.dart';
import 'package:unimatch_admin/models/admin_user.dart';
import 'package:unimatch_admin/presentation/features/admin/users_screen.dart';
import 'package:unimatch_admin/providers/admin_providers.dart';
import 'package:unimatch_admin/repositories/admin_repository.dart';

class _Firestore extends Fake implements FirebaseFirestore {}

const _user = AdminUser(
  uid: 'example',
  name: 'Cuenta de prueba',
  email: 'example@example.test',
  age: 22,
  gender: 'Otro',
  university: 'Universidad',
  career: 'Carrera',
  avatarId: 0,
  accountStatus: 'active',
  createdAt: null,
  lastActivity: null,
);

void main() {
  if (!accountManagementBackendEnabled) {
    test(
      'permanent deletion cannot fall back to a Firestore status change',
      () async {
        final repository = AdminRepository(_Firestore());
        await expectLater(
          repository.updateAccountStatus(
            adminId: 'admin',
            user: _user,
            status: 'deleted',
            reason: 'Prueba de borrado',
          ),
          throwsA(
            isA<FirebaseException>().having(
              (error) => error.code,
              'code',
              'backend-unavailable',
            ),
          ),
        );
      },
    );

    testWidgets(
      'moderation shows the contact and disables unavailable deletion',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 1500);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              adminUsersProvider.overrideWith((ref) => Stream.value([_user])),
            ],
            child: const MaterialApp(home: Scaffold(body: UsersScreen())),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.manage_accounts_outlined));
        await tester.pumpAndSettle();
        expect(find.text(supportEmail), findsOneWidget);
        final dropdown = tester.widget<DropdownButton<String>>(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(DropdownButton<String>),
          ),
        );
        final item = dropdown.items!.singleWhere(
          (item) => item.value == 'deleted',
        );
        expect(item.enabled, isFalse);
        expect(
          find.textContaining('pendiente de activar el servicio'),
          findsOneWidget,
        );
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
      },
    );
  }
}
