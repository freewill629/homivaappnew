import 'package:flutter/material.dart';

class TankToggle extends StatelessWidget {
  const TankToggle({
    required this.isOn,
    required this.onChanged,
    super.key,
    this.enabled = true,
    this.busy = false,
  });

  final bool isOn;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSelectionChanged = enabled && !busy
        ? (Set<bool> selected) {
            if (selected.isNotEmpty) {
              onChanged(selected.first);
            }
          }
        : null;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 72,
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                icon: Icon(Icons.power_settings_new),
                label: _SegmentContent(
                  title: 'Pump off',
                  subtitle: 'Stops water flow',
                ),
              ),
              ButtonSegment(
                value: true,
                icon: Icon(Icons.bolt),
                label: _SegmentContent(
                  title: 'Pump on',
                  subtitle: 'Starts pumping now',
                ),
              ),
            ],
            showSelectedIcon: false,
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              side: WidgetStateProperty.resolveWith(
                (states) {
                  if (states.contains(WidgetState.disabled)) {
                    return const BorderSide(color: Color(0xFFE2E8F0));
                  }
                  if (states.contains(WidgetState.selected)) {
                    return BorderSide(color: theme.colorScheme.primary, width: 1.2);
                  }
                  return const BorderSide(color: Color(0xFFE2E8F0));
                },
              ),
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) {
                  if (states.contains(WidgetState.disabled)) {
                    return const Color(0xFFF1F5F9);
                  }
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFFEEF2FF);
                  }
                  return Colors.white;
                },
              ),
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) {
                  if (states.contains(WidgetState.disabled)) {
                    return const Color(0xFF94A3B8);
                  }
                  if (states.contains(WidgetState.selected)) {
                    return theme.colorScheme.primary;
                  }
                  return const Color(0xFF334155);
                },
              ),
              iconColor: WidgetStateProperty.resolveWith(
                (states) {
                  if (states.contains(WidgetState.disabled)) {
                    return const Color(0xFF94A3B8);
                  }
                  return states.contains(WidgetState.selected)
                      ? theme.colorScheme.primary
                      : const Color(0xFF64748B);
                },
              ),
            ),
            selected: <bool>{isOn},
            onSelectionChanged: onSelectionChanged,
          ),
        ),
        if (busy)
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
      ],
    );
  }
}

class _SegmentContent extends StatelessWidget {
  const _SegmentContent({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700);
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: baseStyle),
        const SizedBox(height: 2),
        Text(subtitle, style: subtitleStyle),
      ],
    );
  }
}
