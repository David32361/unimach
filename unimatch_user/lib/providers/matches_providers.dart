import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_user/models/public_profile.dart';
import 'package:unimatch_user/models/user_match.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/profile_providers.dart';
import 'package:unimatch_user/services/matches_service.dart';

final matchesServiceProvider = Provider<MatchesService>((ref) {
  return MatchesService(ref.watch(firebaseFirestoreProvider));
});

final matchesProvider = StreamProvider<List<UserMatch>>((ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return Stream.value(const <UserMatch>[]);
  return ref.watch(matchesServiceProvider).watchMatches(uid);
});

final matchedProfileProvider = StreamProvider.family<PublicProfile?, String>((
  ref,
  uid,
) {
  return ref.watch(matchesServiceProvider).watchPublicProfile(uid);
});
