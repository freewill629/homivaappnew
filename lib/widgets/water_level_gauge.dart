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
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.12),
                    theme.colorScheme.secondary.withOpacity(0.16),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(36)),
              ),
              child: SizedBox(
                height: 260,
                width: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const _TankShell(),
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
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(44),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0x55FFFFFF), Color(0x004256D1)],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.isConnected ? 'Live' : 'Standby',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: widget.isConnected
                                      ? theme.colorScheme.primary
                                      : const Color(0xFF475569),
                                  fontWeight: FontWeight.w600,
                                ),
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
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
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
                              color: Colors.white.withOpacity(0.7),
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

class _TankShell extends StatelessWidget {
  const _TankShell();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.85),
            const Color(0xFF1D4ED8),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x334455AA),
            blurRadius: 30,
            spreadRadius: 4,
            offset: Offset(0, 18),
          ),
        ],
      ),
    );
  }
}

class _WaterFillPainter extends CustomPainter {
  _WaterFillPainter({required this.progress, required this.phase});

  final double progress;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final borderRadius = 44.0;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final clampedProgress = progress.clamp(0.0, 1.0);
    if (clampedProgress <= 0) {
      final highlightPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x22FFFFFF), Color(0x00000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect);
      canvas.drawRRect(rrect, highlightPaint);
      return;
    }

    canvas.save();
    canvas.clipRRect(rrect);

    final height = size.height * clampedProgress;
    final baseY = size.height - height;
    final amplitude = math.min(18.0, math.max(6.0, height * 0.15));
    final wavePath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, baseY);

    final waveLength = size.width;
    for (double x = 0; x <= waveLength; x++) {
      final sine = math.sin((x / waveLength * 2 * math.pi) + phase * 2 * math.pi);
      wavePath.lineTo(x, baseY + sine * amplitude);
    }

    wavePath
      ..lineTo(size.width, size.height)
      ..close();

    final gradient = const LinearGradient(
      colors: [Color(0xFF60A5FA), Color(0xFF6366F1), Color(0xFF4C1D95)],
      stops: [0.0, 0.6, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final shaderRect = Rect.fromLTWH(
      0,
      baseY - amplitude,
      size.width,
      height + amplitude,
    );

    final fillPaint = Paint()..shader = gradient.createShader(shaderRect);
    canvas.drawPath(wavePath, fillPaint);

    final foamPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final foamPath = Path()
      ..moveTo(0, baseY)
      ..lineTo(0, baseY);
    for (double x = 0; x <= waveLength; x += 6) {
      final sine = math.sin((x / waveLength * 2 * math.pi) + phase * 2 * math.pi);
      foamPath.lineTo(x, baseY + sine * amplitude * 0.6);
    }
    canvas.drawPath(foamPath, foamPaint);

    canvas.restore();

    final highlightPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x22FFFFFF), Color(0x00000000)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRRect(rrect, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _WaterFillPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.phase != phase;
  }
}
