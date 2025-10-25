import 'package:flutter/material.dart';

class TankStatusChip extends StatelessWidget {
  const TankStatusChip({
    required this.isOn,
    required this.hasData,
    super.key,
  });

  final bool isOn;
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    final color = isOn ? const Color(0xFF16A34A) : Colors.black38;
    final background = isOn ? const Color(0xFFD1FAE5) : const Color(0xFFE5E7EB);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasData ? background : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        hasData ? (isOn ? 'ON' : 'OFF') : 'PENDING',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: hasData ? color : Colors.black45,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
