import 'package:flutter/material.dart';

/// Central palette for Prayer Guide.
///
/// Soft rose / plum / lilac scheme matching the app icon.
/// Change these values to re-theme the whole app.
class AppColors {
  AppColors._();

  /// Deepest tone: headings, selected icons, primary text on light surfaces.
  /// Kept dark enough to stay WCAG-AA legible on white.
  static const Color primary = Color(0xFF7B3F76);

  /// Mid tone: accents, buttons, active indicators.
  static const Color accent = Color(0xFFB05A96);

  /// Brighter rose: highlights, progress, step numbers.
  static const Color highlight = Color(0xFFD07AB0);

  /// Very light blush: tinted card / banner backgrounds.
  static const Color tintBg = Color(0xFFFCEFF7);

  /// Light pink: borders, dividers, inactive track.
  static const Color softPink = Color(0xFFEBC3DF);

  /// Warm off-white: page scaffold background.
  static const Color scaffold = Color(0xFFFAF6FB);

  /// Gradient pair used on header banners (matches the launcher icon).
  static const Color gradientStart = Color(0xFFF5C6E0);
  static const Color gradientEnd = Color(0xFFC6A8F5);
}
