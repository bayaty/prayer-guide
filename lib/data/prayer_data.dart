import 'practice_mode.dart';

class PrayerStep {
  final String title;
  final String arabicText;
  final String transliteration;
  final String translation;
  final String instruction;
  final String icon;

  /// Background on the purpose of this step. Hidden behind "Show more info".
  final String info;

  /// Whether the step is a pillar (rukn) or a recommended sunnah.
  final StepLevel level;

  const PrayerStep({
    required this.title,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    required this.instruction,
    required this.icon,
    this.info = '',
    this.level = StepLevel.essential,
  });
}

class Prayer {
  final String name;
  final String arabicName;
  final int rakatCount;
  final String timeDescription;
  final List<PrayerStep> steps;

  const Prayer({
    required this.name,
    required this.arabicName,
    required this.rakatCount,
    required this.timeDescription,
    required this.steps,
  });
}

final List<PrayerStep> _oneRakah = [
  const PrayerStep(
    title: 'Standing (Qiyam)',
    arabicText: 'اللَّهُ أَكْبَرُ',
    transliteration: 'Allahu Akbar',
    translation: 'Allah is the Greatest',
    instruction: 'Stand facing the Qibla (the direction of Makkah). Raise your hands to your ears and say the Takbir to begin the prayer.',
    icon: 'posture:standing',
    info:
        'Qiyam marks the moment you leave worldly matters behind and stand '
        'before Allah. The opening Takbir is the boundary: once said, '
        'speech, eating and turning away are no longer permitted until the '
        'prayer ends. Raising the hands is a gesture of surrender, like '
        'setting the world down behind you.',
  ),
  const PrayerStep(
    title: 'Opening Supplication',
    arabicText: 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَىٰ جَدُّكَ، وَلَا إِلَٰهَ غَيْرُكَ',
    transliteration: 'Subhanaka Allahumma wa bihamdika, wa tabarakasmuka, wa ta\'ala jadduka, wa la ilaha ghairuk',
    translation: 'Glory be to You O Allah, and praise be to You. Blessed is Your name, exalted is Your majesty, and there is no god but You.',
    instruction: 'Place your right hand over your left on your chest. Recite the opening supplication silently.',
    icon: 'posture:hands',
    level: StepLevel.sunnah,
    info:
        'A quiet praise said before any recitation, said silently because '
        'it is between you and Allah alone. It settles the heart and shifts '
        'attention from the rush of daily life into the prayer.',
  ),
  const PrayerStep(
    title: 'Recite Al-Fatiha (The Opening)',
    arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\nالرَّحْمَٰنِ الرَّحِيمِ\nمَالِكِ يَوْمِ الدِّينِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\nاهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\nصِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
    transliteration: 'Bismillahir Rahmanir Raheem\nAlhamdu lillahi Rabbil \'aalameen\nAr-Rahmanir Raheem\nMaaliki yawmid-deen\nIyyaka na\'budu wa iyyaka nasta\'een\nIhdinas-siratal mustaqeem\nSiratal-lazeena an\'amta \'alaihim ghairil maghdoobi \'alaihim walad-daalleen',
    translation: 'In the name of Allah, the Most Gracious, the Most Merciful.\nAll praise is due to Allah, Lord of all the worlds.\nThe Most Gracious, the Most Merciful.\nMaster of the Day of Judgment.\nYou alone we worship, and You alone we ask for help.\nGuide us on the Straight Path.\nThe path of those who have received Your grace; not the path of those who have brought down wrath upon themselves, nor of those who have gone astray.',
    instruction: 'Recite Surah Al-Fatiha (the opening chapter). This is required in every rak\'ah (round of prayer) of the prayer. Say "Ameen" at the end.',
    icon: '📖',
    info:
        'Al-Fatiha is required in every rak\'ah (round of prayer), which is why it is called '
        'the Opening. A hadith qudsi describes it as a conversation, with '
        'Allah answering each verse as it is recited. Half of it praises '
        'Allah and half asks for guidance, so recite it slowly enough to '
        'hear both.',
  ),
  const PrayerStep(
    title: 'Recite a Short Surah (chapter)',
    arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ\nاللَّهُ الصَّمَدُ\nلَمْ يَلِدْ وَلَمْ يُولَدْ\nوَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
    transliteration: 'Qul Huwa Allahu Ahad\nAllahus-Samad\nLam yalid wa lam yoolad\nWa lam yakun lahu kufuwan ahad',
    translation: 'Say: He is Allah, the One.\nAllah, the Eternal Refuge.\nHe neither begets nor is born.\nNor is there to Him any equivalent.',
    instruction: 'After Al-Fatiha, recite any short surah (chapter of the Quran). Here is Surah Al-Ikhlas (112) as an example. This is recited in the first two rak\'ahs (rounds).',
    icon: '📖',
    level: StepLevel.sunnah,
    info:
        'Adding a passage after Al-Fatiha in the first two rak\'ahs (rounds) keeps '
        'the Quran present in daily worship. Any portion may be used, so a '
        'new Muslim can begin with a short surah such as Al-Ikhlas and '
        'build from there.',
  ),
  const PrayerStep(
    title: 'Bowing (Ruku)',
    arabicText: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
    transliteration: 'Subhana Rabbiyal Azeem',
    translation: 'Glory be to my Lord, the Most Great',
    instruction: 'Say "Allahu Akbar" and bow down, placing your hands on your knees. Keep your back straight. Say this remembrance (dhikr) 3 times.',
    icon: 'posture:bowing',
    info:
        'Ruku is for glorifying Allah rather than asking. The Prophet '
        'instructed that the Quran not be recited in this position; '
        'magnify your Lord here, and save your requests for sujud.',
  ),
  const PrayerStep(
    title: 'Rising from Bowing',
    arabicText: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ\nرَبَّنَا وَلَكَ الْحَمْدُ',
    transliteration: 'Sami\' Allahu liman hamidah\nRabbana wa lakal hamd',
    translation: 'Allah hears the one who praises Him.\nOur Lord, to You belongs all praise.',
    instruction: 'Rise back to standing position while saying "Sami Allahu liman hamidah", then say "Rabbana wa lakal hamd".',
    icon: 'posture:standing',
    info:
        'Standing upright again is its own required posture, not a rushed '
        'transition. It is one of the few moments in the prayer where '
        'praise is voiced aloud in response to Allah hearing the one who '
        'praises Him.',
  ),
  const PrayerStep(
    title: 'First Prostration (Sujud)',
    arabicText: 'سُبْحَانَ رَبِّيَ الْأَعْلَىٰ',
    transliteration: 'Subhana Rabbiyal A\'la',
    translation: 'Glory be to my Lord, the Most High',
    instruction: 'Say "Allahu Akbar" and prostrate with your forehead, nose, both palms, both knees, and toes touching the ground. Say this remembrance (dhikr) 3 times.',
    icon: 'posture:prostrating',
    info:
        'This is the best place and time to make dua. The Prophet said '
        'the servant is nearest to Allah while in sujud, so ask for what '
        'you need here, in any language, after saying the required '
        'glorification. Personal, specific dua belongs in this position '
        'more than anywhere else in the prayer.',
  ),
  const PrayerStep(
    title: 'Sitting Between Prostrations',
    arabicText: 'رَبِّ اغْفِرْ لِي',
    transliteration: 'Rabbighfir lee',
    translation: 'My Lord, forgive me',
    instruction: 'Rise from sujud saying "Allahu Akbar" and sit briefly. Say this supplication.',
    icon: 'posture:sitting',
    info:
        'This is the best moment for repentance. The supplication said '
        'here is a direct request for forgiveness, so bring to mind what '
        'you want forgiven and ask sincerely. Do not rush the sitting; '
        'stay still long enough to mean what you are saying.',
  ),
  const PrayerStep(
    title: 'Second Prostration (Sujud)',
    arabicText: 'سُبْحَانَ رَبِّيَ الْأَعْلَىٰ',
    transliteration: 'Subhana Rabbiyal A\'la',
    translation: 'Glory be to my Lord, the Most High',
    instruction: 'Say "Allahu Akbar" and prostrate again. Say this remembrance (dhikr) 3 times. This completes one rak\'ah (round of prayer).',
    icon: 'posture:prostrating',
    info:
        'Another opportunity for dua, and the same nearness applies. '
        'Repeating the prostration completes the rak\'ah (round of prayer), and the cycle of '
        'standing, bowing and prostrating covers the full range of human '
        'posture in one unit of prayer.',
  ),
];

