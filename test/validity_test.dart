import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prayer_guide/data/app_settings.dart';
import 'package:prayer_guide/data/practice_mode.dart';
import 'package:prayer_guide/data/prayer_data.dart';
import 'package:prayer_guide/data/wudu_data.dart';

/// Guards the promise made by bare-minimum mode: following only the steps it
/// shows must still produce a valid wudu and a valid prayer.
///
/// If a step is ever reclassified as sunnah by mistake, these fail.
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

  group('bare-minimum wudu remains valid', () {
    // The four obligations named in Quran 5:6.
    test('all four Quranic obligations survive', () {
      final titles = minimalWudu().map((s) => s.title).toList();

      expect(titles, contains('Wash the Face'),
          reason: 'washing the face is obligatory (Quran 5:6)');
      expect(titles, contains('Wash the Arms'),
          reason: 'washing the arms to the elbows is obligatory (Quran 5:6)');
      expect(titles, contains('Wipe the Head'),
          reason: 'wiping the head is obligatory (Quran 5:6)');
      expect(titles, contains('Wash the Feet'),
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
        titles.indexWhere((t) => t == 'Wash the Arms'),
        titles.indexWhere((t) => t == 'Wipe the Head'),
        titles.indexWhere((t) => t == 'Wash the Feet'),
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
        'Wash the Arms',
        'Wipe the Head',
        'Wash the Feet',
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
        expect(steps.first.instruction, contains(p.name),
            reason: '${p.name} intention must name the prayer');
      }
    });

    test('every pillar survives in every prayer', () {
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
        'Blessings and Closing Peace',
      ];

      for (final p in prayers) {
        final titles = minimalPrayer(p).map((s) => s.title).toList();
        for (final pillar in pillars) {
          expect(titles.any((t) => t.contains(pillar)), isTrue,
              reason: '${p.name} is missing the pillar: $pillar');
        }
      }
    });

    test('each prayer keeps its full count of rounds', () {
      for (final p in prayers) {
        final steps = minimalPrayer(p);
        // Al-Fatiha is recited once per round, so counting it counts rounds.
        final fatiha =
            steps.where((s) => s.title.contains('Recite the Opening Chapter')).length;
        expect(fatiha, p.rakatCount,
            reason: '${p.name} should have ${p.rakatCount} rounds, '
                'found $fatiha');
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
        expect(minimalPrayer(p).last.title,
            contains('Blessings and Closing Peace'),
            reason: '${p.name} must end with the closing greeting');
      }
    });

    test('only recommended additions were removed', () {
      // Anything dropped must be a sunnah, never a pillar.
      const removable = ['Opening Supplication', 'Short Chapter'];

      for (final p in prayers) {
        final full = p.steps.map((s) => s.title).toSet();
        final minimal = minimalPrayer(p).map((s) => s.title).toSet();
        final dropped = full.difference(minimal);

        for (final title in dropped) {
          expect(removable.any((r) => title.contains(r)), isTrue,
              reason: '${p.name} dropped "$title", which is not a '
                  'recommended addition');
        }
      }
    });
  });
}
