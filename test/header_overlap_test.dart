import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_guide/data/app_settings.dart';
import 'package:prayer_guide/screens/wudu_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The header title must never print on top of the subtitle behind it.
///
/// FlexibleSpaceBar draws its title at every scroll position, so on a short
/// window, where the header can only open partway, the title lands on the
/// subtitle. That is what the web app showed at 1280x700: "Wudu" printed
/// across "Purify Yourself Before Prayer".
///
/// A fixed spacer passed at phone height and still failed there, so these
/// cases use the viewport that actually broke.
void main() {
  Future<void> pump(WidgetTester tester, Size size) async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.load();
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: WudaScreenHost()));
    await tester.pumpAndSettle();
  }

  /// Rect of a Text widget by its exact string.
  Rect rectOf(WidgetTester tester, String text) =>
      tester.getRect(find.text(text).first);

  group('the header still shows its name', () {
    for (final size in const [
      Size(1280, 700),
      Size(390, 850),
      Size(1024, 600),
    ]) {
      testWidgets('Wudu is visible at ${size.width.toInt()}x'
          '${size.height.toInt()}', (tester) async {
        await pump(tester, size);

        // Not overlapping is not enough: a hidden title also never overlaps,
        // which is exactly how the title went missing from the open header.
        expect(find.text('Wudu'), findsWidgets,
            reason: 'the header must still name the screen at $size');

        final rect = tester.getRect(find.text('Wudu').first);
        expect(rect.width, greaterThan(0), reason: 'title has no width');
        expect(rect.height, greaterThan(0), reason: 'title has no height');
        expect(rect.top, lessThan(size.height),
            reason: 'title is off screen at $size');
      });
    }
  });

  group('the header title never covers the subtitle', () {
    for (final size in const [
      Size(1280, 700), // the desktop browser window that showed the bug
      Size(390, 850), // a phone
      Size(1024, 600), // a short laptop
    ]) {
      testWidgets('at ${size.width.toInt()}x${size.height.toInt()}',
          (tester) async {
        await pump(tester, size);

        final subtitle = find.text('Purify Yourself Before Prayer');
        expect(subtitle, findsOneWidget);

        // The title is only rendered once the header is mostly collapsed.
        // While the subtitle is on screen expanded, they must not intersect.
        final titleFinder = find.text('Wudu');
        if (titleFinder.evaluate().isEmpty) return;

        final a = rectOf(tester, 'Wudu');
        final b = rectOf(tester, 'Purify Yourself Before Prayer');
        expect(a.overlaps(b), isFalse,
            reason: 'title $a overlaps subtitle $b at $size');
      });
    }
  });
}

/// The wudu screen needs a Scaffold ancestor in isolation.
class WudaScreenHost extends StatelessWidget {
  const WudaScreenHost({super.key});

  @override
  Widget build(BuildContext context) => const WuduScreen();
}
