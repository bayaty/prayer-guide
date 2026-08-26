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
                      painter: _DialPainter(
                        bearing: bearing,
                        dialRotation: turn,
                      ),
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
          const SizedBox(height: 16),
          _instructions(bearing, heading),
        ],
      ),
    );
  }

  /// How to use the dial, and what will throw it off.
  Widget _instructions(double bearing, double? heading) {
    final working = _hasCompass && heading != null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.help_outline, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'How to use it',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (working) ...[
              _step(1, 'Pick your city from the list above.'),
              _step(2,
                  'Hold the phone flat, screen up and level with the '
                  'ground.'),
              _step(3,
                  'Turn your whole body slowly until the gold arrow points '
                  'straight up.'),
              _step(4, 'Facing that way, you are facing the qibla.'),
              _step(5,
                  'To check it, the N on the dial should sit over true '
                  'north. The notes below give a few ways to find it.'),
            ] else ...[
              _step(1, 'Pick your city from the list above.'),
              _step(2,
                  'This device has no compass, so the dial cannot turn with '
                  'you. Find north first, using the notes below.'),
              _step(3, 'Stand facing north.'),
              _step(4, _turnInstruction(bearing)),
            ],
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.softPink),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Finding north without the phone',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 6),
                  _note(
                    'The sun rises roughly in the east and sets roughly in '
                    'the west. Stand with your right hand towards sunrise '
                    'and you are facing north.',
                  ),
                  _note(
                    'At midday, well north of the equator, the sun sits due '
                    'south and your shadow points north. Well south of the '
                    'equator it is the other way round. Close to the equator '
                    'this one does not help.',
                  ),
                  _note(
                    'Push a stick upright into the ground and mark the tip '
                    'of its shadow, wait about fifteen minutes and mark it '
                    'again. The line from the first mark to the second runs '
                    'roughly west to east.',
                  ),
                  _note(
                    'On a clear night the Pole Star sits over true north. '
                    'Find the Plough, or Big Dipper, and follow the two '
                    'stars at the end of its bowl upwards.',
                  ),
                  _note(
                    'Satellite dishes in North America and Europe generally '
                    'face the equator, so towards the south.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.tintBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.softPink),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What throws it off',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 6),
                  _note(
                    'Metal and magnets pull the reading around. Step away '
                    'from cars, desks, speakers and magnetic phone cases.',
                  ),
                  _note(
                    'If the arrow drifts or sticks, wave the phone in a '
                    'figure of eight to settle it.',
                  ),
                  _note(
                    'The bearing is measured from true north. A magnetic '
                    'compass reads a little differently depending on where '
                    'you are, so trust the dial here over a cheap compass.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Describes the turn from north as the shorter way round, so an eastern
  /// bearing reads as a small turn to the left rather than a large one to
  /// the right.
  String _turnInstruction(double bearing) {
    final point = Qibla.compassPoint(bearing);

    if (bearing <= 180) {
      return 'Turn ${bearing.toStringAsFixed(0)} degrees to your right, '
          'towards the $point. That is the qibla.';
    }
    final left = 360 - bearing;
    return 'Turn ${left.toStringAsFixed(0)} degrees to your left, '
        'towards the $point. That is the qibla.';
  }

  Widget _step(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _note(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('  \u2022 ', style: TextStyle(color: Colors.grey[700])),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.45,
              ),
            ),
          ),
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

  /// How far the whole dial has been turned, in radians. The Kaaba is
  /// turned back by the same amount so it never appears upside down.
  final double dialRotation;

  const _DialPainter({required this.bearing, this.dialRotation = 0});

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

    // The arrow to the Kaaba, stopping short so the Kaaba itself sits at
    // the end of it.
    final a = (bearing - 90) * math.pi / 180;
    const kaabaSize = 30.0;
    final kaabaAt = centre +
        Offset(math.cos(a) * (radius - 20), math.sin(a) * (radius - 20));
    final tip = centre +
        Offset(math.cos(a) * (radius - 42), math.sin(a) * (radius - 42));

    final shaft = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFD4A017);
    canvas.drawLine(centre, tip, shaft);

    // Arrow head.
    final head = Path();
    const spread = 0.32;
    const len = 22.0;
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

    // The Kaaba, marking what the arrow points at. It is turned back
    // against the dial so it always sits upright however the phone is held.
    final kaaba = TextPainter(
      text: const TextSpan(
        text: '🕋',
        style: TextStyle(fontSize: kaabaSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(kaabaAt.dx, kaabaAt.dy);
    canvas.rotate(-dialRotation);
    kaaba.paint(
      canvas,
      Offset(-kaaba.width / 2, -kaaba.height / 2),
    );
    canvas.restore();

    canvas.drawCircle(centre, 6, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.bearing != bearing || old.dialRotation != dialRotation;
}
