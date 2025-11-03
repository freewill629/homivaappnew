import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 28,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF3F6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFFE3E8FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A4455AA),
            blurRadius: 30,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: child,
    );
  }
}
