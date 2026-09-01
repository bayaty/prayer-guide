import 'package:flutter/material.dart';

/// A [FlexibleSpaceBar] title that stays hidden until the header is nearly
/// collapsed.
///
/// FlexibleSpaceBar draws its title at every scroll position, sliding it down
/// over the background as the header expands. With a subtitle in that
/// background the two print on top of each other, which is exactly what
/// happened on the wudu header: "Wudu" landed on "Purify Yourself Before
/// Prayer".
///
/// A fixed spacer does not fix it. On a short, wide window the header opens
/// only partway, so the gap the spacer reserved is never there. Fading on the
/// actual collapse fraction works at any viewport, which is what the web app
/// needs.
class CollapsingTitle extends StatelessWidget {
  final Widget child;

  const CollapsingTitle({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

    var opacity = 1.0;
    if (settings != null) {
      final range = settings.maxExtent - settings.minExtent;
      if (range > 0) {
        // 0 when fully expanded, 1 when fully collapsed.
        final collapsed =
            ((settings.maxExtent - settings.currentExtent) / range)
                .clamp(0.0, 1.0);
        // Hold back until the header is most of the way closed, then fade in
        // quickly, so the title and the subtitle never share the space.
        opacity = ((collapsed - 0.7) / 0.25).clamp(0.0, 1.0);
      }
    }

    if (opacity == 0) return const SizedBox.shrink();
    return Opacity(opacity: opacity, child: child);
  }
}
