import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class SessionStorage {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyBaseUrl = 'base_url';
  static const _keyStudentData = 'student_data';
  static const _keyStudentId = 'student_id';
  static const _keyRemindersEnabled = 'reminders_enabled';
  static const _keyCookies = 'session_cookies';

  static const defaultBaseUrl = 'https://www.lccianhub.me';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;
  set isLoggedIn(bool value) => _prefs.setBool(_keyIsLoggedIn, value);

  String get baseUrl => _prefs.getString(_keyBaseUrl) ?? defaultBaseUrl;
  set baseUrl(String value) => _prefs.setString(_keyBaseUrl, value);

  Student? get studentData {
    final json = _prefs.getString(_keyStudentData);
    if (json == null) return null;
    try {
      return Student.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  set studentData(Student? value) {
    if (value == null) {
      _prefs.remove(_keyStudentData);
    } else {
      _prefs.setString(_keyStudentData, jsonEncode({
        'name': value.name,
        'id': value.id,
        'course': value.course,
        'email': value.email,
        'address': value.address,
        'mobile': value.mobile,
        'enrollment_date': value.enrollmentDate,
        'schoolYear': value.schoolYear,
        'yearLevel': value.yearLevel,
        'semester': value.semester,
        'section': value.section,
        'schedule': value.schedule?.map((s) => {
          'subject': s.subject, 'description': s.description, 'section': s.section,
          'units': s.units, 'time': s.time, 'room': s.room, 'instructor': s.instructor,
        }).toList(),
        'financials': value.financials != null ? {
          'total': value.financials!.total, 'balance': value.financials!.balance,
          'dueToday': value.financials!.dueToday,
        } : null,
        'availableReports': value.availableReports?.map((r) => {'text': r.text, 'href': r.href}).toList(),
        'settings': value.settings != null ? {
          'notifications': value.settings!.notifications,
          'isPublic': value.settings!.isPublic,
          'showAcademicInfo': value.settings!.showAcademicInfo,
        } : null,
        'badges': value.badges,
      }));
    }
  }

  String get studentId => _prefs.getString(_keyStudentId) ?? '';
  set studentId(String value) => _prefs.setString(_keyStudentId, value);

  bool get remindersEnabled => _prefs.getBool(_keyRemindersEnabled) ?? true;
  set remindersEnabled(bool value) => _prefs.setBool(_keyRemindersEnabled, value);

  Map<String, String> get cookies {
    final json = _prefs.getString(_keyCookies);
    if (json == null) return {};
    try {
      return Map<String, String>.from(jsonDecode(json));
    } catch (_) {
      return {};
    }
  }

  set cookies(Map<String, String> value) {
    if (value.isEmpty) {
      _prefs.remove(_keyCookies);
    } else {
      _prefs.setString(_keyCookies, jsonEncode(value));
    }
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
