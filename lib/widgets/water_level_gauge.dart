import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'live_sync_status.dart';

class WaterLevelGauge extends StatelessWidget {
  const WaterLevelGauge({
    required this.level,
    required this.isConnected,
    required this.isLoading,
    super.key,
  });

  final double? level;
  final bool isConnected;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final value = level;
    final pct = value != null ? (value.clamp(0, 10)) / 10.0 : 0.0;
    final hasValue = value != null;
    final statusText = isLoading
        ? 'Connecting…'
        : isConnected
            ? 'Live · syncing'
            : 'Offline';
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
                    hasValue ? '${value!.toStringAsFixed(1)} / 10' : '-- / 10',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
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
        const SizedBox(height: 8),
        LiveSyncStatus(label: statusText, isActive: isConnected && !isLoading),
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
