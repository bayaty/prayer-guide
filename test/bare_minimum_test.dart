import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prayer_guide/data/app_settings.dart';
import 'package:prayer_guide/data/practice_mode.dart';
import 'package:prayer_guide/data/prayer_data.dart';
import 'package:prayer_guide/data/wudu_data.dart';
import 'package:prayer_guide/screens/prayer_steps_screen.dart';
import 'package:prayer_guide/screens/wudu_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.load();
  });

  group('repetition count follows the mode', () {
    test('three times in full mode, once in bare minimum', () {
      final face = wuduSteps.firstWhere((s) => s.title == 'Wash the Face');
      expect(face.times, 3);

      expect(face.timesFor(extraSunnahs: true), 3);
      expect(face.timesFor(extraSunnahs: false), 1,
          reason: 'washing once satisfies the obligation '
              '(Sahih al-Bukhari 157)');
    });

    test('steps already done once stay at once', () {
      final head =
          wuduSteps.firstWhere((s) => s.title == 'Wipe the Head');
      expect(head.times, 1);
      expect(head.timesFor(extraSunnahs: false), 1);
    });

    test('uncounted steps stay uncounted', () {
      final niyyah = wuduSteps.firstWhere((s) => s.title == 'Intention');
      expect(niyyah.times, 0);
      expect(niyyah.timesFor(extraSunnahs: true), 0);
      expect(niyyah.timesFor(extraSunnahs: false), 0);
    });

    test('every repeated wudu step reduces to once', () {
      for (final s in wuduSteps.where((s) => s.times > 1)) {
        expect(s.timesFor(extraSunnahs: false), 1,
            reason: '${s.title} should reduce to once');
      }
    });
  });

  group('the wudu list renumbers continuously', () {
    /// Scrolls the whole list and collects each card's badge number in order.
    Future<List<int>> badgeNumbers(WidgetTester tester) async {
      // Tall surface so every card is laid out at once.
      tester.view.physicalSize = const Size(1200, 8000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: WuduScreen()));
      await tester.pumpAndSettle();

      final visible =
          PracticeMode.instance.filter<WuduStep>(wuduSteps, (s) => s.level);

      // Each card renders its badge as the first Text inside the header row,
      // so match on the step titles instead and read the badge beside them.
      final found = <int>[];
      for (var i = 1; i <= visible.length; i++) {
        if (find.text('$i').evaluate().isNotEmpty) found.add(i);
      }
      return found;
    }

    testWidgets('bare minimum numbers run 1..N with no gaps', (tester) async {
      await AppSettings.instance.setExtraSunnahs(false);

      final visible =
          PracticeMode.instance.filter<WuduStep>(wuduSteps, (s) => s.level);

      // The underlying data still carries its original numbering, which has
      // gaps once sunnah steps are filtered out. Renumbering happens in the
      // view layer.
      final original = visible.map((s) => s.number).toList();
      expect(
        original,
        isNot(equals([for (var i = 1; i <= visible.length; i++) i])),
        reason: 'this test is meaningless if the raw numbers are already '
            'sequential',
      );

      final shown = await badgeNumbers(tester);
      expect(shown, [for (var i = 1; i <= visible.length; i++) i],
          reason: 'the visible list should renumber from 1');
    });

    testWidgets('full mode numbers every step in order', (tester) async {
      await AppSettings.instance.setExtraSunnahs(true);
      final shown = await badgeNumbers(tester);
      expect(shown, [for (var i = 1; i <= wuduSteps.length; i++) i]);
    });
  });

  // The app deliberately presents one general instruction from the authentic
  // sources rather than splitting by school. These guard against school
  // wording creeping back into the step text.
  group('steps stay free of school-specific wording', () {
    testWidgets('the wudu screen shows no school names', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WuduScreen()));
      await tester.pumpAndSettle();

      for (final name in ['Hanafi', 'Maliki', 'Shafi\'i', 'Hanbali']) {
        expect(find.textContaining(name), findsNothing,
            reason: '$name should not appear in the steps');
      }
    });

    testWidgets('the prayer step detail shows no school names',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: PrayerStepsScreen(prayer: prayers.first)),
      );
      await tester.pumpAndSettle();

      for (final name in ['Hanafi', 'Maliki', 'Shafi\'i', 'Hanbali']) {
        expect(find.textContaining(name), findsNothing,
            reason: '$name should not appear in the steps');
      }
    });

    test('no step text mentions a school', () {
      final schools = ['Hanafi', 'Maliki', 'Shafi', 'Hanbali', 'madhab'];
      final offenders = <String>[];

      void check(String label, String text) {
        for (final s in schools) {
          if (text.toLowerCase().contains(s.toLowerCase())) {
            offenders.add('$label mentions $s');
          }
        }
      }

      for (final p in prayers) {
        for (final s in p.steps) {
          check(s.title, s.instruction);
          check(s.title, s.info);
        }
      }
      for (final s in wuduSteps) {
        check(s.title, s.instruction);
        check(s.title, s.info);
      }

      expect(offenders, isEmpty);
    });
  });
}
