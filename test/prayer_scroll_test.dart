import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_guide/data/app_settings.dart';
import 'package:prayer_guide/data/practice_mode.dart';
import 'package:prayer_guide/data/prayer_data.dart';
import 'package:prayer_guide/screens/prayer_screen.dart';
import 'package:prayer_guide/screens/prayer_steps_screen.dart';
import 'package:prayer_guide/widgets/step_detail_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A prayer opens as one continuous scroll: every step written out in full,
/// in order, so a learner can follow the whole prayer without tapping.
///
/// The paged step-by-step guide is still there. Tapping any card opens it at
/// that step, for anyone who would rather take one step at a time.
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.load();
    PracticeMode.instance.extraSunnahs = true;
  });

  Future<void> pumpPrayer(WidgetTester tester, {Prayer? prayer}) async {
    // A SliverList builds lazily, so on the default 800px test surface only
    // the first card exists and any count would measure the viewport rather
    // than the screen. Give it room for the whole list.
    tester.view.physicalSize = const Size(1200, 20000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: PrayerScreen(prayer: prayer ?? prayers.first)),
    );
    await tester.pumpAndSettle();
  }

  group('the prayer list is one continuous read', () {
    testWidgets('every visible step is written out in full', (tester) async {
      await pumpPrayer(tester);

      final visible = PracticeMode.instance
          .filter<PrayerStep>(prayers.first.steps, (s) => s.level);

      expect(
        find.byType(StepDetailCard),
        findsNWidgets(visible.length),
        reason: 'each step should be a full card, not a condensed tile',
      );
    });

    testWidgets('the instruction text is on screen without tapping',
        (tester) async {
      await pumpPrayer(tester);

      // The whole point of the long read: the words are already there.
      final first = PracticeMode.instance
          .filter<PrayerStep>(prayers.first.steps, (s) => s.level)
          .first;
      expect(find.textContaining(first.instruction.split('.').first),
          findsWidgets);
    });

    testWidgets('the heading says All Steps', (tester) async {
      await pumpPrayer(tester);
      expect(find.text('All Steps'), findsOneWidget);
    });

    testWidgets('each card carries its step number', (tester) async {
      await pumpPrayer(tester);

      final visible = PracticeMode.instance
          .filter<PrayerStep>(prayers.first.steps, (s) => s.level);
      // The badge reads "Step 3", not a bare numeral.
      for (var i = 1; i <= visible.length; i++) {
        expect(find.text('Step $i'), findsWidgets, reason: 'step $i badge');
      }
    });

    testWidgets('the numbering has no gaps and matches the visible count',
        (tester) async {
      PracticeMode.instance.extraSunnahs = false;
      await pumpPrayer(tester);

      final visible = PracticeMode.instance
          .filter<PrayerStep>(prayers.first.steps, (s) => s.level);
      final cards = tester.widgetList<StepDetailCard>(
        find.byType(StepDetailCard),
      );

      expect(
        cards.map((c) => c.stepNumber).toList(),
        List.generate(visible.length, (i) => i + 1),
        reason: 'bare minimum must renumber 1..N with no gaps',
      );
    });

    testWidgets('bare minimum still filters the cards', (tester) async {
      PracticeMode.instance.extraSunnahs = true;
      await pumpPrayer(tester);
      final full = tester.widgetList(find.byType(StepDetailCard)).length;

      PracticeMode.instance.extraSunnahs = false;
      await tester.pumpAndSettle();
      final minimal = tester.widgetList(find.byType(StepDetailCard)).length;

      expect(minimal, lessThan(full));
    });

    testWidgets('the text settings still apply inside the cards',
        (tester) async {
      await AppSettings.instance.setShowArabic(false);
      await pumpPrayer(tester);

      final withArabic = prayers.first.steps.firstWhere(
        (s) => s.arabicText.isNotEmpty,
        orElse: () => prayers.first.steps.first,
      );
      if (withArabic.arabicText.isNotEmpty) {
        expect(find.text(withArabic.arabicText), findsNothing);
      }
    });
  });

  group('step by step is still available', () {
    testWidgets('tapping a card opens the paged guide at that step',
        (tester) async {
      await pumpPrayer(tester);

      // Tap the second card, so an index of 0 could not pass by accident.
      await tester.tap(find.byType(StepDetailCard).at(1));
      await tester.pumpAndSettle();

      expect(find.byType(PrayerStepsScreen), findsOneWidget);

      final screen = tester.widget<PrayerStepsScreen>(
        find.byType(PrayerStepsScreen),
      );
      expect(screen.initialStep, 1);
    });

    testWidgets('the paged guide shows one step at a time', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: PrayerStepsScreen(prayer: prayers.first)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StepDetailCard), findsOneWidget);
    });
  });
}
