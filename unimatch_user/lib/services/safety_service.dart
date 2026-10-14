import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class SafetyService {
  SafetyService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<Set<String>> watchBlockedUserIds(String uid) {
    final controller = StreamController<Set<String>>();
    var outgoing = <String>{};
    var incoming = <String>{};

    void emit() => controller.add({...outgoing, ...incoming});

    final outgoingSubscription = _firestore
        .collection('blocks')
        .where('blockerId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          outgoing = snapshot.docs
              .map((doc) => doc.data()['blockedUserId'] as String)
              .toSet();
          emit();
        }, onError: controller.addError);
    final incomingSubscription = _firestore
        .collection('blocks')
        .where('blockedUserId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          incoming = snapshot.docs
              .map((doc) => doc.data()['blockerId'] as String)
              .toSet();
          emit();
        }, onError: controller.addError);

    controller.onCancel = () async {
      await outgoingSubscription.cancel();
      await incomingSubscription.cancel();
    };
    return controller.stream;
  }

  Future<void> block({required String uid, required String blockedUserId}) {
    return _firestore.collection('blocks').doc('${uid}_$blockedUserId').set({
      'blockerId': uid,
      'blockedUserId': blockedUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> report({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    required String description,
  }) {
    return _firestore.collection('reports').add({
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'description': description.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }
}
