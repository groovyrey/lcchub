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

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 6, 0);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final fireDate = DateTime(scheduled.year, scheduled.month, scheduled.day);
    final fireDateClasses = getTodayClasses(schedule, referenceDate: fireDate);
    if (fireDateClasses.isEmpty) return;

    final body = fireDateClasses.map((item) {
      final time = item.time.isNotEmpty ? item.time : 'TBA';
      final room = item.room.isNotEmpty ? ' @ ${item.room}' : '';
      return '${item.subject}$room - $time';
    }).join('\n');

    await _plugin.zonedSchedule(
      1001,
      "Tomorrow's Schedule",
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
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static List<String> _extractDayTokens(String time) {
    return time
        .toUpperCase()
        .split(RegExp(r'[,/\s]+'))
        .where((t) => t.isNotEmpty)
        .toList();
  }

  static final _dayTokenMap = {
    'MON': 'mon', 'MONDAY': 'mon',
    'TUE': 'tue', 'TUES': 'tue', 'TUESDAY': 'tue',
    'WED': 'wed', 'WEDNESDAY': 'wed',
    'THU': 'thu', 'THUR': 'thu', 'THURS': 'thu', 'THURSDAY': 'thu',
    'FRI': 'fri', 'FRIDAY': 'fri',
    'SAT': 'sat', 'SATURDAY': 'sat',
    'SUN': 'sun', 'SUNDAY': 'sun',
  };

  static List<ScheduleItem> getTodayClasses(List<ScheduleItem> schedule, {DateTime? referenceDate}) {
    final date = referenceDate ?? DateTime.now();
    final dayOfWeek = date.weekday;
    final todayCode = switch (dayOfWeek) {
      1 => 'mon',
      2 => 'tue',
      3 => 'wed',
      4 => 'thu',
      5 => 'fri',
      6 => 'sat',
      7 => 'sun',
      _ => '',
    };

    return schedule.where((item) {
      final tokens = _extractDayTokens(item.time);
      return tokens.any((token) => _dayTokenMap[token] == todayCode);
    }).toList();
  }
}
