import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prayer_guide/data/practice_mode.dart';
import 'package:prayer_guide/data/prayer_data.dart';
import 'package:prayer_guide/data/wudu_data.dart';
import 'package:prayer_guide/widgets/practice_mode_toggle.dart';

void main() {
  // The mode is a shared singleton, so restore the default after each test.
  tearDown(() => PracticeMode.instance.extraSunnahs = true);

  test('the title changes with the mode', () {
    final mode = PracticeMode.instance;

    mode.extraSunnahs = true;
    expect(mode.title, 'Complete Steps');

    mode.extraSunnahs = false;
    expect(mode.title, 'Starting Out');
  });

  test('bare minimum removes sunnah wudu steps', () {
    final mode = PracticeMode.instance;

    mode.extraSunnahs = true;
    final full = mode.filter<WuduStep>(wuduSteps, (s) => s.level);
    expect(full.length, wuduSteps.length);

    mode.extraSunnahs = false;
    final minimal = mode.filter<WuduStep>(wuduSteps, (s) => s.level);
    expect(minimal.length, lessThan(full.length));

    // The four Quranic obligations must survive.
    final titles = minimal.map((s) => s.title).toList();
    expect(titles, contains('Wash the Face'));
    expect(titles, contains('Wash the Arms (include elbows)'));
    expect(titles, contains('Wipe the Head'));
    expect(titles, contains('Wash the Feet (include ankles)'));

    // The intention is sunnah in the Hanafi school, so bare minimum drops
    // it. It is fard in the Shafi'i school, which is why the card names
    // the school rather than presenting this as universal.
    expect(titles.any((t) => t == 'Intention'), isFalse);

    // Sunnah acts should be gone.
    expect(titles, isNot(contains('Rinse the Mouth')));
    expect(titles, isNot(contains('Wipe the Ears')));
  });

  test('starting out simplifies the wording but keeps every posture', () {
    final mode = PracticeMode.instance;
    final fajr = prayers.first;

    mode.extraSunnahs = false;
    final minimal = mode.filter<PrayerStep>(fajr.steps, (s) => s.level);
    final titles = minimal.map((s) => s.title).toList();

    expect(minimal.length, lessThan(fajr.steps.length));

    // Every posture remains; only the words change.
    expect(titles.any((t) => t.contains('Bowing')), isTrue);
    expect(titles.any((t) => t.contains('Prostration')), isTrue);

    // The full Arabic is replaced by the simplified stand-ins.
    expect(titles.any((t) => t.contains('Recite the Opening Chapter')), isFalse,
        reason: 'the full chapter belongs to complete mode');
    expect(titles.any((t) => t.contains('Praise Allah')), isTrue,
        reason: 'a beginner still recites something while standing');
    expect(titles.any((t) => t.contains('Sitting Testification')), isFalse);
    expect(titles.any((t) => t.startsWith('Sitting (')), isTrue,
        reason: 'the sitting is occupied with takbir instead');

    // Sunnah additions are dropped in both cases.
    expect(titles.any((t) => t.contains('Opening Supplication')), isFalse);
    expect(titles.any((t) => t.contains('Short Chapter')), isFalse);
  });

  test('every prayer keeps a standing recitation in starting-out mode', () {
    PracticeMode.instance.extraSunnahs = false;
    for (final p in prayers) {
      final minimal =
          PracticeMode.instance.filter<PrayerStep>(p.steps, (s) => s.level);
      expect(minimal, isNotEmpty, reason: '${p.name} lost every step');
      expect(minimal.any((s) => s.title.contains('Praise Allah')), isTrue,
          reason: '${p.name} has nothing to recite while standing');
      expect(minimal.last.title, contains('Closing Peace'),
          reason: '${p.name} must still end with the closing greeting');
    }
  });

  testWidgets('the toggle switches the label and the count', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PracticeModeToggle(visibleCount: 10, totalCount: 10),
        ),
      ),
    );

    expect(find.text('Complete Steps'), findsOneWidget);
    expect(find.text('10 of 10 steps'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Starting Out'), findsOneWidget);
    expect(find.text('Complete Steps'), findsNothing);
  });

  test('toggling notifies listeners exactly once per change', () {
    final mode = PracticeMode.instance;
    var calls = 0;
    void listener() => calls++;

    mode.addListener(listener);
    mode.extraSunnahs = true; // already true, no change
    expect(calls, 0);

    mode.toggle();
    expect(calls, 1);

    mode.toggle();
    expect(calls, 2);

    mode.removeListener(listener);
  });
}
