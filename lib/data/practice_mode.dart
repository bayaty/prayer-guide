import 'package:flutter/foundation.dart';

import 'app_settings.dart';

/// Which detail level a step belongs to.
///
/// Two of these exist to support a swap rather than a filter. An absolute
/// beginner who has not yet memorised the Arabic is taught a simpler stand-in,
/// and the same moment in the prayer shows the full wording once they are
/// ready. So a step is not only shown or hidden: some steps replace others.
enum StepLevel {
  /// Required for the act to be valid. Always shown.
  essential,

  /// Recommended practice of the Prophet. Hidden in bare-minimum mode.
  sunnah,

  /// A simplified stand-in shown ONLY in bare-minimum mode.
  ///
  /// For someone who has just become Muslim and cannot yet recite the full
  /// Arabic. It is scaffolding, not the destination, so every beginner step
  /// says plainly what it is standing in for.
  beginner,

  /// The full wording a [beginner] step stands in for.
  ///
  /// Hidden in bare-minimum mode and shown in complete mode. Distinct from
  /// [sunnah] because these are not optional extras: they are the real thing
  /// the learner is working towards.
  learning,
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
  String get title => extraSunnahs ? 'Complete Steps' : 'Starting Out';

  /// One-line explanation of what the current mode shows.
  String get description => extraSunnahs
      ? 'Showing the complete steps, including recommended practice.'
      : 'A simpler path while you learn. Switch to Complete Steps as the '
          'Arabic becomes familiar.';

  set extraSunnahs(bool value) {
    AppSettings.instance.setExtraSunnahs(value);
  }

  void toggle() => extraSunnahs = !extraSunnahs;

  /// Whether a step belongs in the current mode.
  bool shows(StepLevel level) {
    if (extraSunnahs) {
      // Complete: everything except the beginner stand-ins, which would
      // otherwise appear beside the full wording they replace.
      return level != StepLevel.beginner;
    }
    // Starting out: the required steps plus the simplified stand-ins.
    return level == StepLevel.essential || level == StepLevel.beginner;
  }

  /// Filters [steps] according to the current mode.
  List<T> filter<T>(List<T> steps, StepLevel Function(T) levelOf) {
    return steps.where((s) => shows(levelOf(s))).toList();
  }
}
