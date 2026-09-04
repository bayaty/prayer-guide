import 'practice_mode.dart';

class WuduStep {
  final int number;
  final String title;
  final String arabicText;
  final String transliteration;
  final String translation;
  final String instruction;
  final String icon;

  /// How many times the action is performed (0 = not a counted action,
  /// e.g. intention or the closing supplication).
  final int times;

  /// Background on why the step exists. Hidden behind "Show more info".
  final String info;

  /// Whether the step is obligatory (fard) or a recommended sunnah.
  final StepLevel level;

  const WuduStep({
    required this.number,
    required this.title,
    required this.instruction,
    required this.icon,
    this.arabicText = '',
    this.transliteration = '',
    this.translation = '',
    this.times = 0,
    this.info = '',
    this.level = StepLevel.essential,
  });

  /// How many times to show for the current practice mode.
  ///
  /// Washing each part three times is the sunnah; washing once is enough for
  /// the obligation to be met, as recorded in Sahih al-Bukhari 157. So the
  /// bare-minimum view reduces any repeated action to a single time.
  int timesFor({required bool extraSunnahs}) {
    if (times == 0) return 0;
    return extraSunnahs ? times : 1;
  }
}

/// The steps of wudu (ablution), in order.
final List<WuduStep> wuduSteps = [
  const WuduStep(
    number: 1,
    title: 'Intention',
    instruction: '',
    icon: '🤍',
    level: StepLevel.sunnah,
  ),
  const WuduStep(
    number: 2,
    title: 'Say In the Name of God',
    instruction: '',
    icon: '🌸',
    level: StepLevel.sunnah,
  ),
  const WuduStep(
    number: 3,
    title: 'Wash the Hands',
    instruction: '',
    icon: '🫧',
    level: StepLevel.sunnah,
    times: 3,
  ),
  const WuduStep(
    number: 4,
    title: 'Rinse the Mouth',
    instruction: '',
    icon: '💧',
    level: StepLevel.sunnah,
    times: 3,
  ),
  const WuduStep(
    number: 5,
    title: 'Rinse the Nose',
    instruction: '',
    icon: '💨',
    level: StepLevel.sunnah,
    times: 3,
  ),
  const WuduStep(
    number: 6,
    title: 'Wash the Face',
    instruction: '',
    icon: '🌷',
    times: 3,
  ),
  const WuduStep(
    number: 7,
    title: 'Wash the Arms (include elbows)',
    instruction: '',
    icon: '🌿',
    times: 3,
  ),
  const WuduStep(
    number: 8,
    title: 'Wipe the Head (at least one quarter of the head)',
    instruction: '',
    icon: '🌙',
    times: 1,
  ),
  const WuduStep(
    number: 9,
    title: 'Wipe the Ears',
    instruction: '',
    icon: '🎀',
    level: StepLevel.sunnah,
    times: 1,
  ),
  const WuduStep(
    number: 10,
    title: 'Wash the Feet (include ankles)',
    instruction: '',
    icon: '🌺',
    times: 3,
  ),
];
