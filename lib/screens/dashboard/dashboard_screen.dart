import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/tank_provider.dart';
import '../../widgets/card_placeholder.dart';
import '../../widgets/live_sync_status.dart';
import '../../widgets/tank_status_chip.dart';
import '../../widgets/tank_toggle.dart';
import '../../widgets/water_level_gauge.dart';
import '../tank/tank_control_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    final tankProvider = context.watch<TankProvider>();
    final updatedAtLabel = _formatTime(tankProvider.updatedAt);
    final hasData = tankProvider.hasData;
    final isOn = tankProvider.isOn ?? false;
    final canToggle = hasData && !tankProvider.isWriting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homiva MVP'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => context.read<AuthService>().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          if (tankProvider.error != null)
            _DisconnectedBanner(message: tankProvider.error!),
          if (user != null) ...[
            Text(
              'Welcome back, ${user.email}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WaterLevelGauge(
                    level: tankProvider.waterLevel,
                    isConnected: tankProvider.isConnected,
                    isLoading: tankProvider.isLoading && !tankProvider.hasData,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 8),
                  LiveSyncStatus(
                    label: tankProvider.isConnected ? 'Live · syncing' : 'Awaiting connection',
                    isActive: tankProvider.isConnected,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Updated: $updatedAtLabel',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  TankToggle(
                    isOn: isOn,
                    enabled: canToggle,
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
                    'Segmentation ensures hardware-safe switching between ON/OFF.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const TankControlScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open full tank control'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Product roadmap', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: _features.length,
            itemBuilder: (context, index) {
              final feature = _features[index];
              return CardPlaceholder(
                title: feature.title,
                description: feature.description,
              );
            },
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

class _DisconnectedBanner extends StatelessWidget {
  const _DisconnectedBanner({required this.message});

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

class _FeatureDescription {
  const _FeatureDescription(this.title, this.description);

  final String title;
  final String description;
}

const _features = [
  _FeatureDescription('Automatic water level control', 'Auto-fill and drain orchestration with adaptive scheduling.'),
  _FeatureDescription('Real-time multi-tank monitoring', 'Live insights across every connected storage tank.'),
  _FeatureDescription('IoT device management', 'Pair new controllers, push OTA firmware, stay updated.'),
  _FeatureDescription('Water quality monitoring', 'TDS, pH and mineral intelligence with AI recommendations.'),
  _FeatureDescription('Usage analytics & AI reports', 'Predictive consumption reports and household insights.'),
  _FeatureDescription('Low-water alerts & emergency mode', 'Emergency cut-offs and mobile alerts before tanks run dry.'),
  _FeatureDescription('Manual bypass options (hardware)', 'Guided fallback hardware overrides for technicians.'),
  _FeatureDescription('Self-cleaning assistance', 'Automated rinse cycles with reminders and logs.'),
  _FeatureDescription('Solar-powered operation widgets', 'Sync solar pumps and energy budgets automatically.'),
  _FeatureDescription('Safety & security (leak/overflow)', 'Leak, overflow, and intrusion detection at a glance.'),
  _FeatureDescription('Tank tampering alerts', 'Get notified on unauthorized access or tamper events.'),
  _FeatureDescription('Modular upgrade kits', 'Plug-and-play expansion packs for new capabilities.'),
  _FeatureDescription('Hard water conversion controls', 'Switch between softening modes remotely.'),
  _FeatureDescription('Built-in water purification controls', 'RO/UV automation with filter health tracking.'),
  _FeatureDescription('Rainwater harvesting views', 'Capture inflow analytics and recharge efficiency.'),
];
