import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
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

  static Future<CommunityPostsResponse> getCommunityPosts({
    String? topic,
    String? search,
    String? userId,
    String sort = 'recent',
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final params = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
        'sort': sort,
      };
      if (topic != null && topic.isNotEmpty) params['topic'] = topic;
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (userId != null && userId.isNotEmpty) params['userId'] = userId;

      final uri = Uri.parse('$_baseUrl/api/community').replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers());
      _updateCookies(response);
      final data = jsonDecode(response.body);
      return CommunityPostsResponse.fromJson(data);
    } catch (_) {
      return CommunityPostsResponse();
    }
  }

  static Future<Map<String, dynamic>> getPostDetail(String postId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/community').replace(queryParameters: {'postId': postId});
      final response = await http.get(uri, headers: _headers());
      _updateCookies(response);
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return {
          'success': true,
          'post': data['post'] != null ? CommunityPost.fromJson(data['post']) : null,
          'comments': <CommunityComment>[],
        };
      }
      return {'success': false, 'error': data['error']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getPostComments(String postId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/community/comments').replace(queryParameters: {'postId': postId});
      final response = await http.get(uri, headers: _headers());
      _updateCookies(response);
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return {
          'success': true,
          'comments': (data['comments'] as List?)?.map((e) => CommunityComment.fromJson(e)).toList() ?? [],
        };
      }
      return {'success': false, 'error': data['error']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createPost(String content, {String? topic, bool isAnonymous = false, Map<String, dynamic>? poll}) async {
    try {
      final body = <String, dynamic>{
        'content': content,
        'topic': topic,
        'isAnonymous': isAnonymous,
      };
      if (poll != null) body['poll'] = poll;
      final response = await http.post(
        Uri.parse('$_baseUrl/api/community'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      return {'success': data['success'] ?? false, 'error': data['error']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addComment(String postId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/community/comments'),
        headers: _headers(),
        body: jsonEncode({'postId': postId, 'content': content}),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      return {'success': data['success'] ?? false, 'error': data['error']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<void> likePost(String postId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/community'),
        headers: _headers(),
        body: jsonEncode({'postId': postId, 'action': 'like'}),
      );
      _updateCookies(response);
    } catch (_) {}
  }

  static Future<void> unlikePost(String postId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/community'),
        headers: _headers(),
        body: jsonEncode({'postId': postId, 'action': 'unlike'}),
      );
      _updateCookies(response);
    } catch (_) {}
  }

  static Future<bool> votePoll(String postId, int optionIndex) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/community'),
        headers: _headers(),
        body: jsonEncode({'postId': postId, 'action': 'vote', 'optionIndex': optionIndex}),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deletePost(String postId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/community'),
        headers: _headers(),
        body: jsonEncode({'postId': postId}),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteComment(String commentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/community/comments?id=$commentId'),
        headers: _headers(),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> reportPost(String postId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/community/report'),
        headers: _headers(),
        body: jsonEncode({'postId': postId}),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      return {'success': data['success'] ?? false, 'decision': data['decision'], 'reason': data['reason']};
    } catch (_) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> reportComment(String commentId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/community/comments/report'),
        headers: _headers(),
        body: jsonEncode({'commentId': commentId}),
      );
      _updateCookies(response);
      final data = jsonDecode(response.body);
      return {'success': data['success'] ?? false, 'decision': data['decision'], 'reason': data['reason']};
    } catch (_) {
      return {'success': false};
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

  static Stream<String> chatStream(List<Map<String, String>> messages) async* {
    final request = http.Request('POST', Uri.parse('$_baseUrl/api/ai/assistant'));
    request.headers.addAll(_headers());
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({'messages': messages});

    final streamedResponse = await http.Client().send(request);
    _updateCookies(http.Response('', streamedResponse.statusCode, headers: streamedResponse.headers));

    final buffer = StringBuffer();
    var inThoughtBlock = false;
    var yieldedLen = 0;

    await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
      for (final line in chunk.split('\n')) {
        if (line.isEmpty) continue;

        final trimmed = line.trim();
        if (trimmed.startsWith('STATUS:')) {
          yield trimmed;
          continue;
        }
        if (trimmed.startsWith('TOOL_USED:')) {
          yield trimmed;
          continue;
        }

        buffer.write(line);
        final text = buffer.toString();

        final lastOpen = text.lastIndexOf('<thought>');
        final lastClose = text.lastIndexOf('</thought>');

        if (lastOpen > lastClose) {
          inThoughtBlock = true;
          continue;
        }

        inThoughtBlock = false;
        final cleaned = text.replaceAll(
          RegExp(r'<thought>[\s\S]*?</thought>', dotAll: true), '');

        if (cleaned.length > yieldedLen) {
          final newPart = cleaned.substring(yieldedLen);
          yieldedLen = cleaned.length;
          if (newPart.trim().isNotEmpty) {
            yield newPart;
          }
        }
      }
    }
  }
}
