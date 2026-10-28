import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unimatch_user/models/public_profile.dart';
import 'package:unimatch_user/models/user_match.dart';
import 'package:unimatch_user/presentation/features/matches/sent_interests_tab.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/discovery_providers.dart';
import 'package:unimatch_user/providers/matches_providers.dart';
import 'package:unimatch_user/providers/safety_providers.dart';

void main() {
  testWidgets('pending interests exclude mutual matches and blocked users', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
          outgoingLikesProvider.overrideWith(
            (ref) => Stream.value({'bob', 'carol', 'blocked'}),
          ),
          blockedUserIdsProvider.overrideWith(
            (ref) => Stream.value({'blocked'}),
          ),
          matchesProvider.overrideWith(
            (ref) => Stream.value([
              const UserMatch(
                id: '_bob',
                userIds: ['', 'bob'],
                status: 'active',
              ),
            ]),
          ),
          matchedProfileProvider.overrideWith(
            (ref, uid) => Stream.value(
              PublicProfile(
                uid: uid,
                name: uid,
                age: 21,
                gender: 'Mujer',
                university: 'UTVM',
                career: 'Ingeniería',
                description: 'Perfil de prueba',
                avatarId: 0,
                interests: const [],
                animeGenres: const [],
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: SentInterestsTab())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('carol'), findsOneWidget);
    expect(find.text('bob'), findsNothing);
    expect(find.text('blocked'), findsNothing);
    expect(
      find.text('Interés enviado · Esperando interés mutuo'),
      findsOneWidget,
    );
  });
}
