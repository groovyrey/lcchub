import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/models.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
  }

  static Future<bool> requestPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final result = await Permission.notification.request();
    return result.isGranted;
  }

  static Future<void> scheduleDailyReminder(List<ScheduleItem> schedule) async {
    await _plugin.cancelAll();

    final todayClasses = _getTodayClasses(schedule);
    if (todayClasses.isEmpty) return;

    final body = todayClasses.map((item) {
      final time = item.time.isNotEmpty ? item.time : 'TBA';
      final room = item.room.isNotEmpty ? ' @ ${item.room}' : '';
      return '${item.subject}$room - $time';
    }).join('\n');

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 6, 0);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      1001,
      "Today's Schedule",
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_reminders',
          'Schedule Reminders',
          channelDescription: 'Daily reminders for your class schedule',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static List<ScheduleItem> _getTodayClasses(List<ScheduleItem> schedule) {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    final todayAbbrev = switch (dayOfWeek) {
      1 => 'm',
      2 => 't',
      3 => 'w',
      4 => 'th',
      5 => 'f',
      6 => 'sa',
      7 => 'su',
      _ => '',
    };

    return schedule.where((item) {
      final timeLower = item.time.toLowerCase();
      return switch (todayAbbrev) {
        'm' => timeLower.contains('m') && !timeLower.contains('w') && !timeLower.contains('f'),
        't' => timeLower.contains('t') && !timeLower.contains('th'),
        'w' => timeLower.contains('w'),
        'th' => timeLower.contains('th') || (timeLower.contains('t') && !timeLower.contains('tu')),
        'f' => timeLower.contains('f'),
        'sa' => timeLower.contains('sa') || timeLower.contains('sat'),
        'su' => timeLower.contains('su') || timeLower.contains('sun'),
        _ => false,
      };
    }).toList();
  }
}