/// Said once at the very start, before the first round.
final List<PrayerStep> _opening = [
  const PrayerStep(
    title: 'Intention (Niyyah)',
    arabicText: '',
    transliteration: '',
    translation: '',
    instruction:
        'Decide in your heart which prayer you are about to perform. The '
        'intention is held in the heart and is not spoken aloud. Without it '
        'the prayer does not count, so settle it before you say the Takbir.',
    icon: '🤍',
    info:
        'Niyyah is what separates prayer from ordinary movement. The Prophet '
        'said that actions are judged by intentions, and that each person '
        'receives what they intended. It costs no time: simply know which '
        'prayer you are standing for before you begin.',
  ),
];

final List<PrayerStep> _tashahhud = [
  const PrayerStep(
    title: 'Testification (Tashahhud)',
    arabicText: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ\nالسَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ\nالسَّلَامُ عَلَيْنَا وَعَلَىٰ عِبَادِ اللَّهِ الصَّالِحِينَ\nأَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
    transliteration: 'At-tahiyyatu lillahi was-salawatu wat-tayyibat\nAs-salamu \'alaika ayyuhan-Nabiyyu wa rahmatullahi wa barakatuh\nAs-salamu \'alaina wa \'ala \'ibadillahis-saliheen\nAsh-hadu an la ilaha illallah wa ash-hadu anna Muhammadan \'abduhu wa rasuluh',
    translation: 'All greetings, prayers, and good things are for Allah.\nPeace be upon you, O Prophet, and the mercy of Allah and His blessings.\nPeace be upon us and upon the righteous servants of Allah.\nI bear witness that there is no god but Allah, and I bear witness that Muhammad is His servant and messenger.',
    instruction: 'Sit with your left foot under you and right foot upright. Point your right index finger. Recite the Tashahhud.',
    icon: 'posture:sitting',
    info:
        'Before the final Tasleem there is another opening for dua, and '
        'the Prophet taught seeking refuge from the punishment of the '
        'grave, the punishment of the Fire, the trials of life and death, '
        'and the trial of the False Messiah. The raised index finger '
        'points to the oneness of Allah.',
  ),
];

