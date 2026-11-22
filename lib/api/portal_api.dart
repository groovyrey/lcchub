import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/models.dart';

class PortalApi {
  static String _baseUrl = 'https://www.lccianhub.me';
  static Map<String, String> _cookies = {};
  static String _lastUserId = '';
  static String _lastPassword = '';
  static dynamic _storage;

  static void init(String url, [dynamic storage]) {
    _baseUrl = url;
    _storage = storage;
    if (_storage != null) {
      _cookies = Map<String, String>.from(_storage.cookies);
    }
  }

  static String get baseUrl => _baseUrl;

  static Map<String, String> _headers() {
    final cookieStr = _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (cookieStr.isNotEmpty) 'Cookie': cookieStr,
    };
  }

  static void _updateCookies(http.Response response) {
    final setCookieHeader = response.headers['set-cookie'];
    if (setCookieHeader == null) return;

    final cookieStrings = _splitSetCookieHeaders(setCookieHeader);

    for (final raw in cookieStrings) {
      final trimmed = raw.trim();
      final eqIdx = trimmed.indexOf('=');
      if (eqIdx > 0) {
        final key = trimmed.substring(0, eqIdx).trim();
        final rest = trimmed.substring(eqIdx + 1);
        final semiIdx = rest.indexOf(';');
        final value = (semiIdx > 0 ? rest.substring(0, semiIdx) : rest).trim();
        if (key.isNotEmpty) {
          _cookies[key] = value;
        }
      }
    }
    _persistCookies();
  }

  static void _persistCookies() {
    if (_storage != null) {
      _storage.cookies = Map<String, String>.from(_cookies);
    }
  }

  static List<String> _splitSetCookieHeaders(String header) {
    // Split on ", " but only when not inside quotes
    final result = <String>[];
    final current = StringBuffer();
    var inQuotes = false;
    var i = 0;
    while (i < header.length) {
      final ch = header[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
        current.write(ch);
      } else if (ch == ',' && !inQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(ch);
      }
      i++;
    }
    if (current.isNotEmpty) result.add(current.toString());
    return result;
  }

  static void clearSession() {
    _cookies.clear();
    _persistCookies();
    _lastUserId = '';
    _lastPassword = '';
  }

  static Future<Map<String, dynamic>> login(String userId, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/student/login'),
        headers: _headers(),
        body: jsonEncode({'userId': userId, 'password': password}),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        _lastUserId = userId;
        _lastPassword = password;
        return {'success': true, 'data': Student.fromJson(data['data']), 'isNewUser': data['isNewUser'] ?? false};
      }
      return {'success': false, 'error': data['error'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Student?> getMe() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/student/me'),
        headers: _headers(),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return Student.fromJson(data['data']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/student/profile?id=$userId'),
        headers: _headers(),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> uploadAvatar(
      Uint8List bytes, {
      String filename = 'avatar.jpg',
      String mimeType = 'image/jpeg',
    }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/cloudinary/upload'),
      );
      final cookieStr = _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
      if (cookieStr.isNotEmpty) request.headers['Cookie'] = cookieStr;
      request.headers['Accept'] = 'application/json';
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      _updateCookies(response);
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['url'] != null) {
        return data['url'] as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> updateProfilePhoto(String? url) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/student/profile'),
        headers: _headers(),
        body: jsonEncode({'profilePhotoUrl': url}),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getGrades(String href, {String? reportName}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/student/grades'),
        headers: _headers(),
        body: jsonEncode({
          'href': href,
          'userId': _lastUserId,
          'password': _lastPassword,
          if (reportName != null) 'reportName': reportName,
        }),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return {
          'success': true,
          'subjects': (data['subjects'] as List?)?.map((e) => SubjectGrade.fromJson(e)).toList() ?? [],
        };
      }
      return {'success': false, 'error': data['error']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/student/notifications'),
        headers: _headers(),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return (data['notifications'] as List?)?.map((e) => AppNotification.fromJson(e)).toList() ?? [];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> markNotificationRead(String id) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/student/notifications'),
        headers: _headers(),
        body: jsonEncode({'id': id, 'action': 'markRead'}),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> markAllNotificationsRead() async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/student/notifications'),
        headers: _headers(),
        body: jsonEncode({'action': 'markAllRead'}),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteNotification(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/student/notifications'),
        headers: _headers(),
        body: jsonEncode({'id': id, 'action': 'delete'}),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> clearAllNotifications() async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/student/notifications'),
        headers: _headers(),
        body: jsonEncode({'action': 'clearAll'}),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> registerDeviceToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/student/notifications'),
        headers: _headers(),
        body: jsonEncode({'action': 'registerDevice', 'token': token}),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateSettings(Map<String, dynamic> settings) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/student/settings'),
        headers: _headers(),
        body: jsonEncode({'settings': settings}),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> syncGrades(List<ReportLink> reports) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/student/grades'),
        headers: _headers(),
        body: jsonEncode({
          'refresh': true,
          'reports': reports
              .map((report) => {'href': report.href, 'reportName': report.text})
              .toList(),
        }),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      if (data['success'] != true) {
        return {'success': false, 'error': data['error']};
      }

      final grades = <String, List<SubjectGrade>>{};
      for (final entry in data['reports'] ?? const []) {
        final reportName = entry['report']?.toString() ?? '';
        final matching = reports.where((report) => report.text == reportName);
        final href = matching.isNotEmpty ? matching.first.href : reportName;
        grades[href] = (entry['subjects'] as List?)
                ?.map((subject) => SubjectGrade.fromJson(
                      Map<String, dynamic>.from(subject as Map)..['semester'] = reportName,
                    ))
                .toList() ??
            const <SubjectGrade>[];
      }
      return {'success': true, 'grades': grades};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
