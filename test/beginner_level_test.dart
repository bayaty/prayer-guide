// The beginner path: what someone sees before they have memorised the Arabic.
//
// Two modes now swap steps rather than only hiding them, so the risk is a
// prayer that is wrong in one mode: a beginner shown nothing where the
// recitation belongs, or a learner shown the simplified stand-in beside the
// full wording it replaces. These tests read the actual step lists.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prayer_guide/data/app_settings.dart';
import 'package:prayer_guide/data/practice_mode.dart';
import 'package:prayer_guide/data/prayer_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.load();
  });

  List<PrayerStep> stepsFor(Prayer prayer, {required bool complete}) {
    return prayer.steps
        .where((s) => complete
            ? s.level != StepLevel.beginner
            : s.level == StepLevel.essential || s.level == StepLevel.beginner)
        .toList();
  }

  Prayer named(String name) => prayers.firstWhere((p) => p.name == name);

  group('the two modes never overlap', () {
    test('a beginner step never appears in complete mode', () {
      for (final p in prayers) {
        final complete = stepsFor(p, complete: true);
        expect(
          complete.where((s) => s.level == StepLevel.beginner),
          isEmpty,
          reason: '${p.name} shows a simplified stand-in in complete mode',
        );
      }
    });

    test('the full wording never appears in starting-out mode', () {
      for (final p in prayers) {
        final beginner = stepsFor(p, complete: false);
        expect(
          beginner.where((s) => s.level == StepLevel.learning),
          isEmpty,
          reason: '${p.name} shows the full wording to a beginner',
        );
      }
    });

    test('every prayer has steps in both modes', () {
      for (final p in prayers) {
        expect(stepsFor(p, complete: false), isNotEmpty, reason: p.name);
        expect(stepsFor(p, complete: true), isNotEmpty, reason: p.name);
      }
    });
  });

  group('the standing recitation', () {
    test('a beginner gets the praise line, not silence', () {
      final steps = stepsFor(named('Fajr'), complete: false);
      final praise = steps.where((s) => s.title.startsWith('Praise Allah'));
      expect(praise, hasLength(2), reason: 'once per round of Fajr');
    });

    test('a beginner is not shown the full Fatiha', () {
      final steps = stepsFor(named('Fajr'), complete: false);
      expect(
        steps.where((s) => s.title.startsWith('Recite the Opening')),
        isEmpty,
      );
    });

    test('complete mode keeps Al-Fatiha in every round', () {
      // The count must equal the number of rounds. This is the assertion that
      // catches the positional-removal bug, where inserting a step above made
      // removeAt(3) delete Al-Fatiha from later rounds instead of the
      // optional short chapter.
      for (final p in prayers) {
        final steps = stepsFor(p, complete: true);
        final fatiha =
            steps.where((s) => s.title.startsWith('Recite the Opening'));
        expect(fatiha, hasLength(p.rakatCount),
            reason: '${p.name} must recite Al-Fatiha in all '
                '${p.rakatCount} rounds');
      }
    });

    test('the short chapter stays in the first two rounds only', () {
      for (final p in prayers) {
        final steps = stepsFor(p, complete: true);
        final short = steps.where((s) => s.title.startsWith('Recite a Short'));
        expect(short, hasLength(2), reason: p.name);
      }
    });
  });

  group('the sittings', () {
    test('a beginner sits with takbir instead of the testification', () {
      final steps = stepsFor(named('Fajr'), complete: false);
      expect(
        steps.where((s) => s.title.contains('Testification')),
        isEmpty,
        reason: 'the testification belongs to complete mode',
      );
      expect(
        steps.where((s) => s.transliteration == 'Allahu Akbar' &&
            s.title.startsWith('Sitting')),
        isNotEmpty,
      );
    });

    test('complete mode teaches the testification', () {
      final steps = stepsFor(named('Fajr'), complete: true);
      expect(
        steps.where((s) => s.title.contains('Testification')),
        isNotEmpty,
      );
    });

    test('four-round prayers sit twice', () {
      final steps = stepsFor(named('Dhuhr'), complete: true);
      final sittings = steps.where((s) => s.title.contains('Testification'));
      expect(sittings, hasLength(2), reason: 'middle and final sitting');
    });
  });

  group('the closing peace', () {
    test('a beginner still says the salam in full', () {
      // The one part not simplified: it is short, and it is what actually
      // ends the prayer.
      final steps = stepsFor(named('Fajr'), complete: false);
      final closing = steps.last;
      expect(closing.transliteration, contains('As-salamu alaikum'));
    });

    test('a beginner is not asked for the blessings', () {
      final steps = stepsFor(named('Fajr'), complete: false);
      expect(
        steps.where((s) => s.title.contains('Blessings')),
        isEmpty,
      );
    });

    test('the prayer ends with the peace in both modes', () {
      for (final p in prayers) {
        for (final complete in [true, false]) {
          final steps = stepsFor(p, complete: complete);
          expect(steps.last.transliteration, contains('salamu alaikum'),
              reason: '${p.name} (complete: $complete) must end with salam');
        }
      }
    });

    test('turning right then left is spelled out', () {
      for (final p in prayers) {
        for (final complete in [true, false]) {
          final last = stepsFor(p, complete: complete).last;
          expect(last.instruction.toLowerCase(), contains('right'));
          expect(last.instruction.toLowerCase(), contains('left'));
        }
      }
    });
  });

  group('beginner steps say what they are standing in for', () {
    test('each names the fuller practice it replaces', () {
      // Scaffolding that does not admit it is scaffolding leaves someone
      // believing the simplified prayer is the finished one.
      final beginnerSteps = <PrayerStep>[];
      for (final p in prayers) {
        beginnerSteps.addAll(
          p.steps.where((s) => s.level == StepLevel.beginner),
        );
      }
      expect(beginnerSteps, isNotEmpty);

      for (final s in beginnerSteps) {
        final text = '${s.instruction} ${s.info}'.toLowerCase();
        final admits = text.contains('learn') ||
            text.contains('while you') ||
            text.contains('complete steps') ||
            text.contains('starting point');
        expect(admits, isTrue,
            reason: '"${s.title}" should say it is a step on the way');
      }
    });
  });

  group('PracticeMode.shows agrees with the mode', () {
    test('starting out keeps essentials and stand-ins', () {
      PracticeMode.instance.extraSunnahs = false;
      expect(PracticeMode.instance.shows(StepLevel.essential), isTrue);
      expect(PracticeMode.instance.shows(StepLevel.beginner), isTrue);
      expect(PracticeMode.instance.shows(StepLevel.learning), isFalse);
      expect(PracticeMode.instance.shows(StepLevel.sunnah), isFalse);
    });

    test('complete keeps everything but the stand-ins', () {
      PracticeMode.instance.extraSunnahs = true;
      expect(PracticeMode.instance.shows(StepLevel.essential), isTrue);
      expect(PracticeMode.instance.shows(StepLevel.learning), isTrue);
      expect(PracticeMode.instance.shows(StepLevel.sunnah), isTrue);
      expect(PracticeMode.instance.shows(StepLevel.beginner), isFalse);
    });
  });
}
