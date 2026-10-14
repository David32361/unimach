import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimatch_user/models/public_profile.dart';

class DiscoveryService {
  DiscoveryService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<PublicProfile>> watchPublicProfiles() {
    return _firestore
        .collection('publicProfiles')
        .where('accountStatus', isEqualTo: 'active')
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(PublicProfile.fromSnapshot)
              .toList(growable: false),
        );
  }

  Stream<Set<String>> watchOutgoingLikes(String uid) {
    return _firestore
        .collection('likes')
        .where('senderId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data()['receiverId'] as String)
              .toSet(),
        );
  }

  Stream<Set<String>> watchPasses(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('passes')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  Future<void> pass({required String uid, required String targetUid}) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('passes')
        .doc(targetUid)
        .set({
          'userId': uid,
          'targetUserId': targetUid,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<bool> like({required String uid, required String targetUid}) async {
    final ownLikeId = '${uid}_$targetUid';
    final reciprocalLikeId = '${targetUid}_$uid';
    final sortedUsers = [uid, targetUid]..sort();
    final matchId = '${sortedUsers[0]}_${sortedUsers[1]}';
    final ownLike = _firestore.collection('likes').doc(ownLikeId);
    final reciprocalLike = _firestore.collection('likes').doc(reciprocalLikeId);
    final match = _firestore.collection('matches').doc(matchId);
    final conversation = _firestore.collection('conversations').doc(matchId);

    final matched = await _firestore.runTransaction((transaction) async {
      final ownSnapshot = await transaction.get(ownLike);
      final reciprocalSnapshot = await transaction.get(reciprocalLike);
      DocumentSnapshot<Map<String, dynamic>>? matchSnapshot;
      if (reciprocalSnapshot.exists) {
        matchSnapshot = await transaction.get(match);
      }

      if (!ownSnapshot.exists) {
        transaction.set(ownLike, {
          'senderId': uid,
          'receiverId': targetUid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      if (reciprocalSnapshot.exists && matchSnapshot?.exists != true) {
        transaction.set(match, {
          'matchId': matchId,
          'user1': sortedUsers[0],
          'user2': sortedUsers[1],
          'userIds': sortedUsers,
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'active',
        });
      }
      return reciprocalSnapshot.exists;
    });

    if (matched) {
      final conversationSnapshot = await conversation.get();
      if (!conversationSnapshot.exists) {
        await conversation.set({
          'conversationId': matchId,
          'matchId': matchId,
          'participants': sortedUsers,
          'lastMessage': '',
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastSenderId': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    return matched;
  }
}
