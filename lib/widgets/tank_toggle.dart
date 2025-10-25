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
          height: 56,
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Power off'),
                icon: Icon(Icons.power_settings_new),
              ),
              ButtonSegment(
                value: true,
                label: Text('Power on'),
                icon: Icon(Icons.bolt),
              ),
            ],
            showSelectedIcon: false,
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              side: MaterialStateProperty.resolveWith(
                (states) {
                  if (states.contains(MaterialState.disabled)) {
                    return const BorderSide(color: Color(0x33FFFFFF));
                  }
                  if (states.contains(MaterialState.selected)) {
                    return const BorderSide(color: Color(0xFF1E3A8A), width: 1.4);
                  }
                  return const BorderSide(color: Color(0xFFCBD5F5));
                },
              ),
              backgroundColor: MaterialStateProperty.resolveWith(
                (states) {
                  if (states.contains(MaterialState.disabled)) {
                    return Colors.white.withOpacity(0.08);
                  }
                  if (states.contains(MaterialState.selected)) {
                    return const Color(0xFFEEF2FF);
                  }
                  return Colors.white.withOpacity(0.18);
                },
              ),
              foregroundColor: MaterialStateProperty.resolveWith(
                (states) {
                  if (states.contains(MaterialState.disabled)) {
                    return Colors.white54;
                  }
                  if (states.contains(MaterialState.selected)) {
                    return const Color(0xFF1D4ED8);
                  }
                  return Colors.white;
                },
              ),
              textStyle: MaterialStateProperty.all(
                const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
              ),
              iconColor: MaterialStateProperty.resolveWith(
                (states) {
                  if (states.contains(MaterialState.disabled)) {
                    return Colors.white54;
                  }
                  return states.contains(MaterialState.selected) ? const Color(0xFF2563EB) : Colors.white70;
                },
              ),
            ),
            selected: <bool>{isOn},
            onSelectionChanged: onSelectionChanged,
          ),
        ),
        if (busy)
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
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
