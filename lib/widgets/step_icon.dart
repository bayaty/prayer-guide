import 'package:flutter/material.dart';

/// Renders a step icon.
///
/// Body-posture emoji (standing, bowing, kneeling, open hands) render with
/// faces and skin tones that vary by device, so those are drawn from faceless
/// generated assets instead. Everything else falls back to the emoji itself.
class StepIcon extends StatelessWidget {
  final String icon;
  final double size;

  const StepIcon(this.icon, {super.key, this.size = 24});

  /// Generated posture art sits inside a round backdrop with padding, so it
  /// reads smaller than an emoji at the same box size. Scale the assets up to
  /// compensate; emoji keep their original size.
  static const double assetScale = 1.75;

  /// Emoji that depict a human body, mapped to a faceless asset.
  static const Map<String, String> _assetForEmoji = {
    '🧍': 'standing',
    '🙇': 'bowing',
    '🤲': 'hands',
    '🧎': 'sitting',
    '🕌': 'standing',
  };

  /// Posture assets keyed by name, for direct use.
  static String pathFor(String name) => 'assets/postures/$name.png';

  @override
  Widget build(BuildContext context) {
    // Explicit form: `posture:<name>` names an asset directly, for postures
    // that have no distinct emoji (prostration reuses the open-hands emoji).
    final explicit =
        icon.startsWith('posture:') ? icon.substring('posture:'.length) : null;
    final asset = explicit ?? _assetForEmoji[icon];

    if (asset != null) {
      return Image.asset(
        pathFor(asset),
        width: size * assetScale,
        height: size * assetScale,
        // If an asset is ever missing, show something readable rather than a
        // broken-image box.
        errorBuilder: (_, _, _) => Text(
          explicit != null ? '🤲' : icon,
          style: TextStyle(fontSize: size * 0.85),
        ),
      );
    }
    return Text(icon, style: TextStyle(fontSize: size * 0.85));
  }
}
