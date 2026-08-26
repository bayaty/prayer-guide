import 'package:flutter/material.dart';
import '../data/app_settings.dart';
import '../data/practice_mode.dart';
import '../theme/app_colors.dart';
import '../widgets/info_section.dart';
import '../widgets/step_icon.dart';
import '../data/prayer_data.dart';

class PrayerStepsScreen extends StatefulWidget {
  final Prayer prayer;
  final int initialStep;

  const PrayerStepsScreen({super.key, required this.prayer, this.initialStep = 0});

  @override
  State<PrayerStepsScreen> createState() => _PrayerStepsScreenState();
}

class _PrayerStepsScreenState extends State<PrayerStepsScreen> {
  late final PageController _pageController;
  late int _currentStep;

  /// Steps honouring the current practice mode, so indexes here line up
  /// with the filtered list the user tapped from.
  List<PrayerStep> get _steps => PracticeMode.instance
      .filter<PrayerStep>(widget.prayer.steps, (s) => s.level);

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _pageController = PageController(initialPage: widget.initialStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step >= 0 && step < _steps.length) {
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the practice mode changes, so the step list stays correct
    // without needing to leave and re-enter the screen.
    return AnimatedBuilder(
      animation: PracticeMode.instance,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final steps = _steps;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('${widget.prayer.name} Prayer'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / steps.length,
            backgroundColor: AppColors.highlight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.softPink),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              'Step ${_currentStep + 1} of ${steps.length}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              itemCount: steps.length,
              itemBuilder: (context, index) {
                return _StepCard(step: steps[index]);
              },
            ),
          ),
          _NavigationBar(
            currentStep: _currentStep,
            totalSteps: steps.length,
            onPrevious: () => _goToStep(_currentStep - 1),
            onNext: () => _goToStep(_currentStep + 1),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final PrayerStep step;

  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    final sections = _sections(context, step);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
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
          const SizedBox(height: 80),
        ],
      ),
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

class _NavigationBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _NavigationBar({
    required this.currentStep,
    required this.totalSteps,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = currentStep == 0;
    final isLast = currentStep == totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: isFirst
                  ? const SizedBox()
                  : OutlinedButton.icon(
                      onPressed: onPrevious,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.accent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isLast
                  ? FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: onNext,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
