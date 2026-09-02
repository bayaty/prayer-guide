import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_guide/data/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:prayer_guide/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The update checker downloads an APK and asks Android to install it. On the
/// web there is no APK and the app updates when the page reloads, so the
/// control would only ever report a version the user cannot act on.
void main() {
  testWidgets('the update section follows the platform', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.load();

    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();

    if (kIsWeb) {
      expect(find.text('App Updates'), findsNothing,
          reason: 'the web build has no APK to install');
      expect(find.textContaining('Check for updates'), findsNothing);
      expect(find.textContaining('GitHub Releases'), findsNothing);
    } else {
      expect(find.text('App Updates'), findsOneWidget,
          reason: 'the mobile build installs its own APK');
    }
  });

  testWidgets('the rest of settings is present either way', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.load();

    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();

    // Removing the update card must not take the rest of the screen with it.
    expect(find.text('Qibla Compass'), findsOneWidget);
    expect(find.text('Step Text'), findsOneWidget);
  });
}
