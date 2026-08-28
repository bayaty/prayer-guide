import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prayer_guide/data/app_settings.dart';
import 'package:prayer_guide/data/practice_mode.dart';
import 'package:prayer_guide/data/prayer_data.dart';
import 'package:prayer_guide/screens/prayer_screen.dart';
import 'package:prayer_guide/screens/prayer_steps_screen.dart';
import 'package:prayer_guide/widgets/step_detail_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.load();
  });

  tearDown(() async {
    await AppSettings.instance.setFullDetail(false);
    await AppSettings.instance.setShowArabic(true);
    await AppSettings.instance.setShowTransliteration(true);
    await AppSettings.instance.setShowTranslation(true);
    await AppSettings.instance.setExtraSunnahs(true);
  });

  group('the setting itself', () {
    test('defaults to off, so existing users keep the overview', () {
      expect(AppSettings.instance.fullDetail, isFalse);
    });

    test('survives a restart', () async {
      await AppSettings.instance.setFullDetail(true);
      await AppSettings.instance.load();
      expect(AppSettings.instance.fullDetail, isTrue);
    });

    test('a saved value is picked up on a cold start', () async {
      SharedPreferences.setMockInitialValues({'full_detail': true});
      await AppSettings.instance.load();
      expect(AppSettings.instance.fullDetail, isTrue);
    });

    test('notifies listeners exactly once per real change', () async {
      final s = AppSettings.instance;
      var calls = 0;
      void listener() => calls++;
      s.addListener(listener);
      addTearDown(() => s.removeListener(listener));

      await s.setFullDetail(true);
      expect(calls, 1);

      // Setting the same value again should be a no-op.
      await s.setFullDetail(true);
      expect(calls, 1, reason: 'an unchanged value should not notify');

      await s.setFullDetail(false);
      expect(calls, 2);
    });

    test('it is independent of the other text settings', () async {
      await AppSettings.instance.setFullDetail(true);
      await AppSettings.instance.setShowArabic(false);

      expect(AppSettings.instance.fullDetail, isTrue,
          reason: 'hiding Arabic must not disturb the layout choice');
      expect(AppSettings.instance.showTranslation, isTrue);
    });
  });

  group('the prayer screen layout', () {
    Future<void> open(WidgetTester tester, Prayer prayer) async {
      tester.view.physicalSize = const Size(1200, 20000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(home: PrayerScreen(prayer: prayer)));
      await tester.pumpAndSettle();
    }

    testWidgets('off shows the compact overview and no full cards',
        (tester) async {
      await open(tester, prayers.first);

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('All Steps'), findsNothing);
      expect(find.byType(StepDetailCard), findsNothing,
          reason: 'the overview should stay a short list of names');
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('on writes every visible step out in full', (tester) async {
      await AppSettings.instance.setFullDetail(true);
      await open(tester, prayers.first);

      final visible = PracticeMode.instance
          .filter<PrayerStep>(prayers.first.steps, (s) => s.level);

      expect(find.text('All Steps'), findsOneWidget);
      expect(find.text('Overview'), findsNothing);
      expect(find.byType(StepDetailCard), findsNWidgets(visible.length),
          reason: 'every visible step should get its own full card');
    });

    testWidgets('on shows the actual instruction text, not just a title',
        (tester) async {
      await AppSettings.instance.setFullDetail(true);
      await open(tester, prayers.first);

      // The point of the mode: a learner reads the wording without tapping.
      expect(find.textContaining('Stand facing'), findsWidgets);
      expect(find.textContaining('Allahu Akbar'), findsWidgets);
    });

    testWidgets('off hides that instruction text behind a tap',
        (tester) async {
      await open(tester, prayers.first);
      expect(find.textContaining('Stand facing'), findsNothing);
    });

    testWidgets('each full card carries its step number', (tester) async {
      await AppSettings.instance.setFullDetail(true);
      await open(tester, prayers.first);

      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Step 2'), findsOneWidget);
    });

    testWidgets('the numbering has no gaps and matches the visible count',
        (tester) async {
      await AppSettings.instance.setFullDetail(true);
      await open(tester, prayers.first);

      final visible = PracticeMode.instance
          .filter<PrayerStep>(prayers.first.steps, (s) => s.level);

      for (var i = 1; i <= visible.length; i++) {
        expect(find.text('Step $i'), findsOneWidget,
            reason: 'step $i should appear exactly once');
      }
      expect(find.text('Step ${visible.length + 1}'), findsNothing,
          reason: 'numbering must stop at the last visible step');
    });

    testWidgets('bare minimum mode still filters the full cards',
        (tester) async {
      await AppSettings.instance.setFullDetail(true);
      await AppSettings.instance.setExtraSunnahs(false);
      await open(tester, prayers.first);

      final essential = prayers.first.steps
          .where((s) => s.level == StepLevel.essential)
          .length;

      expect(find.byType(StepDetailCard), findsNWidgets(essential));
      expect(essential, lessThan(prayers.first.steps.length),
          reason: 'the fixture must actually contain sunnah steps');
    });

    testWidgets('the text settings still apply inside the full cards',
        (tester) async {
      await AppSettings.instance.setFullDetail(true);
      await AppSettings.instance.setShowArabic(false);
      await open(tester, prayers.first);

      expect(find.text('Arabic'), findsNothing,
          reason: 'hiding Arabic must hold in the long read too');
      expect(find.text('Translation'), findsWidgets);
    });

    testWidgets('switching the setting swaps the layout without a reopen',
        (tester) async {
      await open(tester, prayers.first);
      expect(find.text('Overview'), findsOneWidget);

      await AppSettings.instance.setFullDetail(true);
      await tester.pumpAndSettle();

      expect(find.text('All Steps'), findsOneWidget,
          reason: 'the screen listens for the change while open');
      expect(find.byType(StepDetailCard), findsWidgets);
    });

    testWidgets('a full card opens the paged guide at that step',
        (tester) async {
      await AppSettings.instance.setFullDetail(true);
      await open(tester, prayers.first);

      // Tap the second step's card and check the guide lands on step 2.
      await tester.tap(find.text('Step 2'));
      await tester.pumpAndSettle();

      expect(find.byType(PrayerStepsScreen), findsOneWidget);
      expect(find.text('Step 2 of ${PracticeMode.instance.filter<PrayerStep>(prayers.first.steps, (s) => s.level).length}'),
          findsOneWidget);
    });
  });

  group('the paged guide is unaffected by the setting', () {
    Future<void> openGuide(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(home: PrayerStepsScreen(prayer: prayers.first)),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('it still shows one step at a time with full detail on',
        (tester) async {
      await AppSettings.instance.setFullDetail(true);
      await openGuide(tester);

      // A PageView builds neighbours, but the counter must still read step 1.
      expect(find.text('Step 1 of ${PracticeMode.instance.filter<PrayerStep>(prayers.first.steps, (s) => s.level).length}'),
          findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('its cards carry no step number badge', (tester) async {
      await openGuide(tester);

      // The badge belongs to the reading list; the guide has its own counter.
      expect(find.text('Step 1'), findsNothing,
          reason: 'the paged guide should not double up on numbering');
    });
  });
}
