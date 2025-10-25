import 'package:flutter/material.dart';

class TankToggle extends StatelessWidget {
  const TankToggle({required this.isOn, required this.onChanged, super.key});

  final bool isOn;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: false, label: Text('OFF'), icon: Icon(Icons.power_off_outlined)),
          ButtonSegment(value: true, label: Text('ON'), icon: Icon(Icons.power_outlined)),
        ],
        selected: <bool>{isOn},
        onSelectionChanged: (selected) => onChanged(selected.first),
      ),
    );
  }
}
