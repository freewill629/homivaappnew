import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/tank_provider.dart';
import '../../widgets/tank_toggle.dart';
import '../../widgets/water_level_gauge.dart';

class TankControlScreen extends StatelessWidget {
  const TankControlScreen({required this.isLoading, super.key});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final tankProvider = context.watch<TankProvider>();
    final level = tankProvider.waterLevel;
    final isOn = tankProvider.isOn ?? false;
    final hasError = tankProvider.error != null;
    final toggleEnabled = tankProvider.isOn != null && !tankProvider.isLoading;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tank Status', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                if (isLoading)
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: _buildContent(context, isOn, level, hasError, toggleEnabled),
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildDetails(context, isOn, level, hasError, toggleEnabled),
                      ),
                    ),
                    const SizedBox(width: 32),
                    WaterLevelGauge(level: level),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    bool isOn,
    double? level,
    bool hasError,
    bool toggleEnabled,
  ) {
    return [
      WaterLevelGauge(level: level),
      const SizedBox(height: 24),
      ..._buildDetails(context, isOn, level, hasError, toggleEnabled),
    ];
  }

  List<Widget> _buildDetails(
    BuildContext context,
    bool isOn,
    double? level,
    bool hasError,
    bool toggleEnabled,
  ) {
    final provider = context.read<TankProvider>();
    return [
      Row(
        children: [
          const Icon(Icons.water_drop_outlined, color: Color(0xFF0A84FF)),
          const SizedBox(width: 8),
          Text('Real-time water level', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        '${level?.toStringAsFixed(1) ?? '--'} / 10',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          const Icon(Icons.power_settings_new, color: Color(0xFF30D158)),
          const SizedBox(width: 8),
          Text('Tank power', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
      const SizedBox(height: 12),
      IgnorePointer(
        ignoring: !toggleEnabled,
        child: Opacity(
          opacity: toggleEnabled ? 1 : 0.5,
          child: TankToggle(
            isOn: isOn,
            onChanged: provider.toggleTank,
          ),
        ),
      ),
      if (!toggleEnabled) ...[
        const SizedBox(height: 8),
        Text(
          'Connecting to tank…',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
      if (hasError) ...[
        const SizedBox(height: 16),
        Text(
          'Unable to sync tank data. Check your connection.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
        ),
      ],
    ];
  }
}
