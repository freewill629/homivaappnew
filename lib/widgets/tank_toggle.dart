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
              ButtonSegment(value: false, label: Text('OFF'), icon: Icon(Icons.power_off_outlined)),
              ButtonSegment(value: true, label: Text('ON'), icon: Icon(Icons.power_outlined)),
            ],
            selected: <bool>{isOn},
            onSelectionChanged: onSelectionChanged,
          ),
        ),
        if (busy)
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
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
