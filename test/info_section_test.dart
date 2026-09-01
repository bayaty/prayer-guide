import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prayer_guide/data/prayer_data.dart';
import 'package:prayer_guide/data/wudu_data.dart';
import 'package:prayer_guide/widgets/info_section.dart';

void main() {
  test('prostration info points to dua, sitting explains the pause', () {
    final steps = prayers.first.steps;
    final sujud = steps.firstWhere((s) => s.title.contains('First Prostration'));
    final between =
        steps.firstWhere((s) => s.title.contains('Sitting Between'));

    expect(sujud.info.toLowerCase(), contains('dua'));
    expect(sujud.info.toLowerCase(), contains('nearest'));
    // The beginner sitting says nothing; its note explains the rest
    // and records the words used once the prayer is settled.
    expect(between.info.toLowerCase(), contains('rest'));
    expect(between.info.toLowerCase(), contains('forgive me'));
  });

  test('info text contains no em dashes or smart quotes', () {
    final offenders = <String>[];
    void check(String label, String text) {
      if (RegExp(r'[\u2014\u2013\u2018\u2019\u201C\u201D]').hasMatch(text)) {
        offenders.add(label);
      }
    }

    for (final p in prayers) {
      for (final s in p.steps) {
        check('${p.name}/${s.title}', s.info);
      }
    }
    for (final s in wuduSteps) {
      check('wudu/${s.title}', s.info);
    }
    expect(offenders, isEmpty, reason: 'bad punctuation in: $offenders');
  });

  testWidgets('info is hidden until the button is tapped', (tester) async {
    const body = 'The servant is nearest to Allah in this position.';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: InfoSection(body))),
      ),
    );

    // Collapsed: the button shows, and the info text is not visible.
    expect(find.text('Show more info'), findsOneWidget);
    expect(find.text('Hide info'), findsNothing);

    // AnimatedCrossFade keeps both children mounted, so assert on the
    // crossfade state rather than on whether the widget exists.
    AnimatedCrossFade fade() =>
        tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade));
    expect(fade().crossFadeState, CrossFadeState.showFirst,
        reason: 'info should be collapsed at first');

    // Expand.
    await tester.tap(find.text('Show more info'));
    await tester.pumpAndSettle();

    expect(find.text('Hide info'), findsOneWidget);
    expect(fade().crossFadeState, CrossFadeState.showSecond);
    expect(find.text(body), findsOneWidget);

    // Collapse again.
    await tester.tap(find.text('Hide info'));
    await tester.pumpAndSettle();
    expect(find.text('Show more info'), findsOneWidget);
    expect(fade().crossFadeState, CrossFadeState.showFirst);
  });

  testWidgets('an empty info string renders nothing at all', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: InfoSection(''))),
    );
    expect(find.text('Show more info'), findsNothing);
  });
}
