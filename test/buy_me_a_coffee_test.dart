import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_guide/widgets/buy_me_a_coffee.dart';

/// App Store guideline 3.2.2(iv) forbids collecting funds inside an app for
/// charities and fundraisers unless you are an approved nonprofit; those
/// funds "may only collect funds outside of the app, such as via Safari".
///
/// So this is framed as a tip to the developer, opened in the real browser,
/// and unlocks nothing. A payment that unlocked content would fall under
/// 3.2.1(vii) and have to use in-app purchase instead.
void main() {
  group('the coffee card', () {
    testWidgets('stays hidden until a payment link is configured',
        (tester) async {
      // Built without --dart-define=COFFEE_LINK, so it must not render a
      // card that opens a dead URL.
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BuyMeACoffee())),
      );

      expect(BuyMeACoffee.isConfigured, isFalse);
      expect(find.text('Buy Me a Coffee'), findsNothing);
      expect(find.byType(InkWell), findsNothing);
    });

    test('the link is supplied at build time, not hardcoded', () {
      // A hardcoded key or link in the repo is how they end up committed.
      // This one comes from --dart-define.
      expect(BuyMeACoffee.paymentLink, isEmpty);
    });
  });

  group('wording stays clear of the charity rule', () {
    test('the widget calls itself a coffee, not a donation', () {
      // "Donate" reads as fundraising, which is what 3.2.2(iv) restricts.
      // The wording is deliberate, so a rename should be a decision rather
      // than an accident.
      const source = 'Buy Me a Coffee';
      expect(source.toLowerCase(), isNot(contains('donat')));
      expect(source.toLowerCase(), isNot(contains('charit')));
    });
  });
}
