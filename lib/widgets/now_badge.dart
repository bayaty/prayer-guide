import 'package:flutter/material.dart';

/// A gold "NOW" badge marking the prayer whose time it is.
class NowBadge extends StatefulWidget {
  /// Shrinks the badge for the cramped navigation bar.
  final bool compact;

  const NowBadge({super.key, this.compact = false});

  @override
  State<NowBadge> createState() => _NowBadgeState();
}

class _NowBadgeState extends State<NowBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _gold = Color(0xFFD4A017);
  static const _lightGold = Color(0xFFFFC93C);

  @override
  void initState() {
    super.initState();
    // A slow breath rather than a blink, so it draws the eye without
    // becoming a distraction during prayer.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Icon(
          Icons.star_rounded,
          size: 13,
          color: Color.lerp(_gold, _lightGold, _controller.value),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final glow = Color.lerp(_gold, _lightGold, _controller.value)!;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [glow, _gold],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.45 * _controller.value),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: 15, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'NOW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
