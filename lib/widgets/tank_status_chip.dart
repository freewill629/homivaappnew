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
    final theme = Theme.of(context);
    final backgroundGradient = isOn
        ? const [Color(0xFF6366F1), Color(0xFF818CF8)]
        : const [Color(0xFFF4F6FF), Color(0xFFE2E8F0)];
    final labelColor = isOn ? Colors.white : const Color(0xFF334155);
    final iconColor = isOn ? Colors.white : theme.colorScheme.primary;
    final label = hasStatus ? (isOn ? 'Power ON' : 'Power OFF') : 'Awaiting status';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: backgroundGradient),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isConnected ? theme.colorScheme.primary.withOpacity(0.3) : const Color(0xFFE2E8F0)),
        boxShadow: [
          if (hasStatus)
            BoxShadow(
              color: (isOn ? theme.colorScheme.primary : const Color(0xFF94A3B8)).withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOn ? Icons.flash_on : Icons.flash_off,
            size: 18,
            color: iconColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
