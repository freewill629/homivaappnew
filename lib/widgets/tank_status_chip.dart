import 'package:flutter/material.dart';

class TankStatusChip extends StatelessWidget {
  const TankStatusChip({
    required this.isOn,
    required this.hasStatus,
    this.isConnected = false,
    super.key,
  });

  final bool isOn;
  final bool hasStatus;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final backgroundGradient = isOn
        ? const [Color(0xFF34D399), Color(0xFF10B981)]
        : const [Color(0xFFCBD5F5), Color(0xFFA5B4FC)];
    final borderColor = isConnected
        ? Colors.white.withValues(alpha: 0.4)
        : Colors.white.withValues(alpha: 0.12);
    final label = hasStatus
        ? (isOn ? 'Power ON' : 'Power OFF')
        : 'Awaiting status';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: backgroundGradient),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (hasStatus)
            BoxShadow(
              color: (isOn ? const Color(0xFF0F766E) : const Color(0xFF312E81)).withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOn ? Icons.flash_on : Icons.flash_off,
            size: 18,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ),
    );
  }
}
