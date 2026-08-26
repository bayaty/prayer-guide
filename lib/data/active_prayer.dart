import 'dart:async';

import 'package:flutter/foundation.dart';

import 'azan_times.dart';

/// Which prayer the current time falls into.
///
/// Each prayer's time runs until the next one begins, with two exceptions
/// that the plain "next prayer" reading gets wrong:
///
///  * Fajr ends at sunrise, not at Dhuhr. The stretch between sunrise and
///    Dhuhr is not a prayer time at all.
///  * Isha runs past midnight, so in the small hours it is still Isha from
///    the evening before.
class ActivePrayer extends ChangeNotifier {
  ActivePrayer._();

  static final ActivePrayer instance = ActivePrayer._();

  Timer? _timer;
  String? _current;
  DateTime _now = DateTime.now();

  /// The prayer whose time it is, or null between sunrise and Dhuhr.
  String? get current => _current;

  /// True when the given prayer is the one being observed now.
  bool isNow(String prayer) =>
      _current != null && _current!.toLowerCase() == prayer.toLowerCase();

  /// Starts recalculating once a minute, on the minute.
  void start() {
    _recalculate();
    _timer?.cancel();

    // Fire on the next minute boundary, then every minute after, so the
    // display flips over at the same moment the clock does.
    final delay = Duration(
      seconds: 60 - DateTime.now().second,
    );
    _timer = Timer(delay, () {
      _recalculate();
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        _recalculate();
      });
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Recomputes from the clock. Exposed for tests through [evaluate].
  void _recalculate() {
    _now = DateTime.now();
    final next = evaluate(_now);
    if (next != _current) {
      _current = next;
      notifyListeners();
    }
  }

  /// Overrides the clock, for tests.
  @visibleForTesting
  void setNowForTest(DateTime now) {
    _now = now;
    final next = evaluate(now);
    if (next != _current) {
      _current = next;
      notifyListeners();
    }
  }

  /// Works out the prayer for a moment in time, without touching state.
  ///
  /// Returns null when the moment sits between sunrise and Dhuhr, which is
  /// not one of the five prayer times.
  static String? evaluate(DateTime at) {
    final today = AzanTimes.instance.forDate(at);
    if (today == null) return null;

    final minutes = at.hour * 60 + at.minute;

    // Before Fajr the evening prayer from the night before is still running.
    // This holds on the first day of the year too, where the previous day
    // falls outside the table: the prayer is still Isha, it simply began on
    // a date we have no row for.
    if (minutes < today.fajr) return 'Isha';

    if (minutes < today.shrooq) return 'Fajr';
    if (minutes < today.zuhr) return null; // after sunrise, before Dhuhr
    if (minutes < today.asr) return 'Dhuhr';
    if (minutes < today.maghreb) return 'Asr';
    if (minutes < today.isha) return 'Maghrib';
    return 'Isha';
  }

  /// The stretch of time a prayer may be prayed in, as minutes past
  /// midnight, or null when the date falls outside the table.
  ///
  /// Each prayer runs until the next one is called, with two exceptions:
  /// Fajr ends at sunrise rather than at Dhuhr, and Isha runs on to the
  /// following dawn, so its end is read from the next day.
  static ({int start, int end})? windowFor(String prayer, DateTime date) {
    final today = AzanTimes.instance.forDate(date);
    if (today == null) return null;

    switch (prayer.toLowerCase()) {
      case 'fajr':
        return (start: today.fajr, end: today.shrooq);
      case 'dhuhr':
      case 'zuhr':
        return (start: today.zuhr, end: today.asr);
      case 'asr':
        return (start: today.asr, end: today.maghreb);
      case 'maghrib':
      case 'maghreb':
        return (start: today.maghreb, end: today.isha);
      case 'isha':
        // Ends at the next dawn. On the last day of the table there is no
        // following row, so the end is left unknown rather than guessed.
        final tomorrow = AzanTimes.instance.forDate(
          date.add(const Duration(days: 1)),
        );
        if (tomorrow == null) return null;
        return (start: today.isha, end: tomorrow.fajr);
    }
    return null;
  }

  /// The window for a prayer today, formatted as "1:28 pm to 5:13 pm".
  static String? windowLabel(String prayer, {DateTime? on}) {
    final w = windowFor(prayer, on ?? DateTime.now());
    if (w == null) return null;
    return '${AzanTimes.format(w.start)} - ${AzanTimes.format(w.end)}';
  }

  /// When the current prayer's time runs out, for the countdown line.
  static int? endsAt(DateTime at) {
    final today = AzanTimes.instance.forDate(at);
    if (today == null) return null;

    final minutes = at.hour * 60 + at.minute;

    if (minutes < today.fajr) return today.fajr;
    if (minutes < today.shrooq) return today.shrooq;
    if (minutes < today.zuhr) return today.zuhr;
    if (minutes < today.asr) return today.asr;
    if (minutes < today.maghreb) return today.maghreb;
    if (minutes < today.isha) return today.isha;
    return null; // runs past midnight
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
