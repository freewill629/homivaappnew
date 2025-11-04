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
    final motorIsOn = tankProvider.isOn ?? false;
    final manualMode = tankProvider.manualControlEnabled;
    final manualCommand = tankProvider.manualCommand ?? false;
    final manualModeKnown = manualMode != null;
    final manualModeEnabled = manualMode ?? false;
    final canToggle = tankProvider.canControl && !tankProvider.isWriting;
    final displayName = user != null ? _displayName(user) : null;
    final initials = user != null ? _initialsForUser(user) : 'H';

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFEFF3FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomivaLogo(size: 42),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Homiva',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Smart water intelligence for your home',
                            style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Sign out',
                      onPressed: () => context.read<AuthService>().signOut(),
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                if (tankProvider.error != null)
                  _DisconnectedBanner(message: tankProvider.error!),
                if (user != null)
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 24,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                          child: Text(
                            initials,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back',
                                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                displayName ?? 'Explorer',
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF4FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 18, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                tankProvider.isConnected ? 'Controller online' : 'Awaiting link',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 28),
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My tank',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Monitor and control your water storage in real time.',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          TankStatusChip(
                            isOn: motorIsOn,
                            hasStatus: tankProvider.hasStatus,
                            isConnected: tankProvider.isConnected,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      WaterLevelGauge(
                        levelPercent: tankProvider.waterLevelPercent,
                        isConnected: tankProvider.isConnected,
                        isLoading: tankProvider.isLoading && !tankProvider.hasData,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Last sync',
                                style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                updatedAtLabel,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const Spacer(),
                          LiveSyncStatus(
                            label: tankProvider.isConnected ? 'Live · syncing' : 'Awaiting connection',
                            isActive: tankProvider.isConnected,
                            color: const Color(0xFF475569),
                            activeDotColor: theme.colorScheme.primary,
                            inactiveDotColor: const Color(0xFFCBD5F5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.tungsten_outlined, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pump controls',
                                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Switch between automatic and manual overrides.',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          LiveSyncStatus(
                            label: tankProvider.isConnected ? 'Live' : 'Offline',
                            isActive: tankProvider.isConnected,
                            color: const Color(0xFF475569),
                            activeDotColor: theme.colorScheme.primary,
                            inactiveDotColor: const Color(0xFFCBD5F5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Manual mode',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  manualModeEnabled
                                      ? 'Manual overrides are active. Commands act instantly.'
                                      : 'Automatic safety is active. Enable manual mode to intervene.',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: tankProvider.isUpdatingManualControl
                                ? SizedBox(
                                    height: 28,
                                    width: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                                    ),
                                  )
                                : Switch(
                                    value: manualModeEnabled,
                                    onChanged: manualModeKnown
                                        ? (value) async {
                                            final success =
                                                await context.read<TankProvider>().toggleManualControl(value);
                                            if (!success && context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    value
                                                        ? 'Unable to enable manual mode. Please try again.'
                                                        : 'Unable to disable manual mode. Please try again.',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        : null,
                                    activeColor: theme.colorScheme.primary,
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TankToggle(
                        isOn: manualCommand,
                        enabled: canToggle,
                        busy: tankProvider.isWriting,
                        onChanged: (value) async {
                          final success = await context.read<TankProvider>().toggleTank(value);
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to update pump command. Please try again.')),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
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
                Text(
                  'Coming next',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
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

  String _displayName(User user) {
    final trimmedName = user.displayName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      return trimmedName;
    }

    final email = user.email;
    if (email != null && email.isNotEmpty) {
      final localPart = email.split('@').first;
      final normalized = localPart.replaceAll(RegExp(r'[._-]+'), ' ');
      final segments = normalized.split(RegExp(r'\s+')).where((segment) => segment.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        return segments.map(_capitalize).join(' ');
      }
      if (localPart.isNotEmpty) {
        return _capitalize(localPart);
      }
    }

    return 'Explorer';
  }

  String _initialsForUser(User user) {
    final name = _displayName(user);
    final parts = name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return 'H';
    }

    final first = parts.first;
    final last = parts.length > 1 ? parts.last : '';

    final buffer = StringBuffer();
    if (first.isNotEmpty) {
      buffer.write(first[0].toUpperCase());
    }
    if (last.isNotEmpty) {
      buffer.write(last[0].toUpperCase());
    }

    final result = buffer.toString();
    if (result.isNotEmpty) {
      return result;
    }

    return 'H';
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    if (value.length == 1) {
      return value.toUpperCase();
    }
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}

class _DisconnectedBanner extends StatelessWidget {
  const _DisconnectedBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF4D6), Color(0xFFFFEDD5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.35)),
        boxShadow: const [
          BoxShadow(color: Color(0x22F59E0B), blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Color(0xFFB45309)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF92400E),
                fontWeight: FontWeight.w600,
              ),
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
