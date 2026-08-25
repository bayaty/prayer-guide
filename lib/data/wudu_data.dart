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
    title: 'Intention (Niyyah)',
    instruction:
        'Make the intention in your heart to perform wudu for purification. '
        'The intention is silent; it is not spoken aloud.',
    icon: '🤍',
    info:
        'Niyyah is what separates an act of worship from an ordinary '
        'wash. It is held in the heart, not spoken, and it is why wudu '
        'performed with awareness carries reward. The Prophet said: '
        '"Whoever performs wudu and perfects it, his sins leave his body, '
        'even from under his fingernails." (Sahih Muslim 245)',
  ),
  const WuduStep(
    number: 2,
    title: 'Say Bismillah (In the name of God)',
    arabicText: 'بِسْمِ اللَّهِ',
    transliteration: 'Bismillah',
    translation: 'In the name of Allah',
    instruction: 'Begin by saying "Bismillah", meaning "In the name of God".',
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
    title: 'Rinse the Mouth (Madmadah)',
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
    title: 'Rinse the Nose (Istinshaq)',
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
    instruction:
        'Wash the whole face, from the hairline to the chin, and from ear '
        'to ear.',
    icon: '🌷',
    info:
        'The face is the part explicitly named first in the Quranic verse '
        'on wudu (al-Ma\'idah 5:6). Its boundaries are defined precisely: '
        'hairline to chin, ear to ear, so nothing is left unwashed.',
    times: 3,
  ),
  const WuduStep(
    number: 7,
    title: 'Wash the Arms',
    instruction:
        'Wash each arm from the fingertips up to and including the elbow. '
        'Begin with the right arm, then the left.',
    icon: '🌿',
    info:
        'The Quran specifies washing to the elbows, and the elbows are '
        'included rather than merely reached. Beginning with the right '
        'again follows the Prophet\'s practice.',
    times: 3,
  ),
  const WuduStep(
    number: 8,
    title: 'Wipe the Head (Masah)',
    instruction:
        'With wet hands, wipe over the head from the front hairline to the '
        'back, then bring the hands forward again. This is done once.',
    icon: '🌙',
    info:
        'The head is wiped, not washed, and only once. Masah uses the '
        'wetness already on the hands, which makes wudu practical without '
        'needing more water.',
    times: 1,
  ),
  const WuduStep(
    number: 9,
    title: 'Wipe the Ears',
    instruction:
        'Using the same wetness, wipe the inside of the ears with the index '
        'fingers and the outside with the thumbs.',
    icon: '🎀',
    level: StepLevel.sunnah,
    info:
        'The ears are treated as part of the head, using the same wetness '
        'rather than fresh water. Index fingers take the inside, thumbs '
        'the outside.',
    times: 1,
  ),
  const WuduStep(
    number: 10,
    title: 'Wash the Feet',
    instruction:
        'Wash each foot up to and including the ankles, beginning with the '
        'right. Make sure the water reaches between the toes.',
    icon: '🌺',
    info:
        'The feet complete the wudu, washed to and including the ankles. '
        'The Prophet warned against leaving dry patches on the heels, so '
        'water must reach every part, including between the toes.',
    times: 3,
  ),
];
