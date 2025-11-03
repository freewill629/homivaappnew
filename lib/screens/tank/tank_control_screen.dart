import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/tank_provider.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/live_sync_status.dart';
import '../../widgets/tank_status_chip.dart';
import '../../widgets/tank_toggle.dart';
import '../../widgets/water_level_gauge.dart';

class TankControlScreen extends StatelessWidget {
  const TankControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tankProvider = context.watch<TankProvider>();
    final levelPercent = tankProvider.waterLevelPercent;
    final motorIsOn = tankProvider.isOn ?? false;
    final manualMode = tankProvider.manualControlEnabled;
    final manualModeKnown = manualMode != null;
    final manualModeEnabled = manualMode ?? false;
    final manualCommand = tankProvider.manualCommand ?? false;
    final updatedAt = _formatTime(tankProvider.updatedAt);

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tank controls',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Fine tune your tank with live automation overrides.',
              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
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
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tankProvider.error != null)
                  _InfoBanner(message: tankProvider.error!),
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
                            child: Icon(Icons.insights_outlined, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Water level overview',
                                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Live readings refresh automatically every few seconds.',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          TankStatusChip(
                            isOn: motorIsOn,
                            hasStatus: tankProvider.hasStatus,
                            isConnected: tankProvider.isConnected,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      WaterLevelGauge(
                        levelPercent: levelPercent,
                        isConnected: tankProvider.isConnected,
                        isLoading: tankProvider.isLoading && !tankProvider.hasData,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(0xFFEEF2FF),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.auto_graph_outlined, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                levelPercent != null
                                    ? 'Current fill level at ${levelPercent.toStringAsFixed(0)}% · Optimal range 45% – 85%'
                                    : 'Optimal range 45% – 85% when readings resume',
                                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF475569)),
                              ),
                            ),
                          ],
                        ),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Power command center',
                                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Send overrides instantly or let automation take control.',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          LiveSyncStatus(
                            label: tankProvider.isConnected ? 'Live · syncing' : 'Awaiting connection',
                            isActive: tankProvider.isConnected,
                            color: const Color(0xFF475569),
                            activeDotColor: theme.colorScheme.primary,
                            inactiveDotColor: const Color(0xFFCBD5F5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Updated: $updatedAt',
                        style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        manualModeEnabled
                            ? 'Manual overrides are active. Commands will write directly to the controller.'
                            : 'Automatic scheduling manages your pump. Enable manual mode to issue commands here.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
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
                                  'Override automation temporarily to test or service hardware.',
                                  style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF94A3B8)),
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
                        enabled: tankProvider.canControl && !tankProvider.isWriting,
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
                      Text(
                        'This control writes directly to /data/manual_command in Firebase Realtime Database.',
                        style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
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

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

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
