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
    title: 'Standing',
    arabicText: 'اللَّهُ أَكْبَرُ',
    transliteration: 'Allahu Akbar',
    translation: 'Allah is the Greatest',
    instruction: 'Stand upright facing Makkah. Raise your hands to your shoulders and say the line:',
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
    instruction: 'Place your right hand over your left on your chest. '
        'Recite silently:',
    icon: 'posture:hands',
    level: StepLevel.sunnah,
    info:
        'A quiet praise said before any recitation, said silently because '
        'it is between you and Allah alone. It settles the heart and shifts '
        'attention from the rush of daily life into the prayer.',
  ),
  const PrayerStep(
    title: 'Praise Allah',
    arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    transliteration: 'Alhamdu lillahi Rabbil \'aalameen',
    translation: 'All praise is due to Allah, Lord of all the worlds',
    instruction: 'While standing, recite this:',
    icon: '📖',
    level: StepLevel.beginner,
    info:
        'A starting point, not the finished prayer. Al-Fatiha is required in '
        'every round, and a man who could not recite it was taught shorter '
        'words of praise to say until he learned. Use this line the same '
        'way: say it now, learn the full chapter, then switch to Complete '
        'Steps. Do not stay here longer than you need to.',
  ),
  const PrayerStep(
    title: 'Recite the Opening Chapter',
    arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\nالرَّحْمَٰنِ الرَّحِيمِ\nمَالِكِ يَوْمِ الدِّينِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\nاهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\nصِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
    transliteration: 'Bismillahir Rahmanir Raheem\nAlhamdu lillahi Rabbil \'aalameen\nAr-Rahmanir Raheem\nMaaliki yawmid-deen\nIyyaka na\'budu wa iyyaka nasta\'een\nIhdinas-siratal mustaqeem\nSiratal-lazeena an\'amta \'alaihim ghairil maghdoobi \'alaihim walad-daalleen',
    translation: 'In the name of Allah, the Most Gracious, the Most Merciful.\nAll praise is due to Allah, Lord of all the worlds.\nThe Most Gracious, the Most Merciful.\nMaster of the Day of Judgment.\nYou alone we worship, and You alone we ask for help.\nGuide us on the Straight Path.\nThe path of those who have received Your grace; not the path of those who have brought down wrath upon themselves, nor of those who have gone astray.',
    instruction: 'While standing, recite the opening chapter, then say '
        '"Ameen" at the end:',
    icon: '📖',
    level: StepLevel.learning,
    info:
        'The Opening is recited in every round, which is why it is called '
        'the Opening. A hadith qudsi describes it as a conversation, with '
        'Allah answering each verse as it is recited. Half of it praises '
        'Allah and half asks for guidance, so recite it slowly enough to '
        'hear both.',
  ),
  const PrayerStep(
    title: 'Recite a Short Chapter',
    arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ\nاللَّهُ الصَّمَدُ\nلَمْ يَلِدْ وَلَمْ يُولَدْ\nوَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
    transliteration: 'Qul Huwa Allahu Ahad\nAllahus-Samad\nLam yalid wa lam yoolad\nWa lam yakun lahu kufuwan ahad',
    translation: 'Say: He is Allah, the One.\nAllah, the Eternal Refuge.\nHe neither begets nor is born.\nNor is there to Him any equivalent.',
    instruction: 'Then recite any short chapter of the Quran. This one is '
        'Al-Ikhlas, an example to start with:',
    icon: '📖',
    level: StepLevel.sunnah,
    info:
        'Adding a passage after the Opening in the first two rounds keeps '
        'the Quran present in daily worship. Any portion may be used, so a '
        'new Muslim can begin with a short chapter such as Al-Ikhlas and '
        'build from there.',
  ),
  const PrayerStep(
    title: 'Bowing',
    arabicText: 'سُبْحَانَ اللَّهِ',
    transliteration: 'Subhan Allah',
    translation: 'Glory be to Allah',
    instruction: 'Say "Allahu Akbar" and bow, placing your hands on your '
        'knees with your back straight. While bowing, say 3 times:',
    icon: 'posture:bowing',
    info:
        'Bowing is for glorifying Allah rather than asking. The Prophet '
        'instructed that the Quran not be recited in this position; '
        'magnify your Lord here, and save your requests for when you '
        'are face down.',
  ),
  const PrayerStep(
    title: 'Rising from Bowing',
    arabicText: 'اللَّهُ أَكْبَرُ',
    transliteration: 'Allahu Akbar',
    translation: 'Allah is the Greatest',
    instruction: 'Stand back up, saying the line:',
    icon: 'posture:standing',
    info:
        'Standing upright again is its own posture, not a rushed transition. '
        'Stand still before moving on. Once these words carry you through '
        'the prayer, the fuller wording said here is "Sami\' Allahu liman '
        'hamidah", meaning "Allah hears the one who praises Him", answered '
        'with "Rabbana wa lakal hamd", "Our Lord, to You belongs all '
        'praise".',
  ),
  const PrayerStep(
    title: 'First Prostration',
    arabicText: 'سُبْحَانَ اللَّهِ',
    transliteration: 'Subhan Allah',
    translation: 'Glory be to Allah',
    instruction: 'Say "Allahu Akbar" and prostrate, with your forehead, '
        'nose, both palms, both knees and toes touching the ground. '
        'While down, say 3 times:',
    icon: 'posture:prostrating',
    info:
        'This is the best place and time to make dua. The Prophet said '
        'the servant is nearest to Allah while face down, so ask for what '
        'you need here, in any language, after saying the required '
        'glorification. Personal, specific dua belongs in this position '
        'more than anywhere else in the prayer.',
  ),
  const PrayerStep(
    title: 'Sitting Between Prostrations',
    arabicText: '',
    transliteration: '',
    translation: '',
    instruction: 'Say "Allahu Akbar" and sit up from the prostration. Sit '
        'still for a moment.',
    icon: 'posture:sitting',
    info:
        'This is a moment of rest between the two prostrations. Nothing has '
        'to be said here while you are learning. Once the rest is settled, '
        'the words said in this sitting are "Rabbighfir lee", meaning "My '
        'Lord, forgive me".',
  ),
  const PrayerStep(
    title: 'Second Prostration',
    arabicText: 'سُبْحَانَ اللَّهِ',
    transliteration: 'Subhan Allah',
    translation: 'Glory be to Allah',
    instruction: 'Say "Allahu Akbar" and prostrate again. While down, say '
        '3 times:',
    icon: 'posture:prostrating',
    info:
        'Another opportunity for dua, and the same nearness applies. '
        'Repeating the prostration completes the round, and the cycle of '
        'standing, bowing and prostrating covers the full range of human '
        'posture in one unit of prayer.',
  ),
];

