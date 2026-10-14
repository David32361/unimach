import 'package:cloud_firestore/cloud_firestore.dart';

class UsageSessionService {
  UsageSessionService(this._firestore);

  final FirebaseFirestore _firestore;
  DocumentReference<Map<String, dynamic>>? _session;
  String? _userId;
  DateTime? _startedAt;
  Future<void>? _starting;

  Future<void> startSession(String userId) async {
    await _starting;
    if (_session != null && _userId == userId) return;
    await endSession();

    final operation = _createSession(userId);
    _starting = operation;
    try {
      await operation;
    } finally {
      _starting = null;
    }
  }

  Future<void> _createSession(String userId) async {
    final reference = _firestore
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc();
    await reference.set({
      'userId': userId,
      'startedAt': FieldValue.serverTimestamp(),
      'endedAt': null,
      'durationSeconds': 0,
    });
    _session = reference;
    _userId = userId;
    _startedAt = DateTime.now();
  }

  Future<void> endSession() async {
    await _starting;
    final reference = _session;
    final userId = _userId;
    final startedAt = _startedAt;
    _session = null;
    _userId = null;
    _startedAt = null;
    if (reference == null || userId == null || startedAt == null) return;

    final duration = DateTime.now()
        .difference(startedAt)
        .inSeconds
        .clamp(0, 86400);
    final batch = _firestore.batch();
    batch.update(reference, {
      'endedAt': FieldValue.serverTimestamp(),
      'durationSeconds': duration,
    });
    batch.update(_firestore.collection('users').doc(userId), {
      'lastActivity': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
