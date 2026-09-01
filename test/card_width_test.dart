import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_guide/data/app_settings.dart';
import 'package:prayer_guide/data/practice_mode.dart';
import 'package:prayer_guide/data/prayer_data.dart';
import 'package:prayer_guide/screens/prayer_screen.dart';
import 'package:prayer_guide/widgets/step_detail_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Step 1 is the only card with no instruction text. The card's width used to
/// come from the instruction Container being width: double.infinity, so the
/// intention had nothing forcing it wide and rendered as a narrow box beside
/// full width neighbours.
void main() {
  testWidgets('every step card is the same width', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.load();
    PracticeMode.instance.extraSunnahs = false;

    tester.view.physicalSize = const Size(1200, 30000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
        MaterialApp(home: PrayerScreen(prayer: prayers.first)));
    await tester.pumpAndSettle();

    final cards = find.byType(StepDetailCard);
    expect(cards, findsWidgets);

    final widths = <double>[];
    for (var i = 0; i < cards.evaluate().length; i++) {
      widths.add(tester.getSize(cards.at(i)).width);
    }

    // The intention (step 1) carries no instruction; it must still match.
    final first = widths.first;
    for (final w in widths) {
      expect(w, closeTo(first, 0.5),
          reason: 'card widths differ: $widths');
    }
  });
}
