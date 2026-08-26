import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/info_section.dart';
import '../widgets/practice_mode_toggle.dart';
import '../widgets/step_icon.dart';
import '../data/app_settings.dart';
import '../data/practice_mode.dart';
import '../data/wudu_data.dart';
import 'settings_screen.dart';

class WuduScreen extends StatelessWidget {
  const WuduScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PracticeMode.instance,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final visible = PracticeMode.instance.filter<WuduStep>(
      wuduSteps,
      (s) => s.level,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                tooltip: 'Settings',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Wudu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.accent, AppColors.primary],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🫧', style: TextStyle(fontSize: 50)),
                      SizedBox(height: 4),
                      Text(
                        'Purify Yourself Before Prayer',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: PracticeModeToggle(
                visibleCount: visible.length,
                totalCount: wuduSteps.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _WuduCard(
                  step: visible[index],
                  // Number by position so the visible list always reads
                  // 1..N, with no gaps where sunnah steps were removed.
                  displayNumber: index + 1,
                ),
                childCount: visible.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }
}

class _WuduCard extends StatelessWidget {
  final WuduStep step;

  /// Position within the currently visible list, so numbering stays
  /// continuous when sunnah steps are filtered out.
  final int displayNumber;

  const _WuduCard({required this.step, required this.displayNumber});

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.instance;
    // The supplication block is pointless when every part of it is hidden.
    final hasDua = step.arabicText.isNotEmpty && !s.hideAllText;
    final extraSunnahs = PracticeMode.instance.extraSunnahs;
    final shownTimes = step.timesFor(extraSunnahs: extraSunnahs);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header: number badge + icon + title
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.tintBg,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$displayNumber',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                StepIcon(step.icon, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            // "3 times" pill for counted actions
            if (shownTimes > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  shownTimes == 1 ? 'Once' : '$shownTimes times',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            Text(
              step.instruction,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),

            if (step.info.isNotEmpty) InfoSection(step.info),

            // optional supplication block
            if (hasDua) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.tintBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.softPink),
                ),
                child: Column(
                  children: [
                    if (s.showArabic)
                      Text(
                        step.arabicText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          height: 1.9,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                    if (s.showTransliteration) ...[
                      if (s.showArabic) const SizedBox(height: 8),
                      Text(
                        step.transliteration,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (s.showTranslation) ...[
                      if (s.showArabic || s.showTransliteration)
                        const SizedBox(height: 4),
                      Text(
                        step.translation,
                        style:
                            TextStyle(fontSize: 12.5, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
