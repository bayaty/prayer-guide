import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_guide/data/app_settings.dart';
import 'package:prayer_guide/data/prayer_data.dart';
import 'package:prayer_guide/widgets/step_detail_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The recitation used to sit in a second Card below the step, so the words
/// being taught were visually detached from the instruction introducing them
/// ("...and say the line:" followed by a gap, then a separate box).
///
/// They are one thought and belong in one card.
void main() {
  testWidgets('the recitation shares the step card', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.load();

    // The standing step: an instruction that introduces a recitation.
    final step = prayers.first.steps
        .firstWhere((s) => s.transliteration.contains('Allahu Akbar'));

    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: StepDetailCard(step: step, stepNumber: 2)),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Transliteration'), findsOneWidget);

    // One card, not two: the instruction and what it introduces stay together.
    expect(find.byType(Card), findsOneWidget,
        reason: 'the recitation must not sit in a card of its own');
  });
}
