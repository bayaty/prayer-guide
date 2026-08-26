import 'package:flutter_test/flutter_test.dart';

import 'package:prayer_guide/data/azan_times.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AzanTimes.instance.load();
  });

  group('the bundled table', () {
    test('covers every day of 2026', () {
      var day = DateTime(2026, 1, 1);
      var count = 0;

      while (day.year == 2026) {
        expect(AzanTimes.instance.forDate(day), isNotNull,
            reason: 'missing ${day.toIso8601String()}');
        count++;
        day = day.add(const Duration(days: 1));
      }

      expect(count, 365);
    });

    test('stays aligned across the clock changes', () {
      // A local DateTime difference is 25 hours long on the day the clocks go
      // back, which truncated to the previous day and shifted every lookup
      // after November 1 by one day.
      final oct31 = AzanTimes.instance.forDate(DateTime(2026, 10, 31))!;
      expect(AzanTimes.format(oct31.shrooq), '7:58 am');

      final nov1 = AzanTimes.instance.forDate(DateTime(2026, 11, 1))!;
      expect(AzanTimes.format(nov1.shrooq), '6:59 am');

      // And the spring change, where a day is only 23 hours long.
      final mar7 = AzanTimes.instance.forDate(DateTime(2026, 3, 7))!;
      expect(AzanTimes.format(mar7.shrooq), '6:49 am');

      final mar8 = AzanTimes.instance.forDate(DateTime(2026, 3, 8))!;
      expect(AzanTimes.format(mar8.shrooq), '7:48 am');

      // The last day of the year must still be the last row.
      final dec31 = AzanTimes.instance.forDate(DateTime(2026, 12, 31))!;
      expect(AzanTimes.format(dec31.fajr), '6:31 am');
      expect(AzanTimes.format(dec31.zuhr), '12:29 pm');
    });

    test('returns nothing for a year it does not cover', () {
      expect(AzanTimes.instance.forDate(DateTime(2025, 6, 1)), isNull);
      expect(AzanTimes.instance.forDate(DateTime(2027, 6, 1)), isNull);
    });
  });

  group('the times themselves', () {
    /// Spot checks taken from the mosque timetable. The sheet labels its rows
    /// a day behind, so these were confirmed against the weekday column.
    test('match the timetable on known dates', () {
      final jan1 = AzanTimes.instance.forDate(DateTime(2026, 1, 1))!;
      expect(AzanTimes.format(jan1.fajr), '6:31 am');
      expect(AzanTimes.format(jan1.shrooq), '7:55 am');
      expect(AzanTimes.format(jan1.zuhr), '12:30 pm');
      expect(AzanTimes.format(jan1.maghreb), '5:03 pm');

      final solstice = AzanTimes.instance.forDate(DateTime(2026, 6, 21))!;
      expect(AzanTimes.format(solstice.fajr), '3:58 am');
      expect(AzanTimes.format(solstice.maghreb), '9:09 pm');
      expect(AzanTimes.format(solstice.isha), '10:39 pm');

      final dec31 = AzanTimes.instance.forDate(DateTime(2026, 12, 31))!;
      expect(AzanTimes.format(dec31.fajr), '6:31 am');
      expect(AzanTimes.format(dec31.maghreb), '5:02 pm');
    });

    test('run in order on every single day', () {
      var day = DateTime(2026, 1, 1);

      while (day.year == 2026) {
        final t = AzanTimes.instance.forDate(day)!;
        final ordered = [t.fajr, t.shrooq, t.zuhr, t.asr, t.maghreb, t.isha];

        for (var i = 1; i < ordered.length; i++) {
          expect(ordered[i], greaterThan(ordered[i - 1]),
              reason: 'out of order on ${day.toIso8601String()}');
        }
        day = day.add(const Duration(days: 1));
      }
    });

    test('stay inside a single day', () {
      var day = DateTime(2026, 1, 1);

      while (day.year == 2026) {
        final t = AzanTimes.instance.forDate(day)!;
        for (final m in [t.fajr, t.shrooq, t.zuhr, t.asr, t.maghreb, t.isha]) {
          expect(m, inInclusiveRange(0, 24 * 60 - 1));
        }
        day = day.add(const Duration(days: 1));
      }
    });

    test('shift by about an hour when the clocks change', () {
      // Daylight saving starts March 8 and ends November 1.
      final beforeSpring =
          AzanTimes.instance.forDate(DateTime(2026, 3, 7))!.shrooq;
      final afterSpring =
          AzanTimes.instance.forDate(DateTime(2026, 3, 8))!.shrooq;
      expect(afterSpring - beforeSpring, inInclusiveRange(55, 65));

      final beforeAutumn =
          AzanTimes.instance.forDate(DateTime(2026, 10, 31))!.shrooq;
      final afterAutumn =
          AzanTimes.instance.forDate(DateTime(2026, 11, 1))!.shrooq;
      // Clocks go back, so sunrise lands an hour earlier.
      expect(beforeAutumn - afterAutumn, inInclusiveRange(55, 65));
    });

    test('move only gradually on ordinary days', () {
      var day = DateTime(2026, 1, 1);
      final clockChanges = {'2026-03-08', '2026-11-01'};

      while (day.isBefore(DateTime(2026, 12, 31))) {
        final next = day.add(const Duration(days: 1));
        final key = next.toIso8601String().split('T').first;

        if (!clockChanges.contains(key)) {
          final a = AzanTimes.instance.forDate(day)!.fajr;
          final b = AzanTimes.instance.forDate(next)!.fajr;
          expect((b - a).abs(), lessThanOrEqualTo(5),
              reason: 'Fajr jumped between $day and $next');
        }
        day = next;
      }
    });
  });

  group('lookups', () {
    test('resolve the app\'s prayer names', () {
      final t = AzanTimes.instance.forDate(DateTime(2026, 1, 1))!;

      expect(t.forPrayer('Fajr'), t.fajr);
      expect(t.forPrayer('Dhuhr'), t.zuhr, reason: 'the app says Dhuhr');
      expect(t.forPrayer('Asr'), t.asr);
      expect(t.forPrayer('Maghrib'), t.maghreb, reason: 'the app says Maghrib');
      expect(t.forPrayer('Isha'), t.isha);
      expect(t.forPrayer('Nonsense'), isNull);
    });

    test('format as a readable clock time', () {
      expect(AzanTimes.format(0), '12:00 am');
      expect(AzanTimes.format(60), '1:00 am');
      expect(AzanTimes.format(12 * 60), '12:00 pm');
      expect(AzanTimes.format(13 * 60 + 5), '1:05 pm');
      expect(AzanTimes.format(23 * 60 + 59), '11:59 pm');
    });
  });
}
