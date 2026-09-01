import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prayer_guide/data/app_settings.dart';
import 'package:prayer_guide/data/practice_mode.dart';
import 'package:prayer_guide/data/prayer_data.dart';
import 'package:prayer_guide/data/wudu_data.dart';

/// Guards the promise made by the two modes.
///
/// Complete mode must contain every pillar of the prayer. Starting-out mode
/// makes a weaker, deliberate promise: it teaches the shape of the prayer with
/// simplified wording while the Arabic is being learned, so the pillar
/// POSITIONS must all still be there even where the words are stand-ins.
///
/// If a step is ever reclassified by mistake, these fail.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.load();
    await AppSettings.instance.setExtraSunnahs(false);
  });

  tearDown(() => AppSettings.instance.setExtraSunnahs(true));

  List<WuduStep> minimalWudu() =>
      PracticeMode.instance.filter<WuduStep>(wuduSteps, (s) => s.level);

  List<PrayerStep> minimalPrayer(Prayer p) =>
      PracticeMode.instance.filter<PrayerStep>(p.steps, (s) => s.level);

  /// The full practice, as taught once the learner is ready.
  List<PrayerStep> completePrayer(Prayer p) => p.steps
      .where((s) => s.level != StepLevel.beginner)
      .toList();

  group('bare-minimum wudu remains valid', () {
    // The four obligations named in Quran 5:6.
    test('all four Quranic obligations survive', () {
      final titles = minimalWudu().map((s) => s.title).toList();

      expect(titles, contains('Wash the Face'),
          reason: 'washing the face is obligatory (Quran 5:6)');
      expect(titles, contains('Wash the Arms (include elbows)'),
          reason: 'washing the arms to the elbows is obligatory (Quran 5:6)');
      expect(titles, contains('Wipe the Head'),
          reason: 'wiping the head is obligatory (Quran 5:6)');
      expect(titles, contains('Wash the Feet (include ankles)'),
          reason: 'washing the feet to the ankles is obligatory (Quran 5:6)');
    });

    test('the intention is not required', () {
      // Hanafi: the required acts are the four named in Quran 5:6. The
      // intention is sunnah here, though it is fard in the Shafi'i school,
      // so the card names the school rather than stating it universally.
      expect(minimalWudu().any((s) => s.title == 'Intention'), isFalse,
          reason: 'the Hanafi minimum is the four Quranic acts');
    });

    test('the obligations appear in the Quranic order', () {
      final titles = minimalWudu().map((s) => s.title).toList();
      final order = [
        titles.indexWhere((t) => t == 'Wash the Face'),
        titles.indexWhere((t) => t == 'Wash the Arms (include elbows)'),
        titles.indexWhere((t) => t == 'Wipe the Head'),
        titles.indexWhere((t) => t == 'Wash the Feet (include ankles)'),
      ];
      expect(order, orderedEquals([...order]..sort()),
          reason: 'face, arms, head, feet must stay in order');
    });

    test('washing once still satisfies each obligation', () {
      // Sahih al-Bukhari 157 records the Prophet performing wudu washing
      // each part once, so reducing to a single wash stays valid.
      for (final s in minimalWudu()) {
        if (s.times > 0) {
          expect(s.timesFor(extraSunnahs: false), greaterThanOrEqualTo(1),
              reason: '${s.title} must still be performed at least once');
        }
      }
    });

    test('nothing obligatory was classified as sunnah', () {
      const obligatory = [
        'Wash the Face',
        'Wash the Arms (include elbows)',
        'Wipe the Head',
        'Wash the Feet (include ankles)',
      ];
      for (final title in obligatory) {
        final step = wuduSteps.firstWhere((s) => s.title == title);
        expect(step.level, StepLevel.essential,
            reason: '$title must never be filtered out');
      }
    });
  });

  group('bare-minimum prayer remains valid', () {
    test('the intention is present, first, and names the prayer', () {
      for (final p in prayers) {
        final steps = minimalPrayer(p);
        // The first card a learner sees must say which prayer to intend,
        // not just "make the intention".
        expect(steps.first.title, 'Intend to pray ${p.name}',
            reason: '${p.name} must begin by naming its own intention');
        // The intention carries no body text; its title names the prayer.
        expect(steps.first.instruction, isEmpty,
            reason: '${p.name} intention should be a bare title');
      }
    });

    test('every pillar survives in complete mode', () {
      // The arkan: intention, standing, al-Fatiha, bowing, rising,
      // prostrating, sitting between, final sitting, and the closing peace.
      const pillars = [
        'Intend to pray',
        'Standing',
        'Recite the Opening Chapter',
        'Bowing',
        'Rising from Bowing',
        'Prostration',
        'Sitting Between Prostrations',
        'Sitting Testification',
        'Closing Peace',
      ];

      for (final p in prayers) {
        final titles = completePrayer(p).map((s) => s.title).toList();
        for (final pillar in pillars) {
          expect(titles.any((t) => t.contains(pillar)), isTrue,
              reason: '${p.name} is missing the pillar: $pillar');
        }
      }
    });

    test('starting out keeps every pillar POSITION', () {
      // The words may be simplified, but no posture or moment may vanish:
      // someone following this mode still performs the whole prayer, and
      // learns the wording as they go.
      const positions = [
        'Intend to pray',
        'Standing',
        'Bowing',
        'Rising from Bowing',
        'Prostration',
        'Sitting Between Prostrations',
      ];

      for (final p in prayers) {
        final titles = minimalPrayer(p).map((s) => s.title).toList();
        for (final position in positions) {
          expect(titles.any((t) => t.contains(position)), isTrue,
              reason: '${p.name} lost the position: $position');
        }
      }
    });

    test('starting out still stands, recites, sits and closes', () {
      for (final p in prayers) {
        final steps = minimalPrayer(p);

        // Something is recited while standing, even if it is the short
        // praise rather than the full chapter.
        expect(
          steps.any((s) => s.title.contains('Praise Allah')),
          isTrue,
          reason: '${p.name} leaves the standing recitation empty',
        );

        // The sittings are occupied, even if with takbir.
        expect(
          steps.any((s) => s.title.startsWith('Sitting (')),
          isTrue,
          reason: '${p.name} has an empty sitting',
        );

        // And the prayer is actually closed.
        expect(
          steps.last.transliteration,
          contains('salamu alaikum'),
          reason: '${p.name} does not end with the closing peace',
        );
      }
    });

    test('each prayer keeps its full count of rounds', () {
      for (final p in prayers) {
        // Rounds are counted by the standing recitation, which in complete
        // mode is Al-Fatiha and in starting-out mode is the praise line.
        final complete = completePrayer(p)
            .where((s) => s.title.contains('Recite the Opening Chapter'))
            .length;
        expect(complete, p.rakatCount,
            reason: '${p.name} should have ${p.rakatCount} rounds in '
                'complete mode, found $complete');

        final minimal = minimalPrayer(p)
            .where((s) => s.title.contains('Praise Allah'))
            .length;
        expect(minimal, p.rakatCount,
            reason: '${p.name} should have ${p.rakatCount} rounds in '
                'starting-out mode, found $minimal');
      }
    });

    test('every round keeps both prostrations', () {
      for (final p in prayers) {
        final steps = minimalPrayer(p);
        final first =
            steps.where((s) => s.title.contains('First Prostration')).length;
        final second =
            steps.where((s) => s.title.contains('Second Prostration')).length;

        expect(first, p.rakatCount, reason: '${p.name} lost a prostration');
        expect(second, p.rakatCount, reason: '${p.name} lost a prostration');
      }
    });

    test('each prayer still ends with the closing peace', () {
      for (final p in prayers) {
        // Both modes end with the salam; only the wording before it differs.
        expect(minimalPrayer(p).last.title, contains('Closing Peace'),
            reason: '${p.name} must end with the closing greeting');
        expect(completePrayer(p).last.title,
            contains('Closing Peace'),
            reason: '${p.name} must end with the closing greeting');
      }
    });

    test('only recommended additions and stand-ins were removed', () {
      // Anything dropped in starting-out mode must be either a sunnah or the
      // fuller wording a stand-in replaces. A pillar POSITION disappearing
      // would mean the mode teaches an incomplete prayer.
      const removable = [
        'Opening Supplication',
        'Short Chapter',
        // Replaced by the simplified stand-ins, not dropped outright.
        'Recite the Opening Chapter',
        'Sitting Testification',
        'Closing Peace',
      ];

      for (final p in prayers) {
        final full = p.steps.map((s) => s.title).toSet();
        final minimal = minimalPrayer(p).map((s) => s.title).toSet();
        final dropped = full.difference(minimal);

        for (final title in dropped) {
          expect(removable.any((r) => title.contains(r)), isTrue,
              reason: '${p.name} dropped "$title", which is neither a '
                  'recommended addition nor a step with a stand-in');
        }
      }
    });

    test('every dropped pillar has a stand-in taking its place', () {
      // The counterpart to the test above: it is not enough that a pillar was
      // removed for a defensible reason, something must replace it.
      for (final p in prayers) {
        final minimal = minimalPrayer(p);
        final replaced = {
          'Recite the Opening Chapter': 'Praise Allah',
          'Sitting Testification': 'Sitting (',
          'Closing Peace': 'Closing Peace',
        };

        replaced.forEach((removed, standIn) {
          final hasRemoved =
              minimal.any((s) => s.title.contains(removed));
          final hasStandIn =
              minimal.any((s) => s.title.contains(standIn));
          expect(hasRemoved || hasStandIn, isTrue,
              reason: '${p.name}: "$removed" is gone with no stand-in');
        });
      }
    });
  });
}
