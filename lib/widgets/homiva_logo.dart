import 'package:flutter/material.dart';

class HomivaLogo extends StatelessWidget {
  const HomivaLogo({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _HomivaLogoPainter(),
    );
  }
}

class _HomivaLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0A84FF)
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * 0.4),
    );

    final basePath = Path()..addRRect(rect);
    final notchRadius = size.width * 0.3;
    final notchCenter = Offset(size.width / 2, size.height * 0.32);
    final notchPath = Path()
      ..addOval(Rect.fromCircle(center: notchCenter, radius: notchRadius));

    final logoPath = Path.combine(PathOperation.difference, basePath, notchPath);
    canvas.drawPath(logoPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
