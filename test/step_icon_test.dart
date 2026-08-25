import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prayer_guide/data/prayer_data.dart';
import 'package:prayer_guide/data/wudu_data.dart';
import 'package:prayer_guide/widgets/step_icon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every posture asset declared in pubspec actually loads', () async {
    for (final name in [
      'standing',
      'bowing',
      'prostrating',
      'sitting',
      'hands',
    ]) {
      final path = StepIcon.pathFor(name);
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(1000),
          reason: '$path is missing or suspiciously small');
    }
  });

  testWidgets('body-posture icons render as images, not emoji text',
      (tester) async {
    for (final emoji in ['🧍', '🙇', '🤲', '🧎']) {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StepIcon(emoji))),
      );
      expect(find.byType(Image), findsOneWidget,
          reason: '$emoji should use a faceless asset');
      expect(find.text(emoji), findsNothing,
          reason: '$emoji should not render as raw emoji text');
    }
  });

  testWidgets('posture: prefix resolves to an asset', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: StepIcon('posture:prostrating'))),
    );
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('non-body emoji still render as text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: StepIcon('📖'))),
    );
    expect(find.text('📖'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  test('no body-posture emoji remain in the step data', () {
    const bodyEmoji = ['🧍', '🙇', '🤲', '🧎', '🕌'];
    final offenders = <String>[];

    for (final p in prayers) {
      for (final s in p.steps) {
        if (bodyEmoji.contains(s.icon)) offenders.add('${p.name}: ${s.title}');
      }
    }
    for (final s in wuduSteps) {
      if (bodyEmoji.contains(s.icon)) offenders.add('wudu: ${s.title}');
    }

    expect(offenders, isEmpty,
        reason: 'these steps still use a body emoji: $offenders');
  });
}
