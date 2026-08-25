// Smoke test for the Prayer Guide app shell.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prayer_guide/main.dart';

void main() {
  testWidgets('app boots and shows the Wudu tab', (WidgetTester tester) async {
    await tester.pumpWidget(const SalahGuideApp());
    await tester.pump();

    // The first tab is Wudu, and its header should be on screen.
    expect(find.text('Wudu'), findsWidgets);

    // The bottom navigation exposes all five prayers alongside Wudu.
    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      expect(find.text(label), findsOneWidget, reason: '$label tab missing');
    }
  });
}
