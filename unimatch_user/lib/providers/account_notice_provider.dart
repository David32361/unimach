import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/profile_providers.dart';

final accountNoticeProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null || !user.emailVerified) return Stream.value(null);
  return ref
      .watch(firebaseFirestoreProvider)
      .collection('accountNotices')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.data());
});
