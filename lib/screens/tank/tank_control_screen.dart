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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tungsten, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Tank control', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF312E81)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tankProvider.error != null)
                  _InfoBanner(message: tankProvider.error!),
                GlassContainer(
                  child: Column(
                    children: [
                      WaterLevelGauge(
                        levelPercent: levelPercent,
                        isConnected: tankProvider.isConnected,
                        isLoading: tankProvider.isLoading && !tankProvider.hasData,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.insights, color: Colors.white),
                                const SizedBox(width: 12),
                                Text(
                                  'Optimal range 45% – 85%',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            Text(
                              levelPercent != null ? '${levelPercent.toStringAsFixed(0)}% full' : '--',
                              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.trending_up, color: Colors.white.withValues(alpha: 0.9)),
                          const SizedBox(width: 8),
                          Text('Trend: Steady', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
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
                          Text(
                            'Pump power control',
                            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          TankStatusChip(
                            isOn: motorIsOn,
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
                        'Updated: $updatedAt',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        manualModeEnabled
                            ? 'Send manual commands with confidence. Smart safeguards avoid rapid switching and keep relays healthy.'
                            : 'Automatic scheduling is in control. Enable manual mode to send pump commands from here.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Manual mode',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'When enabled you can override the controller directly from this panel.',
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: tankProvider.isUpdatingManualControl
                                ? const SizedBox(
                                    height: 28,
                                    width: 28,
                                    child: CircularProgressIndicator(strokeWidth: 2),
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
                                    thumbColor: WidgetStateProperty.resolveWith(
                                      (states) {
                                        if (states.contains(WidgetState.disabled)) {
                                          return Colors.white54;
                                        }
                                        if (states.contains(WidgetState.selected)) {
                                          return Colors.white;
                                        }
                                        return Colors.white70;
                                      },
                                    ),
                                    trackColor: WidgetStateProperty.resolveWith(
                                      (states) {
                                        if (states.contains(WidgetState.disabled)) {
                                          return Colors.white24;
                                        }
                                        if (states.contains(WidgetState.selected)) {
                                          return const Color(0xFF2563EB);
                                        }
                                        return Colors.white24;
                                      },
                                    ),
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
                        'This control writes directly to /tank/manual_command in Firebase Realtime Database.',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
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

