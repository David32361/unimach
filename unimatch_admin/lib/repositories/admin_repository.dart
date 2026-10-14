import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimatch_admin/models/admin_report.dart';
import 'package:unimatch_admin/models/admin_user.dart';
import 'package:unimatch_admin/models/recent_message.dart';

class AdminRepository {
  AdminRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<AdminUser>> watchUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(AdminUser.fromDocument).toList());
  }

  Stream<List<AdminReport>> watchReports() {
    return _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(AdminReport.fromDocument).toList(),
        );
  }

  Stream<List<RecentMessage>> watchRecentMessages() {
    final cutoff = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(days: 3)),
    );
    return _firestore
        .collectionGroup('messages')
        .where('timestamp', isGreaterThanOrEqualTo: cutoff)
        .orderBy('timestamp', descending: true)
        .limit(200)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(RecentMessage.fromDocument).toList(),
        );
  }

  Stream<int> watchCollectionCount(String collection) {
    return _firestore
        .collection(collection)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<Map<String, int>> watchUsageSeconds() {
    return _firestore.collectionGroup('sessions').snapshots().map((snapshot) {
      final totals = <String, int>{};
      for (final document in snapshot.docs) {
        final userId = document.reference.parent.parent?.id;
        final duration = document.data()['durationSeconds'];
        if (userId != null && duration is int) {
          totals[userId] = (totals[userId] ?? 0) + duration;
        }
      }
      return totals;
    });
  }

  Stream<Map<String, List<String>>> watchConversationParticipants() {
    return _firestore.collection('conversations').snapshots().map((snapshot) {
      return {
        for (final document in snapshot.docs)
          document.id: List<String>.from(
            document.data()['participants'] as List? ?? const [],
          ),
      };
    });
  }

  Future<void> updateAccountStatus({
    required String adminId,
    required AdminUser user,
    required String status,
    required String reason,
  }) async {
    final batch = _firestore.batch();
    batch.update(_firestore.collection('users').doc(user.uid), {
      'accountStatus': status,
    });
    batch.update(_firestore.collection('publicProfiles').doc(user.uid), {
      'accountStatus': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_firestore.collection('adminActions').doc(), {
      'adminId': adminId,
      'userId': user.uid,
      'action': 'accountStatusChanged',
      'previousStatus': user.accountStatus,
      'newStatus': status,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> updateReportStatus({
    required String adminId,
    required AdminReport report,
    required String status,
  }) async {
    final batch = _firestore.batch();
    batch.update(_firestore.collection('reports').doc(report.id), {
      'status': status,
      'reviewedBy': adminId,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_firestore.collection('adminActions').doc(), {
      'adminId': adminId,
      'userId': report.reportedUserId,
      'reportId': report.id,
      'action': 'reportStatusChanged',
      'previousStatus': report.status,
      'newStatus': status,
      'reason': report.reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
