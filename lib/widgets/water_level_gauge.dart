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
    final formattedLevel = value?.toStringAsFixed(1);
    final statusText = isLoading
        ? 'Connecting…'
        : isConnected
            ? 'Live · syncing'
            : 'Offline';
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0x332563EB), Color(0x3338BDF8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SizedBox(
            height: 200,
            width: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x661F2937), blurRadius: 28, offset: Offset(0, 12)),
                    ],
                  ),
                ),
                CustomPaint(
                  size: const Size.square(200),
                  painter: _GaugePainter(pct: pct),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.18)),
                      ),
                      child: Text(
                        isConnected ? 'Live' : 'Standby',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      hasValue ? '$formattedLevel m' : '-- m',
                      style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'out of 10.0',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Water Level',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        LiveSyncStatus(
          label: statusText,
          isActive: isConnected && !isLoading,
          color: Colors.white70,
          activeDotColor: const Color(0xFF34D399),
          inactiveDotColor: Colors.white24,
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
    final radius = math.min(size.width, size.height) / 2 - 18;

    final bg = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0x223B82F6), Color(0x22A855F7), Color(0x223B82F6)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF60A5FA), Color(0xFF22D3EE)],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * pct.clamp(0.0, 1.0);

    canvas.drawArc(rect, 0, 2 * math.pi, false, bg);
    canvas.drawArc(rect, start, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) => oldDelegate.pct != pct;
}