/// Said once at the very start, before the first round.
///
/// Built per prayer rather than shared, so the first card names the prayer
/// being prayed. A beginner reading "Intend to pray Fajr" knows what to do;
/// "make the intention" leaves them guessing which prayer to intend.
PrayerStep _intention(String prayerName) => PrayerStep(
      title: 'Intend to pray $prayerName',
      arabicText: '',
      transliteration: '',
      translation: '',
      instruction: '',
      icon: '🤍',
    );

final List<PrayerStep> _tashahhud = [
  const PrayerStep(
    title: 'Sitting',
    arabicText: 'اللَّهُ أَكْبَرُ',
    transliteration: 'Allahu Akbar',
    translation: 'Allah is the Greatest',
    instruction: 'Sit with your left foot under you and your right foot '
        'upright. Say this line 10 times:',
    icon: 'posture:sitting',
    level: StepLevel.beginner,
    info:
        'While you are learning, filling the sitting with words you already '
        'know keeps it unhurried. Once the rest is settled, this sitting is '
        'where the testification is recited.',
  ),
  const PrayerStep(
    title: 'Sitting Testification',
    arabicText: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ\nالسَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ\nالسَّلَامُ عَلَيْنَا وَعَلَىٰ عِبَادِ اللَّهِ الصَّالِحِينَ\nأَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
    transliteration: 'At-tahiyyatu lillahi was-salawatu wat-tayyibat\nAs-salamu \'alaika ayyuhan-Nabiyyu wa rahmatullahi wa barakatuh\nAs-salamu \'alaina wa \'ala \'ibadillahis-saliheen\nAsh-hadu an la ilaha illallah wa ash-hadu anna Muhammadan \'abduhu wa rasuluh',
    translation: 'All greetings, prayers, and good things are for Allah.\nPeace be upon you, O Prophet, and the mercy of Allah and His blessings.\nPeace be upon us and upon the righteous servants of Allah.\nI bear witness that there is no god but Allah, and I bear witness that Muhammad is His servant and messenger.',
    instruction: 'Sit with your left foot under you and your right foot '
        'upright. Point your right index finger and recite:',
    icon: 'posture:sitting',
    level: StepLevel.learning,
    info:
        'Before the closing greeting there is another chance to make dua '
        '(personal supplication), and '
        'the Prophet taught seeking refuge from the punishment of the '
        'grave, the punishment of the Fire, the trials of life and death, '
        'and the trial of the False Messiah. The raised index finger '
        'points to the oneness of Allah.',
  ),
];

