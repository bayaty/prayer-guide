import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_guide/data/practice_mode.dart';
import 'package:prayer_guide/data/wudu_data.dart';

/// Wiping a quarter of the head is the Hanafi MINIMUM, not the fuller
/// practice. It belongs on the bare-minimum card, where someone is being told
/// the least that counts, and not on the Complete Steps card, which teaches
/// the practice properly.
///
/// It stays ONE essential step rather than a beginner/learning swap: an
/// obligation must never be filterable, which validity_test enforces.
void main() {
  final head = wuduSteps.firstWhere((s) => s.title == 'Wipe the Head');

  test('bare minimum states how much of the head counts', () {
    expect(head.titleFor(extraSunnahs: false),
        'Wipe the Head (at least one quarter of the head)');
  });

  test('complete steps drops the minimum qualifier', () {
    expect(head.titleFor(extraSunnahs: true), 'Wipe the Head');
    expect(head.titleFor(extraSunnahs: true), isNot(contains('quarter')));
  });

  test('wiping the head stays obligatory in both modes', () {
    // The qualifier changes; the obligation does not. If this step were ever
    // reclassified, bare minimum would drop one of the four Quranic acts.
    expect(head.level, StepLevel.essential);
  });

  test('steps without an override keep one title everywhere', () {
    for (final step in wuduSteps) {
      if (step.bareMinimumTitle.isEmpty) {
        expect(step.titleFor(extraSunnahs: false), step.title);
        expect(step.titleFor(extraSunnahs: true), step.title);
      }
    }
  });
}
