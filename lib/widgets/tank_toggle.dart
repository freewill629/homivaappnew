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
                    return const BorderSide(color: Color(0x33FFFFFF));
                  }
                  if (states.contains(WidgetState.selected)) {
                    return const BorderSide(color: Color(0xFF1E3A8A), width: 1.4);
                  }
                  return const BorderSide(color: Color(0xFFCBD5F5));
                },
              ),
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.white.withValues(alpha: 0.08);
                  }
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFFEEF2FF);
                  }
                  return Colors.white.withValues(alpha: 0.18);
                },
              ),
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.white54;
                  }
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF1D4ED8);
                  }
                  return Colors.white;
                },
              ),
              iconColor: WidgetStateProperty.resolveWith(
                (states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.white54;
                  }
                  return states.contains(WidgetState.selected) ? const Color(0xFF2563EB) : Colors.white70;
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
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}
