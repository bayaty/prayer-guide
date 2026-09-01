import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_guide/data/practice_mode.dart';
import 'package:prayer_guide/data/wudu_data.dart';

/// The bare minimum follows the Hanafi school, where the required acts of
/// wudu are the four named in al-Ma'idah 5:6: wash the face, wash the arms
/// to the elbows, wipe the head, wash the feet to the ankles.
///
/// Intention is deliberately NOT among them. It is fard in the Shafi'i
/// school, so this is a school-specific claim and the app says so on the
/// card rather than presenting it as universal.
void main() {
  Iterable<WuduStep> bareMinimum() =>
      wuduSteps.where((s) => s.level == StepLevel.essential);

  group('bare minimum wudu is the four Hanafi requirements', () {
    test('shows exactly four steps', () {
      expect(bareMinimum().length, 4);
    });

    test('is the four acts the Quran names, in order', () {
      expect(
        bareMinimum().map((s) => s.title).toList(),
        ['Wash the Face', 'Wash the Arms', 'Wipe the Head', 'Wash the Feet'],
      );
    });

    test('does not require the intention', () {
      // Hanafi: niyyah is sunnah, not one of the four fard.
      final intention = wuduSteps.firstWhere((s) => s.title == 'Intention');
      expect(intention.level, StepLevel.sunnah);
    });

    test('the head is wiped once, everything else washed three times', () {
      final head = wuduSteps.firstWhere((s) => s.title == 'Wipe the Head');
      expect(head.timesFor(extraSunnahs: true), 1);
      for (final s in bareMinimum().where((s) => s.title != 'Wipe the Head')) {
        expect(s.timesFor(extraSunnahs: true), 3, reason: s.title);
      }
    });

    test('bare minimum still washes once each', () {
      // Three times is the fuller practice; once is what is required.
      for (final s in bareMinimum()) {
        expect(s.timesFor(extraSunnahs: false), 1, reason: s.title);
      }
    });
  });

  group('titles avoid untranslated Arabic', () {
    // The audience is new Muslims and reverts. A transliterated Arabic term
    // in a heading is a word they cannot read, look up, or pronounce yet.
    // The Arabic of the Bismillah still appears on its own card, where the
    // Arabic, transliteration and translation are shown together.
    const arabicTerms = [
      'Niyyah',
      'Madmadah',
      'Istinshaq',
      'Masah',
      'Bismillah',
    ];

    test('no step title contains a transliterated Arabic term', () {
      for (final step in wuduSteps) {
        for (final term in arabicTerms) {
          expect(
            step.title.toLowerCase(),
            isNot(contains(term.toLowerCase())),
            reason: '"${step.title}" still contains $term',
          );
        }
      }
    });

    test('no step title carries a parenthetical gloss', () {
      // "Wipe the Head (Masah)" is the shape being removed.
      for (final step in wuduSteps) {
        expect(step.title, isNot(contains('(')), reason: step.title);
      }
    });

    test('the Arabic of the Bismillah is still taught on its card', () {
      final basmala =
          wuduSteps.firstWhere((s) => s.title == 'Say In the Name of God');
      expect(basmala.arabicText, isNotNull);
      expect(basmala.transliteration, 'Bismillah');
      expect(basmala.translation, isNotNull);
    });
  });

  group('rulings are stated plainly, without naming a school', () {
    // House rule, enforced app-wide by bare_minimum_test.dart: a beginner
    // does not yet know what a madhab is, so a school name in their first
    // instruction raises a question it does not answer. The rulings still
    // have to be correct and specific, just unlabelled.
    test('the head card gives the quarter-head minimum', () {
      final head = wuduSteps.firstWhere((s) => s.title == 'Wipe the Head');
      expect(head.info, contains('quarter'));
    });

    test('no wudu step names a school', () {
      const schools = ['Hanafi', 'Maliki', 'Shafi', 'Hanbali', 'madhab'];
      for (final step in wuduSteps) {
        for (final school in schools) {
          expect(step.instruction.toLowerCase(),
              isNot(contains(school.toLowerCase())),
              reason: '${step.title} instruction names $school');
          expect(step.info.toLowerCase(), isNot(contains(school.toLowerCase())),
              reason: '${step.title} info names $school');
        }
      }
    });
  });
}
