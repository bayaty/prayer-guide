import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_guide/data/prayer_data.dart';
import 'package:prayer_guide/data/wudu_data.dart';

/// The audience is new Muslims and reverts. A transliterated Arabic term in
/// a heading or an instruction is a word they cannot yet read, look up or
/// pronounce, so the steps say what to DO in plain English.
///
/// The Arabic that is meant to be learned still appears on its own card,
/// where the Arabic, transliteration and translation sit together and teach
/// each other. This guards the instructions, not that teaching.
void main() {
  // Terms that name a posture or an action the reader must perform. These
  // are the ones that leave a beginner stuck.
  const bannedInSteps = [
    'ruku',
    'sujud',
    'sujood',
    'qiyam',
    'niyyah',
    'tashahhud',
    'tasleem',
    'salawat',
    'masah',
    'madmadah',
    'istinshaq',
    // Glossed Arabic still makes a beginner stop and parse a word they
    // cannot pronounce, so the instructions use the plain English.
    "rak'ah",
    'dhikr',
    'surah',
  ];

  group('prayer steps read in plain English', () {
    test('no step title uses a transliterated Arabic term', () {
      for (final prayer in prayers) {
        for (final step in prayer.steps) {
          for (final term in bannedInSteps) {
            expect(step.title.toLowerCase(), isNot(contains(term)),
                reason: '${prayer.name}: "${step.title}" contains $term');
          }
        }
      }
    });

    test('no instruction uses a transliterated Arabic term', () {
      for (final prayer in prayers) {
        for (final step in prayer.steps) {
          for (final term in bannedInSteps) {
            expect(step.instruction.toLowerCase(), isNot(contains(term)),
                reason: '${prayer.name}: "${step.title}" instruction '
                    'contains $term');
          }
        }
      }
    });

    test('no step title carries a parenthetical Arabic gloss', () {
      // "Bowing (Ruku)" is the shape being removed. Round and Final markers
      // are positional, not Arabic, so they stay.
      final allowed = RegExp(r'\((Round \d+|Final|Middle)\)');
      for (final prayer in prayers) {
        for (final step in prayer.steps) {
          final stripped = step.title.replaceAll(allowed, '');
          expect(stripped, isNot(contains('(')),
              reason: '${prayer.name}: "${step.title}"');
        }
      }
    });
  });

  group('wudu steps read in plain English', () {
    test('no title or instruction uses a transliterated Arabic term', () {
      for (final step in wuduSteps) {
        for (final term in bannedInSteps) {
          expect(step.title.toLowerCase(), isNot(contains(term)),
              reason: '"${step.title}" contains $term');
          expect(step.instruction.toLowerCase(), isNot(contains(term)),
              reason: '"${step.title}" instruction contains $term');
        }
      }
    });
  });

  group('the intention names its own prayer', () {
    test('every prayer opens by naming itself', () {
      for (final prayer in prayers) {
        final first = prayer.steps.first;
        // The card is a bare title, so the title is what must name it.
        expect(first.title, 'Intend to pray ${prayer.name}');
      }
    });

    test('no two prayers share the same opening card', () {
      // A shared const would make every prayer say the same thing, which is
      // exactly what this replaced.
      final openings = prayers.map((p) => p.steps.first.title).toSet();
      expect(openings.length, prayers.length);
    });
  });

  group('the Arabic worth learning is still taught', () {
    test('recited steps keep Arabic, transliteration and translation', () {
      // Removing terms from instructions must not strip the words a learner
      // is meant to memorise.
      final recited = prayers.first.steps
          .where((s) => s.arabicText.isNotEmpty)
          .toList();
      expect(recited, isNotEmpty);
      for (final step in recited) {
        expect(step.transliteration, isNotEmpty, reason: step.title);
        expect(step.translation, isNotEmpty, reason: step.title);
      }
    });
  });
}
