import 'package:flutter/material.dart';

class LiveSyncStatus extends StatelessWidget {
  const LiveSyncStatus({
    required this.label,
    required this.isActive,
    super.key,
    this.color,
    this.activeDotColor,
    this.inactiveDotColor,
  });

  final String label;
  final bool isActive;
  final Color? color;
  final Color? activeDotColor;
  final Color? inactiveDotColor;

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? (isActive ? const Color(0xFF047857) : Colors.black54);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulsingDot(
          active: isActive,
          activeColor: activeDotColor ?? const Color(0xFF10B981),
          inactiveColor: inactiveDotColor ?? Colors.black26,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
  });

  final bool active;
  final Color activeColor;
  final Color inactiveColor;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  late final Animation<double> _scaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void didUpdateWidget(covariant _PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: widget.active ? widget.activeColor : widget.inactiveColor,
        shape: BoxShape.circle,
      ),
    );
    if (!widget.active) {
      return dot;
    }
    return ScaleTransition(
      scale: _scaleAnimation,
      child: dot,
    );
  }
}
