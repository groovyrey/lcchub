import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class OfflineService {
  static const _keyGrades = 'cached_grades';
  static const _keyCommunity = 'cached_community';
  static const _keyLastGradesUpdate = 'last_grades_update';
  static const _keyLastCommunityUpdate = 'last_community_update';

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

  // ── Community cache ───────────────────────────────────────────────

  List<CommunityPost> get cachedPosts {
    final json = _prefs.getString(_keyCommunity);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => CommunityPost.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  void savePosts(List<CommunityPost> posts) {
    final json = posts.map((p) => {
      'id': p.id,
      'userId': p.userId,
      'userName': p.userName,
      'content': p.content,
      'topic': p.topic,
      'imageUrl': p.imageUrl,
      'isAnonymous': p.isAnonymous,
      'createdAt': p.createdAt is DateTime
          ? (p.createdAt as DateTime).toIso8601String()
          : p.createdAt?.toString(),
      'likes': p.likes,
      'commentCount': p.commentCount,
      'poll': p.poll != null ? {
        'question': p.poll!.question,
        'options': p.poll!.options.map((o) => {
          'id': o.id,
          'text': o.text,
          'votes': o.votes,
        }).toList(),
      } : null,
    }).toList();
    _prefs.setString(_keyCommunity, jsonEncode(json));
    _prefs.setString(_keyLastCommunityUpdate, DateTime.now().toIso8601String());
  }

  DateTime? get lastCommunityUpdate {
    final s = _prefs.getString(_keyLastCommunityUpdate);
    return s != null ? DateTime.tryParse(s) : null;
  }
}
