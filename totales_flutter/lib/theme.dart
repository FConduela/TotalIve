import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF1a1a2e);
  static const card = Color(0xFF16213e);
  static const input = Color(0xFF2b2b2b);
  static const border = Color(0xFF2a6ba0);
  static const text = Color(0xFFe8e8e8);
  static const textMuted = Color(0xFFa0a0a0);
  static const primary = Color(0xFF1f538d);
  static const success = Color(0xFF2FA572);
  static const danger = Color(0xFFD32F2F);
  static const warning = Color(0xFFFF6B35);
  static const totalBadge = Color(0xFF2196F3);
  static const selected = Color(0xFF4CAF50);
}

const List<int> valoresBotones = [
  0, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500,
];

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.success,
      surface: AppColors.card,
      error: AppColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.card,
      foregroundColor: AppColors.text,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.card,
      indicatorColor: AppColors.selected,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    ),
  );
}
