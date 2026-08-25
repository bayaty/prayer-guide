import 'package:flutter/material.dart';

import '../data/practice_mode.dart';
import '../theme/app_colors.dart';

/// Switches between the full practice and the obligatory steps only.
///
/// The label changes with the state, so the control always names the mode
/// currently being shown.
class PracticeModeToggle extends StatelessWidget {
  /// Number of steps currently visible, shown alongside the label.
  final int visibleCount;

  /// Total number of steps available in full mode.
  final int totalCount;

  const PracticeModeToggle({
    super.key,
    required this.visibleCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final mode = PracticeMode.instance;

    return AnimatedBuilder(
      animation: mode,
      builder: (context, _) {
        final on = mode.extraSunnahs;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 1,
          color: on ? Colors.white : AppColors.tintBg,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: mode.toggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  Icon(
                    on ? Icons.auto_awesome : Icons.check_circle_outline,
                    color: AppColors.accent,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$visibleCount of $totalCount steps',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: on,
                    activeThumbColor: AppColors.accent,
                    onChanged: (v) => mode.extraSunnahs = v,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
