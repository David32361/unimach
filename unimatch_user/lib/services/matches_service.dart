import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimatch_user/models/public_profile.dart';
import 'package:unimatch_user/models/user_match.dart';

class MatchesService {
  MatchesService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<UserMatch>> watchMatches(String uid) {
    return _firestore
        .collection('matches')
        .where('userIds', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
          final matches = snapshot.docs
              .map(UserMatch.fromSnapshot)
              .where((match) => match.status == 'active')
              .toList();
          matches.sort(
            (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
              a.createdAt ?? DateTime(1970),
            ),
          );
          return matches;
        });
  }

  Stream<PublicProfile?> watchPublicProfile(String uid) {
    return _firestore.collection('publicProfiles').doc(uid).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return PublicProfile.fromSnapshot(doc);
    });
  }
}
