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
    instruction:
        'Make the intention in your heart to wash for purification. '
        'The intention is silent; it is not spoken aloud.',
    icon: '🤍',
    level: StepLevel.sunnah,
    info:
        'The intention is what turns washing into an act of worship. It is '
        'held in the heart, not spoken aloud. The Prophet said: "Whoever '
        'washes for prayer and perfects it, his sins leave his body, even '
        'from under his fingernails." (Sahih Muslim 245)',
  ),
  const WuduStep(
    number: 2,
    title: 'Say In the Name of God',
    arabicText: 'بِسْمِ اللَّهِ',
    transliteration: 'Bismillah',
    translation: 'In the name of Allah',
    instruction: 'Begin by saying the words below, meaning "In the name of God".',
    icon: '🌸',
    level: StepLevel.sunnah,
    info:
        'Beginning in the name of Allah frames the whole act as worship. '
        'It is the same phrase that opens most surahs of the Quran and '
        'most daily actions.',
  ),
  const WuduStep(
    number: 3,
    title: 'Wash the Hands',
    instruction:
        'Wash both hands up to the wrists, beginning with the right. '
        'Make sure the water reaches between the fingers.',
    icon: '🫧',
    level: StepLevel.sunnah,
    info:
        'The hands are washed first because they carry out the rest of '
        'the wudu. Starting on the right follows the Prophet\'s practice '
        'of beginning with the right in acts of purification and honour.',
    times: 3,
  ),
  const WuduStep(
    number: 4,
    title: 'Rinse the Mouth',
    instruction:
        'Take water into your mouth with the right hand, swill it around, '
        'and spit it out.',
    icon: '💧',
    level: StepLevel.sunnah,
    info:
        'The mouth is cleansed because it is the instrument of speech and '
        'of Quran recitation. Purifying it before prayer prepares what '
        'you will use to speak to Allah.',
    times: 3,
  ),
  const WuduStep(
    number: 5,
    title: 'Rinse the Nose',
    instruction:
        'Sniff water gently into the nostrils with the right hand, then blow '
        'it out using the left hand.',
    icon: '💨',
    level: StepLevel.sunnah,
    info:
        'Water is drawn in gently and expelled with the left hand, '
        'keeping the right hand clean for pure actions. It clears the '
        'passages before standing in prayer.',
    times: 3,
  ),
  const WuduStep(
    number: 6,
    title: 'Wash the Face',
    instruction: 'Wash your face, from the hairline to the chin and from '
        'ear to ear.',
    icon: '🌷',
    info: 'Named first in the verse on washing for prayer (Quran 5:6).',
    times: 3,
  ),
  const WuduStep(
    number: 7,
    title: 'Wash the Arms',
    instruction: 'Wash each arm up to and including the elbow.',
    icon: '🌿',
    info: 'The elbows are included, not just reached (Quran 5:6).',
    times: 3,
  ),
  const WuduStep(
    number: 8,
    title: 'Wipe the Head',
    instruction: 'Take fresh water in your hands, then wipe over a quarter '
        'of your head. Once is enough.',
    icon: '🌙',
    info: 'The head is wiped, not washed, and once is enough. A quarter of '
        'the head is all that is required. Abdullah bin Zaid, describing '
        'how the Prophet washed, put his hands in the water before wiping '
        '(Sahih al-Bukhari 186).',
    times: 1,
  ),
  const WuduStep(
    number: 9,
    title: 'Wipe the Ears',
    instruction:
        'With the same wetness used for the head, wipe the inside of your '
        'ears with your index fingers and the outside with your thumbs.',
    icon: '🎀',
    level: StepLevel.sunnah,
    info:
        'The ears are treated as part of the head. Describing the same '
        'wudu, the narration continues that the Prophet "wiped his head '
        'and ears inside and outside" (Sunan Abi Dawud 121), the ears '
        'following on from the head rather than being a separate washing.',
    times: 1,
  ),
  const WuduStep(
    number: 10,
    title: 'Wash the Feet',
    instruction: 'Wash each foot up to and including the ankle.',
    icon: '🌺',
    info: 'Leave no dry patches, especially on the heels.',
    times: 3,
  ),
];
