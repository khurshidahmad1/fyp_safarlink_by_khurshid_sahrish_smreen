import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class FcmHelper {
  // Legacy FCM Server Key fallback placeholder (can be overridden/replaced if needed)
  static const String _fcmServerKey = 'AAAA_fcmKeyPlaceholder';

  /// Fetches recipient user's FCM Token from Firestore and dispatches a push notification.
  /// Fully isolated in try-catch to prevent failure from stalling other flows.
  static Future<void> sendNotification({
    required String recipientUserId,
    required String title,
    required String body,
  }) async {
    if (recipientUserId.isEmpty) return;
    try {
      // 1. Fetch user's registered FCM Token dynamically from root '/users' collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(recipientUserId)
          .get();

      if (!userDoc.exists) {
        debugPrint('FCM Helper: Recipient user $recipientUserId not found in /users.');
        return;
      }

      final String? fcmToken = userDoc.data()?['fcmToken'];
      if (fcmToken == null || fcmToken.trim().isEmpty) {
        debugPrint('FCM Helper: User $recipientUserId has no registered FCM Token.');
        return;
      }

      // 2. Dispatch the HTTP POST request to FCM legacy endpoint
      final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$_fcmServerKey',
      };

      final payload = {
        'to': fcmToken,
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'status': 'done',
          'title': title,
          'body': body,
        },
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        debugPrint('FCM Helper: Notification dispatched successfully.');
      } else {
        debugPrint('FCM Helper: Server responded with status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('FCM Helper: Error occurred while dispatching push notification: $e');
    }
  }
}
