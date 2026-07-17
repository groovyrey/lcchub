import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  PushService._handleMessage(message);
}

class PushService {
  static final FlutterLocalNotificationsPlugin _localNotifs = FlutterLocalNotificationsPlugin();
  static FirebaseMessaging? _messaging;
  static bool _initialized = false;
  static String? _deviceToken;

  static bool get isAvailable => _initialized;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;
      _initialized = true;
      debugPrint('[Push] Firebase initialized');

      // Request permission
      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('[Push] Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        _deviceToken = await _messaging!.getToken();
        debugPrint('[Push] Device token: $_deviceToken');
      } else {
        debugPrint('[Push] Permission denied');
      }

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        _deviceToken = await _messaging!.getToken();
      }

      // Local notif setup
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _localNotifs.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
      );

      // Foreground messages
      FirebaseMessaging.onMessage.listen(_handleMessage);

      // Background tap
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      // Background handler registration
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (_) {
      _initialized = false;
    }
  }

  static String? get deviceToken => _deviceToken;

  static void _handleMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      'lcc_push',
      'LCC Hub Notifications',
      channelDescription: 'Grades, announcements, and payment alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    _localNotifs.show(
      message.messageId.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails),
    );
  }
}
