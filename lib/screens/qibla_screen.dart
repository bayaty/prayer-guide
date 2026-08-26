import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../data/qibla.dart';
import '../theme/app_colors.dart';

/// Points the way to the Kaaba.
///
/// The heading comes from the device's compass. Where there is no compass,
/// or it has not settled, the bearing is still shown as a number so the
/// direction can be found from a separate compass.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  QiblaCity _city = Qibla.defaultCity;

  StreamSubscription<CompassEvent>? _compass;
  double? _heading;
  bool _hasCompass = true;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  void _listen() {
    final events = FlutterCompass.events;
    if (events == null) {
      setState(() => _hasCompass = false);
      return;
    }

    _compass = events.listen(
      (event) {
        if (!mounted) return;
        setState(() {
          _heading = event.heading;
          // A null heading means the sensor is present but unreadable,
          // usually because it needs calibrating.
          _hasCompass = event.heading != null;
        });
      },
      onError: (_) {
        if (mounted) setState(() => _hasCompass = false);
      },
    );
  }

  @override
  void dispose() {
    _compass?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bearing = Qibla.bearingFrom(_city.latitude, _city.longitude);
    final distance = Qibla.distanceKmFrom(_city.latitude, _city.longitude);
    final heading = _heading;

    // The dial turns opposite to the phone so north stays put, and the
    // needle sits at the qibla bearing relative to where the phone points.
    final turn = heading == null ? 0.0 : -heading * math.pi / 180;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _cityPicker(),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: turn,
                    child: CustomPaint(
                      size: const Size(280, 280),
                      painter: _DialPainter(bearing: bearing),
                    ),
                  ),
                  // Sits on a disc so the needle passes behind the reading
                  // rather than through it.
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.softPink.withValues(alpha: 0.6),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${bearing.toStringAsFixed(0)}°',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          Qibla.compassPoint(bearing),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _readout(bearing, distance, heading),
        ],
      ),
    );
  }

  Widget _cityPicker() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<QiblaCity>(
            value: _city,
            isExpanded: true,
            icon: const Icon(Icons.expand_more, color: AppColors.primary),
            items: [
              for (final city in Qibla.cities)
                DropdownMenuItem(
                  value: city,
                  child: Text(
                    city.label,
                    style: const TextStyle(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (city) {
              if (city != null) setState(() => _city = city);
            },
          ),
        ),
      ),
    );
  }

  Widget _readout(double bearing, double distance, double? heading) {
    return Card(
      color: AppColors.tintBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Direction',
                '${bearing.toStringAsFixed(1)}° '
                '${Qibla.compassPoint(bearing)} of true north'),
            const SizedBox(height: 8),
            _row('Distance', '${distance.round()} km to Mecca'),
            const SizedBox(height: 8),
            _row(
              'Compass',
              _hasCompass && heading != null
                  ? 'Following your phone'
                  : 'Not available on this device',
            ),
            if (!_hasCompass || heading == null) ...[
              const SizedBox(height: 12),
              Text(
                'Without a compass the dial cannot turn with you. Face '
                '${bearing.toStringAsFixed(0)}° on a separate compass to '
                'find the qibla.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13.5)),
        ),
      ],
    );
  }
}

/// The dial face: a ring, the cardinal points, and an arrow to the Kaaba.
class _DialPainter extends CustomPainter {
  final double bearing;

  const _DialPainter({required this.bearing});

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.softPink;
    canvas.drawCircle(centre, radius, ring);

    // Ticks every thirty degrees, longer at the cardinal points.
    final tick = Paint()..strokeWidth = 2..color = AppColors.softPink;
    for (var deg = 0; deg < 360; deg += 30) {
      final a = (deg - 90) * math.pi / 180;
      final long = deg % 90 == 0;
      final inner = radius - (long ? 14 : 8);
      canvas.drawLine(
        centre + Offset(math.cos(a) * inner, math.sin(a) * inner),
        centre + Offset(math.cos(a) * radius, math.sin(a) * radius),
        tick,
      );
    }

    // Cardinal letters.
    for (final entry in {0: 'N', 90: 'E', 180: 'S', 270: 'W'}.entries) {
      final a = (entry.key - 90) * math.pi / 180;
      final at = centre +
          Offset(math.cos(a) * (radius - 30), math.sin(a) * (radius - 30));

      final painter = TextPainter(
        text: TextSpan(
          text: entry.value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: entry.key == 0 ? AppColors.primary : Colors.grey[500],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
    }

    // The arrow to the Kaaba.
    final a = (bearing - 90) * math.pi / 180;
    final tip = centre + Offset(math.cos(a) * (radius - 6),
        math.sin(a) * (radius - 6));

    final shaft = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFD4A017);
    canvas.drawLine(centre, tip, shaft);

    // Arrow head.
    final head = Path();
    const spread = 0.32;
    const len = 26.0;
    head.moveTo(tip.dx, tip.dy);
    head.lineTo(
      tip.dx - math.cos(a - spread) * len,
      tip.dy - math.sin(a - spread) * len,
    );
    head.lineTo(
      tip.dx - math.cos(a + spread) * len,
      tip.dy - math.sin(a + spread) * len,
    );
    head.close();
    canvas.drawPath(head, Paint()..color = const Color(0xFFD4A017));

    canvas.drawCircle(centre, 6, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(_DialPainter old) => old.bearing != bearing;
}
