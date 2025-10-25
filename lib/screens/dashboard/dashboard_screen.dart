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
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Welcome back, ${user.email}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          if (tankProvider.error != null)
            _DisconnectedBanner(message: tankProvider.error!),
          _TankOverviewCard(
            provider: tankProvider,
            updatedAtLabel: updatedAtLabel,
          ),
          const SizedBox(height: 16),
          _TankPowerCard(
            isOn: isOn,
            canToggle: canToggle,
            provider: tankProvider,
          ),
          const SizedBox(height: 24),
          Text(
            'Product roadmap',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const _ProductRoadmapGrid(),
        ],
      ),
    );
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

String _formatTime(DateTime? time) {
  if (time == null) {
    return '--:--:--';
  }
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  final seconds = time.second.toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

class _TankOverviewCard extends StatelessWidget {
  const _TankOverviewCard({
    required this.provider,
    required this.updatedAtLabel,
  });

  final TankProvider provider;
  final String updatedAtLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Water level',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                LiveSyncStatus(
                  label: provider.isConnected ? 'Live · syncing' : 'Awaiting connection',
                  isActive: provider.isConnected,
                ),
              ],
            ),
            const SizedBox(height: 20),
            WaterLevelGauge(
              level: provider.waterLevel,
              isConnected: provider.isConnected,
              isLoading: provider.isLoading && !provider.hasData,
            ),
            const SizedBox(height: 16),
            Text(
              'Updated: $updatedAtLabel',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _TankPowerCard extends StatelessWidget {
  const _TankPowerCard({
    required this.isOn,
    required this.canToggle,
    required this.provider,
  });

  final bool isOn;
  final bool canToggle;
  final TankProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Tank Power',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TankStatusChip(isOn: isOn, hasData: provider.hasData),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Toggle tank hardware remotely with live safety checks.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            TankToggle(
              isOn: isOn,
              enabled: canToggle,
              busy: provider.isWriting,
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
            Row(
              children: [
                LiveSyncStatus(
                  label: provider.isConnected ? 'Live · syncing' : 'Awaiting connection',
                  isActive: provider.isConnected,
                ),
                const Spacer(),
                Text(
                  'Updated: ${_formatTime(provider.updatedAt)}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
    );
  }
}

class _ProductRoadmapGrid extends StatelessWidget {
  const _ProductRoadmapGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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
    );
  }
}

const _features = [
  _FeatureDescription('Water Quality', 'AI-based TDS, pH and mineral tracking.'),
  _FeatureDescription('AI Analytics', 'Consumption forecasting with adaptive alerts.'),
  _FeatureDescription('Smart Alerts', 'Low-water and overflow warnings to your phone.'),
  _FeatureDescription('Solar Integration', 'Coordinate solar pumps for energy savings.'),
  _FeatureDescription('Safety & Security', 'Leak and tamper detection across tanks.'),
  _FeatureDescription('Purifier Control', 'Remote RO/UV purifier automation.'),
  _FeatureDescription('Rainwater Harvesting', 'Monitor rooftop inflow and recharge stats.'),
  _FeatureDescription('Tamper Alerts', 'Instant notifications for unauthorized access events.'),
];
