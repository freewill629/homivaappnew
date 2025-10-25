import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/db_service.dart';
import 'services/tank_provider.dart';
import 'styles/theme.dart';

class HomivaApp extends StatelessWidget {
  const HomivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DbService>(create: (_) => DbService()),
        ChangeNotifierProxyProvider<DbService, TankProvider>(
          create: (context) => TankProvider(db: context.read<DbService>()),
          update: (_, db, previous) {
            final provider = previous ?? TankProvider(db: db);
            provider.attachDb(db);
            return provider;
          },
        ),
      ],
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          return StreamProvider<User?>(
            value: auth.authStateChanges,
            initialData: auth.currentUser,
            child: Consumer<TankProvider>(
              builder: (context, tankProvider, _) {
                return MaterialApp(
                  title: 'Homiva',
                  theme: buildTheme(),
                  home: AuthGate(tankProvider: tankProvider),
                  debugShowCheckedModeBanner: false,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({required this.tankProvider, super.key});

  final TankProvider tankProvider;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.watch<User?>();
    if (user != null) {
      widget.tankProvider.startListening();
    } else {
      widget.tankProvider.stopListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    if (user == null) {
      return const LoginScreen();
    }
    return const DashboardScreen();
  }
}
