import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/tank_provider.dart';
import '../../widgets/card_placeholder.dart';
import '../tank/tank_control_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    final tankProvider = context.watch<TankProvider>();
    final isLoading = tankProvider.isLoading && tankProvider.waterLevel == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
            Text('Welcome back, ${user.email}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TankControlScreen(isLoading: isLoading),
          const SizedBox(height: 24),
          Text('Product roadmap', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._placeholderFeatures.map(
            (feature) => CardPlaceholder(
              title: feature.title,
              description: feature.description,
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

const _placeholderFeatures = [
  _FeatureDescription('Automatic water level control', 'Set thresholds to auto-fill or drain the tank.'),
  _FeatureDescription('Multi-tank monitoring', 'Monitor multiple tanks across properties in real-time.'),
  _FeatureDescription('Water quality insights', 'Track TDS, pH, and contaminants with AI-driven alerts.'),
  _FeatureDescription('Usage analytics', 'See daily and monthly consumption trends.'),
  _FeatureDescription('Emergency & tampering alerts', 'Get notified instantly for leaks, overflow, or tampering.'),
  _FeatureDescription('Solar & energy optimization', 'Integrate solar pumps and optimize energy usage.'),
  _FeatureDescription('Maintenance assistant', 'Guided cleaning schedules and service reminders.'),
];
