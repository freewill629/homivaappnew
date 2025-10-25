import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/tank_provider.dart';
import '../../widgets/card_placeholder.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/homiva_logo.dart';
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
    final isOn = tankProvider.isOn ?? false;
    final canToggle = tankProvider.canControl && !tankProvider.isWriting;

    final theme = Theme.of(context);
    final headline = theme.textTheme.headlineMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    );
    final subtle = theme.textTheme.bodyMedium?.copyWith(color: Colors.white70);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const HomivaLogo(size: 36),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Homiva', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                Text('Smart water intelligence', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => context.read<AuthService>().signOut(),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1121), Color(0xFF111F4D), Color(0xFF1F3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tankProvider.error != null)
                  _DisconnectedBanner(message: tankProvider.error!),
                if (user != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back,', style: subtle),
                      const SizedBox(height: 4),
                      Text(user.email ?? 'Explorer', style: headline),
                      const SizedBox(height: 24),
                    ],
                  ),
                GlassContainer(
                  child: Column(
                    children: [
                      WaterLevelGauge(
                        levelPercent: tankProvider.waterLevelPercent,
                        isConnected: tankProvider.isConnected,
                        isLoading: tankProvider.isLoading && !tankProvider.hasData,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Last sync', style: subtle),
                              const SizedBox(height: 4),
                              Text(updatedAtLabel, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          LiveSyncStatus(
                            label: tankProvider.isConnected ? 'Live · syncing' : 'Awaiting connection',
                            isActive: tankProvider.isConnected,
                            color: Colors.white70,
                            activeDotColor: const Color(0xFF34D399),
                            inactiveDotColor: Colors.white24,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Tank power orchestration', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          TankStatusChip(
                            isOn: isOn,
                            hasStatus: tankProvider.hasStatus,
                            isConnected: tankProvider.isConnected,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LiveSyncStatus(
                        label: tankProvider.isConnected ? 'Live · syncing' : 'Awaiting connection',
                        isActive: tankProvider.isConnected,
                        color: Colors.white70,
                        activeDotColor: const Color(0xFF34D399),
                        inactiveDotColor: Colors.white24,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Remote switching updates the ESP32 relay instantly. Your hardware stays protected with software interlocks.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(foregroundColor: Colors.white),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const TankControlScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.fullscreen, size: 20),
                          label: const Text('Open immersive controls'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('Coming next', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.15,
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
          ),
        ),
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
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD9C0), Color(0xFFFFEDD5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(color: Color(0x33F97316), blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Color(0xFF9A3412)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF7C2D12), fontWeight: FontWeight.w600),
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
