import 'dart:convert';

import 'package:flutter/services.dart';

/// The six daily times, in minutes past midnight.
class AzanDay {
  final int fajr;
  final int shrooq;
  final int zuhr;
  final int asr;
  final int maghreb;
  final int isha;

  const AzanDay({
    required this.fajr,
    required this.shrooq,
    required this.zuhr,
    required this.asr,
    required this.maghreb,
    required this.isha,
  });

  /// Looks a time up by the prayer name used elsewhere in the app.
  int? forPrayer(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
        return fajr;
      case 'shrooq':
      case 'sunrise':
        return shrooq;
      case 'dhuhr':
      case 'zuhr':
        return zuhr;
      case 'asr':
        return asr;
      case 'maghrib':
      case 'maghreb':
        return maghreb;
      case 'isha':
        return isha;
    }
    return null;
  }
}

/// The year's azan times, read from a bundled table.
///
/// The table holds one line per day, so a lookup is an index rather than a
/// calculation. Times come from the mosque timetable rather than being
/// computed, so they match what is actually called.
class AzanTimes {
  AzanTimes._();

  static final AzanTimes instance = AzanTimes._();

  /// The year the bundled table covers.
  static const int year = 2026;

  List<AzanDay>? _days;

  /// True once the table has been read.
  bool get isLoaded => _days != null;

  /// Reads the table. Safe to call more than once.
  Future<void> load() async {
    if (_days != null) return;

    final raw = await rootBundle.loadString('assets/azan/2026.csv');
    final days = <AzanDay>[];

    for (final line in const LineSplitter().convert(raw)) {
      final text = line.trim();
      if (text.isEmpty || text.startsWith('#')) continue;

      final parts = text.split(',');
      if (parts.length != 6) continue;

      final n = parts.map(int.parse).toList();
      days.add(AzanDay(
        fajr: n[0],
        shrooq: n[1],
        zuhr: n[2],
        asr: n[3],
        maghreb: n[4],
        isha: n[5],
      ));
    }

    _days = days;
  }

  /// The times for a given date, or null when the date falls outside the
  /// year the table covers.
  AzanDay? forDate(DateTime date) {
    final days = _days;
    if (days == null || date.year != year) return null;

    // Counted in UTC. A local difference is wrong around the clock changes,
    // where a day is 23 or 25 hours long and inDays truncates to the day
    // before.
    final index = DateTime.utc(date.year, date.month, date.day)
        .difference(DateTime.utc(year, 1, 1))
        .inDays;
    if (index < 0 || index >= days.length) return null;
    return days[index];
  }

  /// The times for today, or null when today is outside the year.
  AzanDay? get today => forDate(DateTime.now());

  /// Formats minutes past midnight as a 12 hour clock time.
  static String format(int minutes) {
    final h24 = minutes ~/ 60;
    final m = minutes % 60;
    final suffix = h24 < 12 ? 'am' : 'pm';
    var h = h24 % 12;
    if (h == 0) h = 12;
    return '$h:${m.toString().padLeft(2, '0')} $suffix';
  }
}
