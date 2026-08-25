import 'package:flutter/foundation.dart';

import 'app_settings.dart';

/// Which detail level a step belongs to.
enum StepLevel {
  /// Required for the act to be valid. Always shown.
  essential,

  /// Recommended practice of the Prophet. Hidden in bare-minimum mode.
  sunnah,
}

/// Whether the user wants the full practice or only the obligatory steps.
///
/// Backed by [AppSettings] so the choice survives a restart.
class PracticeMode extends ChangeNotifier {
  PracticeMode._() {
    AppSettings.instance.addListener(notifyListeners);
  }

  static final PracticeMode instance = PracticeMode._();

  /// True when optional sunnah steps are included.
  bool get extraSunnahs => AppSettings.instance.extraSunnahs;

  /// Title shown for the current mode.
  String get title => extraSunnahs ? 'Complete Steps' : 'Bare Minimum';

  /// One-line explanation of what the current mode shows.
  String get description => extraSunnahs
      ? 'Showing the complete steps, including recommended practice.'
      : 'Showing only the steps required for validity.';

  set extraSunnahs(bool value) {
    AppSettings.instance.setExtraSunnahs(value);
  }

  void toggle() => extraSunnahs = !extraSunnahs;

  /// Filters [steps] according to the current mode.
  List<T> filter<T>(List<T> steps, StepLevel Function(T) levelOf) {
    if (extraSunnahs) return steps;
    return steps.where((s) => levelOf(s) == StepLevel.essential).toList();
  }
}
