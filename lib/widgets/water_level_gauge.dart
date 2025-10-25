import 'dart:math' as math;

import 'package:flutter/material.dart';

class WaterLevelGauge extends StatelessWidget {
  const WaterLevelGauge({required this.level, super.key});

  final double? level;

  @override
  Widget build(BuildContext context) {
    final value = level;
    final pct = value != null ? (value.clamp(0, 10)) / 10.0 : 0.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: CustomPaint(
            painter: _GaugePainter(pct: pct),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value != null ? value.toStringAsFixed(1) : '--',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of 10',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Water Level',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.pct});

  final double pct;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;

    final bg = Paint()
      ..color = const Color(0xFFE0E6EE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0A84FF), Color(0xFF30D158)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * pct;

    canvas.drawArc(rect, 0, 2 * math.pi, false, bg);
    canvas.drawArc(rect, start, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) => oldDelegate.pct != pct;
}
