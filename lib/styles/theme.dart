import 'package:flutter/material.dart';

ThemeData buildTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: const Color(0xFF0A84FF),
      secondary: const Color(0xFF30D158),
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F7FB),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF0A0A0A),
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: const Color(0xFF1A1C1E),
      displayColor: const Color(0xFF1A1C1E),
      fontFamily: 'Roboto',
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0A84FF),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
  );
}
