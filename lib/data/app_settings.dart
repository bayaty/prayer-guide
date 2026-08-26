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
  static const _kShowArabic = 'show_arabic';
  static const _kShowTransliteration = 'show_transliteration';
  static const _kShowTranslation = 'show_translation';

  SharedPreferences? _prefs;

  bool _extraSunnahs = true;
  bool _showArabic = true;
  bool _showTransliteration = true;
  bool _showTranslation = true;

  bool get extraSunnahs => _extraSunnahs;

  /// Whether the Arabic text is shown on a step.
  bool get showArabic => _showArabic;

  /// Whether the transliteration is shown on a step.
  bool get showTransliteration => _showTransliteration;

  /// Whether the English translation is shown on a step.
  bool get showTranslation => _showTranslation;

  /// True when all three are hidden, so a step shows no supplication text.
  bool get hideAllText =>
      !_showArabic && !_showTransliteration && !_showTranslation;


  /// True once [load] has finished reading from disk.
  bool get isLoaded => _prefs != null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    _extraSunnahs = prefs.getBool(_kExtraSunnahs) ?? true;
    _showArabic = prefs.getBool(_kShowArabic) ?? true;
    _showTransliteration = prefs.getBool(_kShowTransliteration) ?? true;
    _showTranslation = prefs.getBool(_kShowTranslation) ?? true;
    notifyListeners();
  }

  Future<void> setExtraSunnahs(bool value) async {
    if (_extraSunnahs == value) return;
    _extraSunnahs = value;
    notifyListeners();
    await _prefs?.setBool(_kExtraSunnahs, value);
  }

  Future<void> setShowArabic(bool value) async {
    if (_showArabic == value) return;
    _showArabic = value;
    notifyListeners();
    await _prefs?.setBool(_kShowArabic, value);
  }

  Future<void> setShowTransliteration(bool value) async {
    if (_showTransliteration == value) return;
    _showTransliteration = value;
    notifyListeners();
    await _prefs?.setBool(_kShowTransliteration, value);
  }

  Future<void> setShowTranslation(bool value) async {
    if (_showTranslation == value) return;
    _showTranslation = value;
    notifyListeners();
    await _prefs?.setBool(_kShowTranslation, value);
  }

}
