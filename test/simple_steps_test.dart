import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_guide/data/prayer_data.dart';

/// A beginner learns the prayer with one phrase carrying the movements:
/// "Allahu Akbar" to begin, to bow, to rise, to prostrate. The closing is
/// "Assalamu alaikum", said to the right and then the left.
///
/// The trap this guards: an instruction that names one phrase while the card
/// below it teaches different Arabic. That happened twice while writing this
/// (Rising from Bowing still showed "Sami' Allahu liman hamidah", and the
/// closing step showed the long blessings), and a learner reading the card
/// would see words they were never told to say.
void main() {
  List<PrayerStep> stepsOf(String prayerName) =>
      prayers.firstWhere((p) => p.name == prayerName).steps;

  /// Quoted phrases inside an instruction, e.g. Say "Allahu Akbar".
  Iterable<String> quoted(String text) =>
      RegExp(r'"([^"]+)"').allMatches(text).map((m) => m.group(1)!);

  group('the movements are carried by one phrase', () {
    test('beginning, bowing, rising and prostrating all say Allahu Akbar',
        () {
      const movements = [
        'Standing',
        'Bowing',
        'Rising from Bowing',
        'First Prostration',
        'Second Prostration',
      ];

      for (final step in stepsOf('Fajr')) {
        final base = step.title.replaceAll(RegExp(r' \(.*\)$'), '');
        if (!movements.contains(base)) continue;
        expect(step.instruction, contains('Allahu Akbar'),
            reason: '${step.title} should be entered with Allahu Akbar');
      }
    });

    test('the prayer closes with the greeting of peace, both sides', () {
      final last = stepsOf('Fajr').last;
      expect(last.instruction, contains('Assalamu alaikum'));
      expect(last.instruction.toLowerCase(), contains('right'));
      expect(last.instruction.toLowerCase(), contains('left'));
    });

    test('the sitting is described by how long it lasts', () {
      // Ten Takbirs is a rough length for an unhurried sitting, not a
      // required recitation, so the wording must read as duration.
      final sitting = stepsOf('Fajr').firstWhere(
        (s) => s.title.contains('(Final)') || s.title.contains('(Middle)'),
      );
      expect(sitting.instruction.toLowerCase(), contains('as long as'));
    });
  });

  group('a card teaches the phrase its instruction names', () {
    test('every quoted phrase matches that step, or is explained in info',
        () {
      for (final prayer in prayers) {
        for (final step in prayer.steps) {
          for (final phrase in quoted(step.instruction)) {
            // Two phrases legitimately appear without being the card's
            // recitation: "Ameen", a one word response, and "Allahu Akbar",
            // which is the transition INTO a posture while the card teaches
            // what is said once you are in it. Both are taught on their own
            // cards elsewhere, so they are not unexplained words.
            if (phrase == 'Ameen' || phrase == 'Allahu Akbar') continue;
            final taught = step.transliteration.contains(phrase) ||
                step.info.contains(phrase);
            expect(taught, isTrue,
                reason: '${prayer.name}: "${step.title}" tells you to say '
                    '"$phrase" but the card teaches '
                    '"${step.transliteration}"');
          }
        }
      }
    });

    test('a step that names Allahu Akbar shows it as the Arabic', () {
      for (final step in stepsOf('Fajr')) {
        final says = quoted(step.instruction).contains('Allahu Akbar');
        if (!says) continue;
        // The intention is settled silently, so it carries no Arabic even
        // though its wording names the phrase that starts the prayer.
        if (step.title.startsWith('Intend to pray')) continue;
        // Steps whose own recitation differs (bowing, prostration) still
        // teach their glorification, so only check that Arabic is present.
        expect(step.arabicText, isNotEmpty, reason: step.title);
      }
    });
  });

  group('the fuller wording is not lost, only moved', () {
    test('rising still records the fuller phrase in its background note', () {
      final rising = stepsOf('Fajr')
          .firstWhere((s) => s.title.startsWith('Rising from Bowing'));
      expect(rising.info, contains('Sami'));
      expect(rising.info, contains('Rabbana wa lakal hamd'));
    });

    test('the closing still records the blessings upon the Prophet', () {
      final last = stepsOf('Fajr').last;
      expect(last.info, contains('Allahumma salli'));
    });
  });
}