final List<PrayerStep> _closing = [
  const PrayerStep(
    title: 'Closing Peace',
    arabicText: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
    transliteration: 'Assalamu alaikum wa rahmatullah',
    translation: 'Peace and mercy of Allah be upon you',
    instruction: 'Turn your head to the right and say the line, then turn '
        'to the left and say it again. This ends the prayer.',
    icon: '🕊️',
    info:
        'Turning to each side closes the prayer and greets those praying '
        'beside you. Once the rest is settled, blessings upon the Prophet '
        'are said in this final sitting before the greeting: "Allahumma '
        'salli \'ala Muhammad wa \'ala ali Muhammad", asking blessings on '
        'the Prophet and his family as they were sent upon Ibrahim.',
  ),
];

List<PrayerStep> _buildSteps(String prayerName, int rakatCount) {
  final steps = <PrayerStep>[];

  // The intention is a pillar of the prayer and is made once, before the
  // first round, so it is never filtered out.
  steps.add(_intention(prayerName));

  for (int i = 1; i <= rakatCount; i++) {
    final rakahSteps = List<PrayerStep>.from(_oneRakah);

    // Removal is by title rather than index. These were positional
    // (removeAt(3), removeAt(1)) until a step was inserted above them, at
    // which point removeAt(3) silently deleted Al-Fatiha, which is required
    // in every round, instead of the optional short chapter. Titles cannot
    // shift when the list is edited.
    if (i > 2) {
      // 3rd and 4th rak'ah: only Al-Fatiha, no extra surah.
      rakahSteps.removeWhere((s) => s.title == 'Recite a Short Chapter');
    }
    if (i > 1) {
      // Opening supplication only in the first rak'ah.
      rakahSteps.removeWhere((s) => s.title == 'Opening Supplication');
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
    steps: _buildSteps('Fajr', 2),
  ),
  Prayer(
    name: 'Dhuhr',
    arabicName: 'الظهر',
    rakatCount: 4,
    timeDescription: 'Midday, after the sun passes its zenith',
    steps: _buildSteps('Dhuhr', 4),
  ),
  Prayer(
    name: 'Asr',
    arabicName: 'العصر',
    rakatCount: 4,
    timeDescription: 'Afternoon, when shadows equal object length',
    steps: _buildSteps('Asr', 4),
  ),
  Prayer(
    name: 'Maghrib',
    arabicName: 'المغرب',
    rakatCount: 3,
    timeDescription: 'Sunset, just after the sun sets',
    steps: _buildSteps('Maghrib', 3),
  ),
  Prayer(
    name: 'Isha',
    arabicName: 'العشاء',
    rakatCount: 4,
    timeDescription: 'Night, after twilight disappears',
    steps: _buildSteps('Isha', 4),
  ),
];
