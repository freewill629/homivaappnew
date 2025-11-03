import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'live_sync_status.dart';

class WaterLevelGauge extends StatefulWidget {
  const WaterLevelGauge({
    required this.levelPercent,
    required this.isConnected,
    required this.isLoading,
    super.key,
  });

  final double? levelPercent;
  final bool isConnected;
  final bool isLoading;

  @override
  State<WaterLevelGauge> createState() => _WaterLevelGaugeState();
}

class _WaterLevelGaugeState extends State<WaterLevelGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  double _previousLevel = 0;

  @override
  void initState() {
    super.initState();
    _previousLevel = widget.levelPercent ?? 0;
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant WaterLevelGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldLevel = oldWidget.levelPercent ?? 0;
    final nextLevel = widget.levelPercent ?? 0;
    if ((oldLevel - nextLevel).abs() > 0.01) {
      _previousLevel = oldLevel;
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusText = widget.isLoading
        ? 'Connecting…'
        : widget.isConnected
            ? 'Live · syncing'
            : 'Offline';
    final hasValue = widget.levelPercent != null;
    final targetLevel = widget.levelPercent ?? 0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _previousLevel, end: targetLevel),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      onEnd: () => _previousLevel = targetLevel,
      builder: (context, animatedPercent, _) {
        final normalized = (animatedPercent / 100).clamp(0.0, 1.0);
        final formattedLevel = hasValue
            ? animatedPercent.clamp(0, 1000).toStringAsFixed(0)
            : '--';
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.12),
                        theme.colorScheme.secondary.withOpacity(0.18),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x220F172A),
                        blurRadius: 32,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 280,
                    width: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _TankShellPainter(
                              baseColor: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: _WaterFillPainter(
                                  progress: normalized,
                                  phase: _waveController.value,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _TankGlossPainter(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 28,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.72),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x330F172A),
                                        blurRadius: 10,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: widget.isConnected
                                              ? theme.colorScheme.primary
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        widget.isConnected ? 'Live' : 'Standby',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: widget.isConnected
                                              ? theme.colorScheme.primary
                                              : const Color(0xFF475569),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formattedLevel != '--'
                                        ? '$formattedLevel%'
                                        : formattedLevel,
                                    style: theme.textTheme.displaySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.8,
                                      shadows: const [
                                        Shadow(
                                          color: Color(0x33000000),
                                          offset: Offset(0, 4),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tank level',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Icon(
                                  Icons.water_drop,
                                  color: Colors.white.withOpacity(0.72),
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Water Level',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            LiveSyncStatus(
              label: statusText,
              isActive: widget.isConnected && !widget.isLoading,
              color: const Color(0xFF475569),
              activeDotColor: theme.colorScheme.primary,
              inactiveDotColor: const Color(0xFFCBD5F5),
            ),
          ],
        );
      },
    );
  }
}

class _TankShellPainter extends CustomPainter {
  _TankShellPainter({required this.baseColor});

  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _TankGeometry.buildPath(size);
    final bodyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        baseColor.withOpacity(0.95),
        const Color(0xFF3B60F3),
        const Color(0xFF1B338A),
      ],
      stops: const [0.05, 0.55, 1.0],
    );

    final fillPaint = Paint()
      ..shader = bodyGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawPath(path, fillPaint);

    canvas.save();
    canvas.clipPath(path);
    final sideGlow = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x66FFFFFF), Color(0x00FFFFFF)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.55, size.height), sideGlow);

    final rimHighlight = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.35));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.35), rimHighlight);
    canvas.restore();

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = Colors.white.withOpacity(0.65);
    canvas.drawPath(path, outlinePaint);

    final bottomGlowPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x335A6AFF), Color(0x00000000)],
        radius: 0.9,
        center: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.7));
    canvas.drawPath(path, bottomGlowPaint);
  }

  @override
  bool shouldRepaint(covariant _TankShellPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor;
  }
}

class _WaterFillPainter extends CustomPainter {
  _WaterFillPainter({required this.progress, required this.phase});

