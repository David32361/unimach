import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReport {
  const AdminReport({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String reporterId;
  final String reportedUserId;
  final String reason;
  final String description;
  final String status;
  final DateTime? createdAt;

  factory AdminReport.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return AdminReport(
      id: doc.id,
      reporterId: data['reporterId'] as String? ?? '',
      reportedUserId: data['reportedUserId'] as String? ?? '',
      reason: data['reason'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
