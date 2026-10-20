import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unimatch_user/models/public_profile.dart';
import 'package:unimatch_user/presentation/features/discovery/discovery_screen.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/discovery_providers.dart';
import 'package:unimatch_user/providers/profile_providers.dart';
import 'package:unimatch_user/providers/safety_providers.dart';
import 'package:unimatch_user/repositories/discovery_repository.dart';
import 'package:unimatch_user/services/discovery_service.dart';

class _FakeDiscoveryRepository implements DiscoveryRepository {
  _FakeDiscoveryRepository(this.pages);

  final List<DiscoveryPage> pages;
  int calls = 0;

  @override
  Future<DiscoveryPage> loadProfilesPage({
    QueryDocumentSnapshot<Map<String, dynamic>>? after,
  }) async => pages[calls++];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFirebaseAuth implements FirebaseAuth {
  @override
  User? get currentUser => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PublicProfile _profile(int index) => PublicProfile(
  uid: 'user-$index',
  name: 'Persona $index',
  age: 21,
  gender: 'Mujer',
  university: 'Universidad Autónoma del Estado de Hidalgo',
  career: 'Ingeniería en Software',
  description: 'Estudiante',
  avatarId: 0,
  interests: const ['anime', 'music_pop', 'books_fantasy'],
  animeGenres: const ['anime_action', 'anime_comedy', 'anime_fantasy'],
);

void main() {
  test(
    'loads all pages and stops at the end without duplicate profiles',
    () async {
      final repository = _FakeDiscoveryRepository([
        DiscoveryPage(
          profiles: List.generate(DiscoveryService.pageSize, _profile),
          lastDocument: null,
          hasMore: true,
        ),
        DiscoveryPage(
          profiles: [_profile(19), _profile(20), _profile(21)],
          lastDocument: null,
          hasMore: false,
        ),
      ]);
      final container = ProviderContainer(
        overrides: [discoveryRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final first = await container.read(discoveryFeedProvider.future);
      expect(first.profiles, hasLength(20));
      expect(first.hasMore, isTrue);

      await container.read(discoveryFeedProvider.notifier).loadMore();
      final last = container.read(discoveryFeedProvider).value!;
      expect(
        last.profiles.map((profile) => profile.uid).toSet(),
        hasLength(22),
      );
      expect(last.hasMore, isFalse);

      await container.read(discoveryFeedProvider.notifier).loadMore();
      expect(repository.calls, 2);
    },
  );

  testWidgets('shows the next profile when scrolling down', (tester) async {
    final repository = _FakeDiscoveryRepository([
      DiscoveryPage(
        profiles: [_profile(0), _profile(1)],
        lastDocument: null,
        hasMore: false,
      ),
    ]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(repository),
          firebaseAuthProvider.overrideWithValue(_FakeFirebaseAuth()),
          currentProfileProvider.overrideWith((ref) => Stream.value(null)),
          outgoingLikesProvider.overrideWith((ref) => Stream.value(<String>{})),
          passesProvider.overrideWith((ref) => Stream.value(<String>{})),
          blockedUserIdsProvider.overrideWith(
            (ref) => Stream.value(<String>{}),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: DiscoveryScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Persona 0, 21'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Persona 1, 21'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Ya viste todos los perfiles.'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Ya viste todos los perfiles.'), findsOneWidget);
  });
}
