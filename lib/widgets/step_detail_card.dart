import 'package:flutter/material.dart';

import '../data/app_settings.dart';
import '../data/prayer_data.dart';
import '../theme/app_colors.dart';
import 'info_section.dart';
import 'step_icon.dart';

/// One prayer step shown in full: icon, title, instruction, and whichever of
/// the Arabic, transliteration and translation blocks the user has enabled.
///
/// Used both by the paged step-by-step guide (one card per page) and by the
/// full-detail reading list on the prayer screen (every card in one scroll).
/// In the reading list a step number is shown and the card is tappable, so
/// those are optional rather than baked in.
class StepDetailCard extends StatelessWidget {
  final PrayerStep step;

  /// 1-based position in the list. Shown as a badge when given.
  final int? stepNumber;

  /// Opens the paged guide at this step. Only used by the reading list.
  final VoidCallback? onTap;

  /// Space left under the card so the last one clears the navigation bar.
  final double bottomPadding;

  /// Whether the card scrolls on its own. True for the paged guide, where the
  /// card fills the page; false in the reading list, which does its own
  /// scrolling and would otherwise nest two scroll views.
  final bool scrollable;

  const StepDetailCard({
    super.key,
    required this.step,
    this.stepNumber,
    this.onTap,
    this.bottomPadding = 80,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = _content(context);

    if (!scrollable) return content;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: content,
    );
  }

  Widget _content(BuildContext context) {
    final sections = _sections(context, step);

    return Column(
      children: [
        _wrapTappable(
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (stepNumber != null) ...[
                    _StepNumber(stepNumber!),
                    const SizedBox(height: 12),
                  ],
                  StepIcon(step.icon, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.tintBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.softPink,
                      ),
                    ),
                    child: Text(
                      step.instruction,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (step.info.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    InfoSection(step.info),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Sections are assembled from whichever the user has enabled and
        // the step actually has, so dividers only fall between two visible
        // blocks and the card disappears entirely when nothing is left.
        if (sections.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: sections),
            ),
          ),
        ],
        SizedBox(height: bottomPadding),
      ],
    );
  }

  /// Makes the main card open the paged guide, when a handler was given.
  /// The info toggle inside keeps its own taps, so the two do not fight.
  Widget _wrapTappable(Widget card) {
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: card,
    );
  }

  /// Builds the Arabic, transliteration and translation blocks the user has
  /// chosen to see, separated by dividers only where two blocks meet.
  List<Widget> _sections(BuildContext context, PrayerStep step) {
    final s = AppSettings.instance;

    Widget label(String text) => Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.highlight,
            letterSpacing: 1,
          ),
        );

    final blocks = <List<Widget>>[
      if (s.showArabic && step.arabicText.trim().isNotEmpty)
        [
          label('Arabic'),
          const SizedBox(height: 12),
          Text(
            step.arabicText,
            style: const TextStyle(
              fontSize: 24,
              height: 2,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        ],
      if (s.showTransliteration && step.transliteration.trim().isNotEmpty)
        [
          label('Transliteration'),
          const SizedBox(height: 12),
          Text(
            step.transliteration,
            style: TextStyle(
              fontSize: 17,
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      if (s.showTranslation && step.translation.trim().isNotEmpty)
        [
          label('Translation'),
          const SizedBox(height: 12),
          Text(
            step.translation,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
    ];

    final out = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      if (i > 0) out.add(const Divider(height: 32));
      out.addAll(blocks[i]);
    }
    return out;
  }
}

/// The "Step 3 of 17" badge shown at the top of a card in the reading list.
class _StepNumber extends StatelessWidget {
  final int number;

  const _StepNumber(this.number);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Step $number',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