final List<PrayerStep> _closing = [
  const PrayerStep(
    title: 'Blessings & Closing Peace (Salawat & Tasleem)',
    arabicText: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ\nكَمَا صَلَّيْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ\nإِنَّكَ حَمِيدٌ مَجِيدٌ\nاللَّهُمَّ بَارِكْ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ\nكَمَا بَارَكْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ\nإِنَّكَ حَمِيدٌ مَجِيدٌ\n\nالسَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
    transliteration: 'Allahumma salli \'ala Muhammad wa \'ala ali Muhammad\nKama sallaita \'ala Ibrahim wa \'ala ali Ibrahim\nInnaka Hameedun Majeed\nAllahumma barik \'ala Muhammad wa \'ala ali Muhammad\nKama barakta \'ala Ibrahim wa \'ala ali Ibrahim\nInnaka Hameedun Majeed\n\nAssalamu alaikum wa rahmatullah',
    translation: 'O Allah, send prayers upon Muhammad and upon the family of Muhammad,\nas You sent prayers upon Ibrahim and the family of Ibrahim.\nIndeed, You are Praiseworthy and Glorious.\nO Allah, bless Muhammad and the family of Muhammad,\nas You blessed Ibrahim and the family of Ibrahim.\nIndeed, You are Praiseworthy and Glorious.\n\nPeace and mercy of Allah be upon you.',
    instruction: 'In the final sitting, after the Tashahhud, recite the Salawat (blessings upon the Prophet). Then turn your head to the right and say the Tasleem (the closing greeting of peace), and turn to the left and repeat it. This ends the prayer.',
    icon: '🕊️',
    info:
        'The Salawat asks blessings upon the Prophet and his family, '
        'mirroring the blessings sent upon Ibrahim. The Tasleem then closes '
        'the prayer by turning to each side with peace, which is also a '
        'greeting to those praying beside you.',
  ),
];

List<PrayerStep> _buildSteps(int rakatCount) {
  final steps = <PrayerStep>[];

  // The intention is a pillar of the prayer and is made once, before the
  // first round, so it is never filtered out.
  steps.addAll(_opening);

  for (int i = 1; i <= rakatCount; i++) {
    final rakahSteps = List<PrayerStep>.from(_oneRakah);
    if (i > 2) {
      // 3rd and 4th rak'ah: only Al-Fatiha, no extra surah
      rakahSteps.removeAt(3);
    }
    if (i > 1) {
      // Opening supplication only in first rak'ah
      rakahSteps.removeAt(1);
    }

    for (final step in rakahSteps) {
      steps.add(PrayerStep(
        title: '${step.title} (Round $i)',
        arabicText: step.arabicText,
        transliteration: step.transliteration,
        translation: step.translation,
        instruction: step.instruction,
        icon: step.icon,
        info: step.info,
        level: step.level,
      ));
    }

    // Tashahhud after 2nd rak'ah (middle) and last rak'ah (final)
    if (i == 2 || i == rakatCount) {
      steps.addAll(_tashahhud.map((s) => PrayerStep(
        title: i == rakatCount ? '${s.title} (Final)' : '${s.title} (Middle)',
        arabicText: s.arabicText,
        transliteration: s.transliteration,
        translation: s.translation,
        instruction: s.instruction,
        icon: s.icon,
        info: s.info,
        level: s.level,
      )));
    }

    // Salawat + Tasleem (combined) only at the very end
    if (i == rakatCount) {
      steps.addAll(_closing);
    }
  }

  return steps;
}

final List<Prayer> prayers = [
  Prayer(
    name: 'Fajr',
    arabicName: 'الفجر',
    rakatCount: 2,
    timeDescription: 'Dawn, before sunrise',
    steps: _buildSteps(2),
  ),
  Prayer(
    name: 'Dhuhr',
    arabicName: 'الظهر',
    rakatCount: 4,
    timeDescription: 'Midday, after the sun passes its zenith',
    steps: _buildSteps(4),
  ),
  Prayer(
    name: 'Asr',
    arabicName: 'العصر',
    rakatCount: 4,
    timeDescription: 'Afternoon, when shadows equal object length',
    steps: _buildSteps(4),
  ),
  Prayer(
    name: 'Maghrib',
    arabicName: 'المغرب',
    rakatCount: 3,
    timeDescription: 'Sunset, just after the sun sets',
    steps: _buildSteps(3),
  ),
  Prayer(
    name: 'Isha',
    arabicName: 'العشاء',
    rakatCount: 4,
    timeDescription: 'Night, after twilight disappears',
    steps: _buildSteps(4),
  ),
];
