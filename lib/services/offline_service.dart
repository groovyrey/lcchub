import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class OfflineService {
  static const _keyGrades = 'cached_grades';
  static const _keyLastGradesUpdate = 'last_grades_update';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Grades cache ──────────────────────────────────────────────────

  Map<String, List<SubjectGrade>> get cachedGrades {
    final json = _prefs.getString(_keyGrades);
    if (json == null) return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((key, value) {
        final list = (value as List).map((e) => SubjectGrade.fromJson(e)).toList();
        return MapEntry(key, list);
      });
    } catch (_) {
      return {};
    }
  }

  void saveGrades(Map<String, List<SubjectGrade>> grades) {
    final json = grades.map((key, value) {
      return MapEntry(key, value.map((g) => {
        'code': g.code,
        'description': g.description,
        'section': g.section,
        'grade': g.grade,
        'units': g.units,
        'remarks': g.remarks,
      }).toList());
    });
    _prefs.setString(_keyGrades, jsonEncode(json));
    _prefs.setString(_keyLastGradesUpdate, DateTime.now().toIso8601String());
  }

  DateTime? get lastGradesUpdate {
    final s = _prefs.getString(_keyLastGradesUpdate);
    return s != null ? DateTime.tryParse(s) : null;
  }
}
