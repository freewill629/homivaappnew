import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/tank_provider.dart';
import '../../widgets/live_sync_status.dart';
import '../../widgets/tank_status_chip.dart';
import '../../widgets/tank_toggle.dart';
import '../../widgets/water_level_gauge.dart';

class TankControlScreen extends StatelessWidget {
  const TankControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tankProvider = context.watch<TankProvider>();
    final level = tankProvider.waterLevel;
    final isOn = tankProvider.isOn ?? false;
    final hasData = tankProvider.hasData;
    final updatedAt = _formatTime(tankProvider.updatedAt);

    return Scaffold(
      appBar: AppBar(title: const Text('Tank Control')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (tankProvider.error != null)
            _InfoBanner(message: tankProvider.error!),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WaterLevelGauge(
                    level: level,
                    isConnected: tankProvider.isConnected,
                    isLoading: tankProvider.isLoading && !tankProvider.hasData,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stacked_line_chart, color: Color(0xFF0369A1)),
                        const SizedBox(width: 12),
                        Text(
                          'Recommended range 4.0 – 8.5',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0C4A6E),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.trending_flat, color: Color(0xFF1D4ED8)),
                      const SizedBox(width: 8),
                      Text(
                        'Trend: Steady',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Tank Power',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TankStatusChip(isOn: isOn, hasData: hasData),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LiveSyncStatus(
                    label: tankProvider.isConnected ? 'Live · syncing' : 'Awaiting connection',
                    isActive: tankProvider.isConnected,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Updated: $updatedAt',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  TankToggle(
                    isOn: isOn,
                    enabled: hasData && !tankProvider.isWriting,
                    busy: tankProvider.isWriting,
                    onChanged: (value) async {
                      final success = await context.read<TankProvider>().toggleTank(value);
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to update tank status. Please try again.')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Toggle writes directly to /tank/status in Firebase Realtime Database.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) {
      return '--:--:--';
    }
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    final seconds = time.second.toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF97316)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Color(0xFFF97316)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF9A3412)),
            ),
          ),
        ],
      ),
    );
  }
}
