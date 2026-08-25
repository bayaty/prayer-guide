import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App preferences that survive a restart.
///
/// Backed by shared_preferences. Call [load] once during startup before
/// running the app so the first frame already reflects the saved choice.
class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  static const _kExtraSunnahs = 'extra_sunnahs';

  SharedPreferences? _prefs;

  bool _extraSunnahs = true;

  bool get extraSunnahs => _extraSunnahs;


  /// True once [load] has finished reading from disk.
  bool get isLoaded => _prefs != null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    _extraSunnahs = prefs.getBool(_kExtraSunnahs) ?? true;
    notifyListeners();
  }

  Future<void> setExtraSunnahs(bool value) async {
    if (_extraSunnahs == value) return;
    _extraSunnahs = value;
    notifyListeners();
    await _prefs?.setBool(_kExtraSunnahs, value);
  }

}
