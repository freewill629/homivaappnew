import 'package:flutter/material.dart';

class HomivaLogo extends StatelessWidget {
  const HomivaLogo({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
