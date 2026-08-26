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
