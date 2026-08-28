import 'package:flutter/material.dart';
import '../data/practice_mode.dart';
import '../theme/app_colors.dart';
import '../widgets/step_detail_card.dart';
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
                return StepDetailCard(step: steps[index]);
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
