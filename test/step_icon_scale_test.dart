import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prayer_guide/widgets/step_icon.dart';

void main() {
  testWidgets('posture assets render larger than the nominal size',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StepIcon('🧍', size: 24))),
    );

    final img = tester.widget<Image>(find.byType(Image));
    expect(img.width, 24 * StepIcon.assetScale);
    expect(img.height, 24 * StepIcon.assetScale);
    expect(StepIcon.assetScale, 1.75);
  });

  testWidgets('emoji icons are NOT scaled up', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StepIcon('📖', size: 24))),
    );

    final text = tester.widget<Text>(find.text('📖'));
    // Emoji keep the original sizing rule (size * 0.85), untouched by
    // assetScale.
    expect(text.style?.fontSize, 24 * 0.85);
  });

  testWidgets('scaled icons do not overflow a typical card row',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: Row(
              children: [
                const StepIcon('posture:prostrating', size: 56),
                const SizedBox(width: 8),
                Expanded(child: Text('Second Prostration (Sujud)')),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
