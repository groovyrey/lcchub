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
  static AuthorizationStatus _authStatus = AuthorizationStatus.notDetermined;

  static bool get isAvailable => _initialized;
  static String? get deviceToken => _deviceToken;
  static bool get permissionGranted =>
      _authStatus == AuthorizationStatus.authorized ||
      _authStatus == AuthorizationStatus.provisional;
  static AuthorizationStatus get authorizationStatus => _authStatus;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;
      _initialized = true;

      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      _authStatus = settings.authorizationStatus;

      if (permissionGranted) {
        _deviceToken = await _messaging!.getToken();
      }

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _localNotifs.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
      );

      FirebaseMessaging.onMessage.listen(_handleMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (_) {
      _initialized = false;
    }
  }

  static Future<void> refreshToken() async {
    if (!_initialized || _messaging == null) return;
    try {
      _deviceToken = await _messaging!.getToken();
    } catch (_) {}
  }

  static Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'lcc_push',
      'LCC Hub Notifications',
      channelDescription: 'Grades, announcements, and payment alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _localNotifs.show(
      0,
      'Test Notification',
      'This is a test notification from LCC Hub',
      const NotificationDetails(android: androidDetails),
    );
  }

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
