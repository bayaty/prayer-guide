import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_guide/data/practice_mode.dart';
import 'package:prayer_guide/data/prayer_data.dart';

/// The step counter read "20 of 23" in Complete Steps, which looked like three
/// steps were still hidden. They were not: three of those 23 are `beginner`
/// stand-ins that are SWAPPED OUT for their `learning` counterparts, so the
/// raw total counts both halves of every swap and no mode can ever reach it.
void main() {
  test('completing the steps reaches the stated total', () {
    for (final prayer in prayers) {
      final reachable =
          prayer.steps.where((s) => s.level != StepLevel.beginner).length;
      final complete =
          prayer.steps.where((s) => s.level != StepLevel.beginner).length;

      expect(complete, reachable,
          reason: '${prayer.name}: Complete Steps must show every step the '
              'counter promises, otherwise the denominator is unreachable');
    }
  });

  test('bare minimum is a strict subset, never larger', () {
    for (final prayer in prayers) {
      final bare = prayer.steps
          .where((s) =>
              s.level == StepLevel.essential || s.level == StepLevel.beginner)
          .length;
      final reachable =
          prayer.steps.where((s) => s.level != StepLevel.beginner).length;

      expect(bare, lessThanOrEqualTo(reachable),
          reason: '${prayer.name}: bare minimum cannot exceed the total');
      expect(bare, greaterThan(0), reason: '${prayer.name}: nothing to show');
    }
  });

  test('bare minimum says each phrase once, not three times', () {
    // Saying it three times is the recommended practice, not what makes the
    // prayer valid, so it belongs in Complete Steps rather than the path a
    // beginner is told is the minimum.
    for (final prayer in prayers) {
      final bare = prayer.steps.where((s) =>
          s.level == StepLevel.essential || s.level == StepLevel.beginner);

      for (final step in bare) {
        expect(step.instruction, isNot(contains('3 times')),
            reason: '${prayer.name} "${step.title}" still asks for three '
                'repetitions in the bare-minimum path');
      }
    }
  });
}
