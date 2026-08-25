import 'package:flutter_test/flutter_test.dart';

import 'package:prayer_guide/data/wudu_data.dart';

/// The wiping of the head previously said it reused the wetness left on the
/// hands. Abdullah bin Zaid, describing the Prophet's wudu, put his hands in
/// the water before wiping (Sahih al-Bukhari 186), so fresh water is taken.
/// These guard that correction.
void main() {
  WuduStep step(String title) =>
      wuduSteps.firstWhere((s) => s.title.startsWith(title));

  group('wiping the head', () {
    test('calls for fresh water', () {
      final head = step('Wipe the Head');
      expect(head.instruction.toLowerCase(), contains('fresh water'));
    });

    test('no longer claims the leftover wetness is enough', () {
      final head = step('Wipe the Head');
      final blob = '${head.instruction} ${head.info}'.toLowerCase();

      expect(blob, isNot(contains('wetness already on the hands')));
      expect(blob, isNot(contains('without needing more water')));
    });

    test('cites the narration it rests on', () {
      expect(step('Wipe the Head').info, contains('Sahih al-Bukhari 186'));
    });

    test('is still wiped once rather than washed', () {
      final head = step('Wipe the Head');
      expect(head.times, 1);
      expect(head.info.toLowerCase(), contains('wiped, not washed'));
    });
  });

  group('wiping the ears', () {
    test('follows on from the head rather than taking new water', () {
      final ears = step('Wipe the Ears');
      expect(ears.instruction.toLowerCase(), contains('same wetness'));
      expect(ears.instruction.toLowerCase(), isNot(contains('fresh water')));
    });

    test('cites the narration it rests on', () {
      expect(step('Wipe the Ears').info, contains('Sunan Abi Dawud 121'));
    });
  });
}
