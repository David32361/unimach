import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService(this._messaging, this._firestore);

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  Future<void> registerDevice(String userId) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    final token = await _messaging.getToken();
    if (token != null) {
      await saveToken(userId, token);
    }
  }

  Future<void> saveToken(String userId, String token) {
    return _deviceReference(userId, token).set({
      'token': token,
      'platform': 'android',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unregisterDevice(String userId) async {
    final token = await _messaging.getToken();
    if (token == null) {
      return;
    }

    await _deviceReference(userId, token).delete();
    await _messaging.deleteToken();
  }

  DocumentReference<Map<String, dynamic>> _deviceReference(
    String userId,
    String token,
  ) {
    final deviceId = base64Url.encode(utf8.encode(token)).replaceAll('=', '');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId);
  }
}
