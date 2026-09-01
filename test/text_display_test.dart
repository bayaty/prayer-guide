import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prayer_guide/data/app_settings.dart';
import 'package:prayer_guide/data/prayer_data.dart';
import 'package:prayer_guide/screens/prayer_steps_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.load();
  });

  tearDown(() async {
    await AppSettings.instance.setShowArabic(true);
    await AppSettings.instance.setShowTransliteration(true);
    await AppSettings.instance.setShowTranslation(true);
  });

  group('the settings themselves', () {
    test('all three default to on', () {
      final s = AppSettings.instance;
      expect(s.showArabic, isTrue);
      expect(s.showTransliteration, isTrue);
      expect(s.showTranslation, isTrue);
      expect(s.hideAllText, isFalse);
    });

    test('each persists across a restart', () async {
      await AppSettings.instance.setShowArabic(false);
      await AppSettings.instance.setShowTransliteration(false);
      await AppSettings.instance.load();

      expect(AppSettings.instance.showArabic, isFalse);
      expect(AppSettings.instance.showTransliteration, isFalse);
      expect(AppSettings.instance.showTranslation, isTrue,
          reason: 'untouched settings should keep their default');
    });

    test('hideAllText only reports true when all three are off', () async {
      final s = AppSettings.instance;

      await s.setShowArabic(false);
      expect(s.hideAllText, isFalse);

      await s.setShowTransliteration(false);
      expect(s.hideAllText, isFalse);

      await s.setShowTranslation(false);
      expect(s.hideAllText, isTrue);
    });

    test('saved values are picked up on a cold start', () async {
      SharedPreferences.setMockInitialValues({
        'show_arabic': false,
        'show_transliteration': true,
        'show_translation': false,
      });
      await AppSettings.instance.load();

      expect(AppSettings.instance.showArabic, isFalse);
      expect(AppSettings.instance.showTransliteration, isTrue);
      expect(AppSettings.instance.showTranslation, isFalse);
    });
  });

  group('the prayer step screen honours them', () {
    Future<void> open(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(home: PrayerStepsScreen(prayer: prayers.first)),
      );
      await tester.pumpAndSettle();
    }

    /// Opens on a step that actually carries a supplication, since the first
    /// step is the intention and has no text of its own.
    Future<void> openStepWithText(WidgetTester tester) async {
      await open(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    testWidgets('all three headings show by default', (tester) async {
      await openStepWithText(tester);

      expect(find.text('Arabic'), findsOneWidget);
      expect(find.text('Transliteration'), findsOneWidget);
      expect(find.text('Translation'), findsOneWidget);
    });

    testWidgets('turning off Arabic removes only that section',
        (tester) async {
      await AppSettings.instance.setShowArabic(false);
      await openStepWithText(tester);

      expect(find.text('Arabic'), findsNothing);
      expect(find.text('Transliteration'), findsOneWidget);
      expect(find.text('Translation'), findsOneWidget);
    });

    testWidgets('turning off transliteration removes only that section',
        (tester) async {
      await AppSettings.instance.setShowTransliteration(false);
      await openStepWithText(tester);

      expect(find.text('Arabic'), findsOneWidget);
      expect(find.text('Transliteration'), findsNothing);
      expect(find.text('Translation'), findsOneWidget);
    });

    testWidgets('turning off translation removes only that section',
        (tester) async {
      await AppSettings.instance.setShowTranslation(false);
      await openStepWithText(tester);

      expect(find.text('Arabic'), findsOneWidget);
      expect(find.text('Transliteration'), findsOneWidget);
      expect(find.text('Translation'), findsNothing);
    });

    testWidgets('three sections are separated by two dividers',
        (tester) async {
      await openStepWithText(tester);
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('two sections leave a single divider', (tester) async {
      await AppSettings.instance.setShowArabic(false);
      await openStepWithText(tester);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('one section leaves no divider', (tester) async {
      await AppSettings.instance.setShowArabic(false);
      await AppSettings.instance.setShowTransliteration(false);
      await openStepWithText(tester);

      expect(find.byType(Divider), findsNothing,
          reason: 'a lone section should not be followed by a divider');
      expect(find.text('Translation'), findsOneWidget);
    });

    testWidgets('a step with no supplication shows no empty text card',
        (tester) async {
      await open(tester);

      // The prayer opens on the intention, which carries no Arabic,
      // transliteration or translation. None of the headings belong there.
      final intention =
          prayers.first.steps.firstWhere((s) => s.title.startsWith('Intend to pray'));
      expect(intention.arabicText.trim(), isEmpty);
      expect(intention.translation.trim(), isEmpty);

      expect(find.text('Arabic'), findsNothing,
          reason: 'an empty step should not show an Arabic heading');
      expect(find.text('Transliteration'), findsNothing);
      expect(find.text('Translation'), findsNothing,
          reason: 'an empty step should not show an orphan Translation card');
    });

    testWidgets('a step that has text still shows its sections',
        (tester) async {
      await open(tester);

      // Move to the standing position, which carries the opening Takbir.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Arabic'), findsOneWidget);
      expect(find.text('Translation'), findsOneWidget);
    });

    testWidgets('hiding all three leaves no headings and no dividers',
        (tester) async {
      await AppSettings.instance.setShowArabic(false);
      await AppSettings.instance.setShowTransliteration(false);
      await AppSettings.instance.setShowTranslation(false);
      await openStepWithText(tester);

      expect(find.text('Arabic'), findsNothing);
      expect(find.text('Transliteration'), findsNothing);
      expect(find.text('Translation'), findsNothing);
      expect(find.byType(Divider), findsNothing);

      // The step itself must still be usable.
      expect(find.textContaining('Stand upright'), findsWidgets,
          reason: 'the instruction text must survive');
    });
  });

}