  final double progress;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final tankPath = _TankGeometry.buildPath(size);
    final clampedProgress = progress.clamp(0.0, 1.0);

    canvas.save();
    canvas.clipPath(tankPath);

    if (clampedProgress > 0) {
      final geometry = _TankGeometry(size);
      final fillTop = geometry.maxFillY -
          (geometry.maxFillY - geometry.minFillY) * clampedProgress;
      final amplitude = geometry.waveAmplitude(clampedProgress);
      final wavePath = Path()
        ..moveTo(0, geometry.bottomY)
        ..lineTo(0, fillTop);

      final waveLength = size.width;
      for (double x = 0; x <= waveLength; x++) {
        final sine = math.sin((x / waveLength * 2 * math.pi) + phase * 2 * math.pi);
        wavePath.lineTo(x, fillTop + sine * amplitude);
      }

      wavePath
        ..lineTo(size.width, geometry.bottomY)
        ..quadraticBezierTo(
          size.width / 2,
          geometry.bottomY + geometry.bottomCurveDepth,
          0,
          geometry.bottomY,
        )
        ..close();

      final fillGradient = const LinearGradient(
        colors: [Color(0xFF8EC5FF), Color(0xFF4F7BFF), Color(0xFF1D4ED8)],
        stops: [0.0, 0.55, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
      final shaderRect = Rect.fromLTWH(
        0,
        fillTop - amplitude * 1.5,
        size.width,
        geometry.bottomY - fillTop + amplitude * 2.5,
      );
      final fillPaint = Paint()..shader = fillGradient.createShader(shaderRect);
      canvas.drawPath(wavePath, fillPaint);

      final foamPaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final foamPath = Path()
        ..moveTo(0, fillTop);
      for (double x = 0; x <= waveLength; x += 6) {
        final sine = math.sin((x / waveLength * 2 * math.pi) + phase * 2 * math.pi);
        foamPath.lineTo(x, fillTop + sine * amplitude * 0.6);
      }
      canvas.drawPath(foamPath, foamPaint);

      final innerGlowPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x33FFFFFF), Color(0x00000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, fillTop - 40, size.width, 80));
      canvas.drawRect(Rect.fromLTWH(0, fillTop - 40, size.width, 80), innerGlowPaint);
    }

    canvas.restore();

    final glossPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x22FFFFFF), Color(0x00000000)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(tankPath, glossPaint);
  }

  @override
  bool shouldRepaint(covariant _WaterFillPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.phase != phase;
  }
}

class _TankGlossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _TankGeometry.buildPath(size);
    canvas.save();
    canvas.clipPath(path);
    final glossPath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.02,
        size.width * 0.45,
        size.height * 0.28,
      )
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.45,
        size.width * 0.4,
        size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.76,
        size.width * 0.18,
        size.height * 0.85,
      )
      ..close();

    final glossPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x55FFFFFF), Color(0x00FFFFFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(glossPath, glossPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TankGeometry {
  _TankGeometry(this.size);

  final Size size;

  static Path buildPath(Size size) {
    final geometry = _TankGeometry(size);
    final path = Path()
      ..moveTo(0, geometry.topY)
      ..quadraticBezierTo(
        size.width / 2,
        geometry.topY - geometry.topCurveDepth,
        size.width,
        geometry.topY,
      )
      ..lineTo(size.width, geometry.bottomY)
      ..quadraticBezierTo(
        size.width / 2,
        geometry.bottomY + geometry.bottomCurveDepth,
        0,
        geometry.bottomY,
      )
      ..close();
    return path;
  }

  double get topCurveDepth => size.height * 0.12;
  double get bottomCurveDepth => size.height * 0.18;
  double get topY => size.height * 0.18;
  double get bottomY => size.height - size.height * 0.16;
  double get minFillY => topY + size.height * 0.02;
  double get maxFillY => bottomY - size.height * 0.05;

  double waveAmplitude(double progress) {
    final base = size.height * 0.04;
    final dynamicRange = size.height * 0.06;
    return base + dynamicRange * progress;
  }
}
