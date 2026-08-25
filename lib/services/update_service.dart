import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Result of an update check.
class UpdateInfo {
  final String currentVersion;
  final String? latestVersion;
  final String? apkUrl;
  final String? releaseNotes;
  final bool updateAvailable;
  final String? error;

  const UpdateInfo({
    required this.currentVersion,
    this.latestVersion,
    this.apkUrl,
    this.releaseNotes,
    this.updateAvailable = false,
    this.error,
  });
}

/// Checks GitHub Releases for a newer APK and installs it.
///
/// Expects releases tagged like `v1.0.1` with an `.apk` asset attached.
class UpdateService {
  /// GitHub `owner/repo` to check for releases.
  static const String repo = 'bayaty/prayer-guide';

  static Uri get _latestReleaseUrl =>
      Uri.parse('https://api.github.com/repos/$repo/releases/latest');

  /// Compares dotted version strings: returns true if [remote] > [local].
  static bool isNewer(String remote, String local) {
    List<int> parse(String v) => v
        .replaceAll(RegExp(r'^v', caseSensitive: false), '')
        .split('+')
        .first
        .split('.')
        .map((p) => int.tryParse(p.trim()) ?? 0)
        .toList();

    final r = parse(remote);
    final l = parse(local);
    final len = r.length > l.length ? r.length : l.length;

    for (var i = 0; i < len; i++) {
      final rv = i < r.length ? r[i] : 0;
      final lv = i < l.length ? l[i] : 0;
      if (rv != lv) return rv > lv;
    }
    return false;
  }

  /// Queries GitHub for the latest release and compares it to this build.
  static Future<UpdateInfo> check() async {
    final info = await PackageInfo.fromPlatform();
    final current = info.version;

    try {
      final res = await http.get(
        _latestReleaseUrl,
        headers: {'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode == 404) {
        return UpdateInfo(
          currentVersion: current,
          error: 'No published releases found for $repo.',
        );
      }
      if (res.statusCode != 200) {
        return UpdateInfo(
          currentVersion: current,
          error: 'GitHub returned HTTP ${res.statusCode}.',
        );
      }

      final data = json.decode(res.body) as Map<String, dynamic>;
      final tag = (data['tag_name'] ?? '') as String;
      final notes = data['body'] as String?;

      final assets = (data['assets'] as List<dynamic>? ?? []);
      String? apkUrl;
      for (final a in assets) {
        final name = (a['name'] ?? '') as String;
        if (name.toLowerCase().endsWith('.apk')) {
          apkUrl = a['browser_download_url'] as String?;
          break;
        }
      }

      final newer = tag.isNotEmpty && isNewer(tag, current);

      return UpdateInfo(
        currentVersion: current,
        latestVersion: tag.isEmpty ? null : tag,
        apkUrl: apkUrl,
        releaseNotes: notes,
        updateAvailable: newer && apkUrl != null,
        error: newer && apkUrl == null
            ? 'Release $tag has no .apk asset attached.'
            : null,
      );
    } on SocketException {
      return UpdateInfo(
        currentVersion: current,
        error: 'No internet connection.',
      );
    } catch (e) {
      return UpdateInfo(currentVersion: current, error: '$e');
    }
  }

  /// Downloads the APK, reporting progress 0.0 to 1.0, then opens the installer.
  static Future<String?> downloadAndInstall(
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final client = http.Client();
      final req = http.Request('GET', Uri.parse(url));
      final res = await client.send(req);

      if (res.statusCode != 200) {
        client.close();
        return 'Download failed: HTTP ${res.statusCode}';
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/prayer-guide-update.apk');
      final sink = file.openWrite();

      final total = res.contentLength ?? 0;
      var received = 0;

      await for (final chunk in res.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
      }

      await sink.close();
      client.close();

      // Hands off to the Android package installer.
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        return 'Could not open installer: ${result.message}';
      }
      return null;
    } catch (e) {
      return '$e';
    }
  }
}
