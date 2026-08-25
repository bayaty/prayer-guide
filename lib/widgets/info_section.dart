import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A "Show more info" toggle that reveals background text about a step.
///
/// Collapsed by default so the step itself stays the focus.
class InfoSection extends StatefulWidget {
  final String info;

  /// Optional source line shown under the text, e.g. a hadith reference.
  final String? source;

  const InfoSection(this.info, {super.key, this.source});

  @override
  State<InfoSection> createState() => _InfoSectionState();
}

class _InfoSectionState extends State<InfoSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.info.trim().isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              _expanded ? Icons.expand_less : Icons.info_outline,
              size: 18,
            ),
            label: Text(
              _expanded ? 'Hide info' : 'Show more info',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.tintBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.softPink),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.info,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.55,
                    color: Colors.grey[800],
                  ),
                ),
                if ((widget.source ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.source!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
