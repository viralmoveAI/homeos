import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode {
  mintyFresh,
  oceanView,
  sunsetGlow;

  String get displayName {
    switch (this) {
      case AppThemeMode.mintyFresh:
        return 'Minty Fresh';
      case AppThemeMode.oceanView:
        return 'Ocean View';
      case AppThemeMode.sunsetGlow:
        return 'Sunset Glow';
    }
  }

  LinearGradient get gradient {
    switch (this) {
      case AppThemeMode.mintyFresh:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE6F6F1), // Very light mint
            Color(0xFF86E2C6), // Mint green
          ],
        );
      case AppThemeMode.oceanView:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE6F0FF), // Light soft blue
            Color(0xFF6B9CFF), // Primary blue
          ],
        );
      case AppThemeMode.sunsetGlow:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF0E6), // Light peach
            Color(0xFFFF9F43), // Warning orange
          ],
        );
    }
  }
}

class ThemeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    return AppThemeMode.mintyFresh;
  }

  void setTheme(AppThemeMode mode) {
    state = mode;
  }
}

final appThemeNavigatorProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(
  () {
    return ThemeNotifier();
  },
);
