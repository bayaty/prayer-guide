import 'package:flutter/material.dart';
import '../data/active_prayer.dart';
import '../data/azan_times.dart';
import '../widgets/now_badge.dart';
import '../data/practice_mode.dart';
import '../theme/app_colors.dart';
import '../widgets/practice_mode_toggle.dart';
import '../widgets/step_detail_card.dart';
import 'settings_screen.dart';
import '../data/prayer_data.dart';
import 'prayer_steps_screen.dart';

class PrayerScreen extends StatelessWidget {
  final Prayer prayer;

  const PrayerScreen({super.key, required this.prayer});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PracticeMode.instance,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final visible = PracticeMode.instance
        .filter<PrayerStep>(prayer.steps, (s) => s.level);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            automaticallyImplyLeading: false,
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
            // The collapsed bar carries the prayer, its window and the star.
            // It is faded in only once the header has actually shrunk, so it
            // never sits on top of the full header.
            title: _CollapsedTitle(prayer: prayer),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.accent, AppColors.primary],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        prayer.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Today's call to prayer, straight from the timetable.
                      AnimatedBuilder(
                        animation: ActivePrayer.instance,
                        builder: (context, _) {
                          final today = AzanTimes.instance.today;
                          final minutes = today?.forPrayer(prayer.name);
                          final isNow = ActivePrayer.instance.isNow(
                            prayer.name,
                          );

                          final window = ActivePrayer.windowLabel(
                            prayer.name,
                          );

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (window != null)
                                Text(
                                  window,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                )
                              else if (minutes != null)
                                Text(
                                  AzanTimes.format(minutes),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                prayer.timeDescription,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              if (isNow) ...[
                                const SizedBox(height: 8),
                                const NowBadge(),
                              ],
                            ],
                          );
                        },
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
              child: Card(
                color: AppColors.tintBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        '${prayer.rakatCount} Rounds · ${prayer.steps.length} Steps',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrayerStepsScreen(prayer: prayer),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Step-by-Step Guide', style: TextStyle(fontSize: 16)),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'All Steps',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: PracticeModeToggle(
                visibleCount: visible.length,
                // Not prayer.steps.length: beginner steps are stand-ins that
                // are swapped out for their learning versions, so the raw
                // total counts both halves of a swap and can never be shown.
                totalCount: prayer.steps
                    .where((s) => s.level != StepLevel.beginner)
                    .length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final step = visible[index];
                  void open() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrayerStepsScreen(
                          prayer: prayer,
                          initialStep: index,
                        ),
                      ),
                    );
                  }

                  // Every step is laid out in one continuous read, so a
                  // learner can follow the whole prayer by scrolling. Tapping
                  // a card still opens the paged guide at that step for
                  // anyone who would rather take it one at a time.
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: StepDetailCard(
                      step: step,
                      stepNumber: index + 1,
                      onTap: open,
                      bottomPadding: 0,
                      scrollable: false,
                    ),
                  );
                },
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

/// The bar shown once the header has been scrolled away.
///
/// A SliverAppBar always builds its title, so this measures how far the
/// header has collapsed and fades in only over the last stretch. Without
/// that the title would sit on top of the expanded header.
class _CollapsedTitle extends StatelessWidget {
  final Prayer prayer;

  const _CollapsedTitle({required this.prayer});

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

    var opacity = 1.0;
    if (settings != null) {
      final range = settings.maxExtent - settings.minExtent;
      if (range > 0) {
        // 0 when fully expanded, 1 when fully collapsed.
        final collapsed =
            ((settings.maxExtent - settings.currentExtent) / range)
                .clamp(0.0, 1.0);
        // Hold back until the header is most of the way closed, then fade in
        // quickly, so the two never overlap.
        opacity = ((collapsed - 0.7) / 0.25).clamp(0.0, 1.0);
      }
    }

    if (opacity == 0) return const SizedBox.shrink();

    return Opacity(
      opacity: opacity,
      child: AnimatedBuilder(
        animation: ActivePrayer.instance,
        builder: (context, _) {
          final window = ActivePrayer.windowLabel(prayer.name);
          final isNow = ActivePrayer.instance.isNow(prayer.name);

          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  window == null ? prayer.name : '${prayer.name}  $window',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
              if (isNow) ...[
                const SizedBox(width: 6),
                const NowBadge(compact: true),
              ],
            ],
          );
        },
      ),
    );
  }
}
