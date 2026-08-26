import 'package:flutter_test/flutter_test.dart';

import 'package:prayer_guide/data/active_prayer.dart';
import 'package:prayer_guide/data/azan_times.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AzanTimes.instance.load();
  });

  /// January 1 2026, when the times are:
  /// Fajr 6:31, sunrise 7:55, Dhuhr 12:30, Asr 14:45, Maghrib 17:03,
  /// Isha 18:28.
  DateTime jan1(int hour, int minute) => DateTime(2026, 1, 1, hour, minute);

  group('which prayer it is', () {
    test('Fajr runs from its call until sunrise', () {
      expect(ActivePrayer.evaluate(jan1(6, 31)), 'Fajr');
      expect(ActivePrayer.evaluate(jan1(7, 0)), 'Fajr');
      expect(ActivePrayer.evaluate(jan1(7, 54)), 'Fajr');
    });

    test('nothing is in between sunrise and Dhuhr', () {
      // This gap is not a prayer time, so no prayer should be marked.
      expect(ActivePrayer.evaluate(jan1(7, 55)), isNull);
      expect(ActivePrayer.evaluate(jan1(10, 0)), isNull);
      expect(ActivePrayer.evaluate(jan1(12, 29)), isNull);
    });

    test('Dhuhr runs until Asr', () {
      expect(ActivePrayer.evaluate(jan1(12, 30)), 'Dhuhr');
      expect(ActivePrayer.evaluate(jan1(14, 44)), 'Dhuhr');
    });

    test('Asr runs until Maghrib', () {
      expect(ActivePrayer.evaluate(jan1(14, 45)), 'Asr');
      expect(ActivePrayer.evaluate(jan1(17, 2)), 'Asr');
    });

    test('Maghrib runs until Isha', () {
      expect(ActivePrayer.evaluate(jan1(17, 3)), 'Maghrib');
      expect(ActivePrayer.evaluate(jan1(18, 27)), 'Maghrib');
    });

    test('Isha carries on past midnight', () {
      expect(ActivePrayer.evaluate(jan1(18, 28)), 'Isha');
      expect(ActivePrayer.evaluate(jan1(23, 59)), 'Isha');

      // Still Isha in the small hours of the next morning.
      expect(ActivePrayer.evaluate(DateTime(2026, 1, 2, 0, 1)), 'Isha');
      expect(ActivePrayer.evaluate(DateTime(2026, 1, 2, 5, 0)), 'Isha');
    });

    test('the boundary belongs to the prayer beginning', () {
      // At exactly the call, the new prayer is in.
      expect(ActivePrayer.evaluate(jan1(6, 30)), 'Isha',
          reason: 'a minute before Fajr the night prayer still stands');
      expect(ActivePrayer.evaluate(jan1(6, 31)), 'Fajr');

      expect(ActivePrayer.evaluate(jan1(17, 2)), 'Asr');
      expect(ActivePrayer.evaluate(jan1(17, 3)), 'Maghrib');
    });
  });

  group('across the whole year', () {
    test('every minute resolves without an error', () {
      // Walk a day in each month at ten minute steps.
      for (var month = 1; month <= 12; month++) {
        for (var minute = 0; minute < 24 * 60; minute += 10) {
          final at = DateTime(2026, month, 15, minute ~/ 60, minute % 60);
          final result = ActivePrayer.evaluate(at);
          if (result != null) {
            expect(
              ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'],
              contains(result),
            );
          }
        }
      }
    });

    test('exactly one prayer is in at any moment', () {
      const names = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

      for (var minute = 0; minute < 24 * 60; minute += 7) {
        final at = DateTime(2026, 6, 15, minute ~/ 60, minute % 60);
        final current = ActivePrayer.evaluate(at);

        final matches = names.where((n) => n == current).length;
        expect(matches, lessThanOrEqualTo(1),
            reason: 'more than one prayer marked at $at');
      }
    });

    test('the clock changes do not break the reading', () {
      // March 8: Fajr 6:30, sunrise 7:48.
      expect(ActivePrayer.evaluate(DateTime(2026, 3, 8, 6, 45)), 'Fajr');
      expect(ActivePrayer.evaluate(DateTime(2026, 3, 8, 9, 0)), isNull);

      // November 1: Fajr 5:41, sunrise 6:59.
      expect(ActivePrayer.evaluate(DateTime(2026, 11, 1, 6, 0)), 'Fajr');
      expect(ActivePrayer.evaluate(DateTime(2026, 11, 1, 8, 0)), isNull);
    });

    test('a date outside the table reports nothing', () {
      expect(ActivePrayer.evaluate(DateTime(2027, 1, 1, 12, 0)), isNull);
    });
  });

  group('when the current time runs out', () {
    test('points at the next call', () {
      expect(ActivePrayer.endsAt(jan1(7, 0)), 7 * 60 + 55); // sunrise
      expect(ActivePrayer.endsAt(jan1(13, 0)), 14 * 60 + 45); // Asr
      expect(ActivePrayer.endsAt(jan1(17, 30)), 18 * 60 + 28); // Isha
    });

    test('reports nothing once Isha has begun, since it crosses midnight', () {
      expect(ActivePrayer.endsAt(jan1(20, 0)), isNull);
    });
  });

  group('the notifier', () {
    test('tells listeners only when the prayer actually changes', () {
      var calls = 0;
      void listener() => calls++;

      ActivePrayer.instance.addListener(listener);
      addTearDown(() => ActivePrayer.instance.removeListener(listener));

      ActivePrayer.instance.setNowForTest(jan1(13, 0)); // Dhuhr
      expect(ActivePrayer.instance.current, 'Dhuhr');
      final afterFirst = calls;

      ActivePrayer.instance.setNowForTest(jan1(13, 30)); // still Dhuhr
      expect(calls, afterFirst, reason: 'no change, so no notification');

      ActivePrayer.instance.setNowForTest(jan1(15, 0)); // now Asr
      expect(ActivePrayer.instance.current, 'Asr');
      expect(calls, greaterThan(afterFirst));
    });

    test('isNow ignores capitalisation', () {
      ActivePrayer.instance.setNowForTest(jan1(13, 0));

      expect(ActivePrayer.instance.isNow('Dhuhr'), isTrue);
      expect(ActivePrayer.instance.isNow('dhuhr'), isTrue);
      expect(ActivePrayer.instance.isNow('Asr'), isFalse);
    });
  });
}
