import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimatch_user/core/errors/discovery_failure.dart';
import 'package:unimatch_user/services/discovery_service.dart';

class DiscoveryRepository {
  DiscoveryRepository(this._service);

  final DiscoveryService _service;

  Future<DiscoveryPage> loadProfilesPage({
    QueryDocumentSnapshot<Map<String, dynamic>>? after,
  }) async {
    try {
      return await _service.loadProfilesPage(after: after);
    } on FirebaseException catch (error) {
      throw DiscoveryFailure.fromFirebase(error);
    }
  }

  Stream<Set<String>> watchOutgoingLikes(String uid) =>
      _service.watchOutgoingLikes(uid);

  Stream<Set<String>> watchPasses(String uid) => _service.watchPasses(uid);

  Future<void> pass({required String uid, required String targetUid}) async {
    try {
      await _service.pass(uid: uid, targetUid: targetUid);
    } on FirebaseException catch (error) {
      throw DiscoveryFailure.fromFirebase(error);
    }
  }

  Future<bool> like({required String uid, required String targetUid}) async {
    try {
      return await _service.like(uid: uid, targetUid: targetUid);
    } on FirebaseException catch (error) {
      throw DiscoveryFailure.fromFirebase(error);
    }
  }
}
