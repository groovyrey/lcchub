import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionCheckService {
  static const _owner = 'groovyrey';
  static const _repo = 'lcchub';
  static const _apiUrl = 'https://api.github.com/repos/$_owner/$_repo/releases/latest';

  static Future<VersionInfo?> checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final tagName = data['tag_name'] as String? ?? '';
      final latestVersion = tagName.replaceFirst('v', '');
      final downloadUrl = data['html_url'] as String? ?? '';
      final body = data['body'] as String? ?? '';

      if (_isNewer(latestVersion, currentVersion)) {
        return VersionInfo(
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          downloadUrl: downloadUrl,
          changelog: body,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static bool _isNewer(String latest, String current) {
    final latestParts = latest.split('.').map(int.tryParse).toList();
    final currentParts = current.split('.').map(int.tryParse).toList();

    for (var i = 0; i < 3; i++) {
      final l = i < latestParts.length ? (latestParts[i] ?? 0) : 0;
      final c = i < currentParts.length ? (currentParts[i] ?? 0) : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }
}

class VersionInfo {
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final String changelog;

  const VersionInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.changelog,
  });
}
