import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimatch_user/models/public_profile.dart';

class DiscoveryPage {
  const DiscoveryPage({
    required this.profiles,
    required this.lastDocument,
    required this.hasMore,
  });

  final List<PublicProfile> profiles;
  final QueryDocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;
}

class DiscoveryService {
  DiscoveryService(this._firestore);

  final FirebaseFirestore _firestore;
  static const pageSize = 20;

  Future<DiscoveryPage> loadProfilesPage({
    QueryDocumentSnapshot<Map<String, dynamic>>? after,
  }) async {
    var query = _firestore
        .collection('publicProfiles')
        .where('accountStatus', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .limit(pageSize);
    if (after != null) query = query.startAfterDocument(after);
    final snapshot = await query.get();
    return DiscoveryPage(
      profiles: snapshot.docs.map(PublicProfile.fromSnapshot).toList(),
      lastDocument: snapshot.docs.lastOrNull,
      hasMore: snapshot.docs.length == pageSize,
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

    return _firestore.runTransaction((transaction) async {
      final ownSnapshot = await transaction.get(ownLike);
      final reciprocalSnapshot = await transaction.get(reciprocalLike);
      DocumentSnapshot<Map<String, dynamic>>? matchSnapshot;
      DocumentSnapshot<Map<String, dynamic>>? conversationSnapshot;
      if (reciprocalSnapshot.exists) {
        matchSnapshot = await transaction.get(match);
        conversationSnapshot = await transaction.get(conversation);
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
      if (reciprocalSnapshot.exists && conversationSnapshot?.exists != true) {
        transaction.set(conversation, {
          'conversationId': matchId,
          'matchId': matchId,
          'participants': sortedUsers,
          'lastMessage': '',
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastSenderId': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return reciprocalSnapshot.exists;
    });
  }
}
