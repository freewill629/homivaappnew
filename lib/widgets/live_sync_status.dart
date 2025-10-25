import 'package:flutter/material.dart';

class LiveSyncStatus extends StatelessWidget {
  const LiveSyncStatus({
    required this.label,
    required this.isActive,
    super.key,
  });

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulsingDot(active: isActive),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: isActive ? const Color(0xFF047857) : Colors.black54),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.active});

  final bool active;

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
        color: widget.active ? const Color(0xFF10B981) : Colors.black26,
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
