import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prayer_guide/data/qibla.dart';
import 'package:prayer_guide/screens/qibla_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: QiblaScreen()));
    await tester.pumpAndSettle();
  }

  group('the instructions', () {
    testWidgets('are on the screen', (tester) async {
      await open(tester);
      expect(find.text('How to use it'), findsOneWidget);
    });

    testWidgets('explain how to find north', (tester) async {
      await open(tester);

      expect(find.text('Finding north without the phone'), findsOneWidget);
      expect(find.textContaining('sun rises'), findsOneWidget);
      expect(find.textContaining('Pole Star'), findsOneWidget);
      expect(find.textContaining('shadow'), findsWidgets);
    });

    testWidgets('warn about what throws the reading off', (tester) async {
      await open(tester);

      expect(find.text('What throws it off'), findsOneWidget);
      expect(find.textContaining('Metal and magnets'), findsOneWidget);
      expect(find.textContaining('figure of eight'), findsOneWidget);
      expect(find.textContaining('true north'), findsWidgets);
    });

    testWidgets('tell you to stand facing north when there is no compass',
        (tester) async {
      // The test environment has no magnetometer, so this is the fallback.
      await open(tester);

      expect(find.text('Stand facing north.'), findsOneWidget);
      expect(find.textContaining('no compass'), findsOneWidget);
    });

    test('the moving instruction says body and phone turn together', () {
      // Reading the source directly, since the test environment has no
      // compass and never renders the steps that mention turning.
      final source = File(
        'lib/screens/qibla_screen.dart',
      ).readAsStringSync();

      expect(source, contains('you and the phone turn together'));
      expect(source, contains('Do not '));
      expect(source, contains('spin the phone by itself'));
      expect(source, isNot(contains('Turn your whole body slowly')),
          reason: 'the old wording read as spinning the phone alone');
    });

    testWidgets('give the turn from north for the chosen city',
        (tester) async {
      await open(tester);

      // London Ontario is 53 degrees, so a right turn towards the north east.
      expect(find.textContaining('53 degrees to your right'), findsOneWidget);
      expect(find.textContaining('NE'), findsWidgets);
    });
  });

  group('the turn from north', () {
    /// Mirrors the rule the screen uses: bearings up to half a circle turn
    /// right, the rest turn left by the shorter way round.
    ({String side, int degrees}) turn(double bearing) {
      if (bearing <= 180) {
        return (side: 'right', degrees: bearing.round());
      }
      return (side: 'left', degrees: (360 - bearing).round());
    }

    test('goes right for an easterly qibla', () {
      // London Ontario, 53 degrees.
      expect(turn(53.3), (side: 'right', degrees: 53));
      // London UK, 119 degrees.
      expect(turn(119.0), (side: 'right', degrees: 119));
    });

    test('goes left for a westerly qibla, by the shorter way', () {
      // Jakarta, 295 degrees, is a 65 degree turn to the left rather than
      // a 295 degree turn to the right.
      expect(turn(295.2), (side: 'left', degrees: 65));
      // Sydney, 277 degrees.
      expect(turn(277.5), (side: 'left', degrees: 83));
    });

    test('never asks for more than half a turn', () {
      for (final city in Qibla.cities) {
        final bearing = Qibla.bearingFrom(city.latitude, city.longitude);
        expect(turn(bearing).degrees, lessThanOrEqualTo(180),
            reason: '${city.label} would need a longer turn than necessary');
      }
    });
  });
}
