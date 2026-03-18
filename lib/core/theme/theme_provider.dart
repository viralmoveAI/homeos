import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode {
  mintyFresh,
  oceanView,
  sunsetGlow,
  midnightMystery,
  royalPurple,
  berryBlast,
  custom;

  String get displayName {
    switch (this) {
      case AppThemeMode.mintyFresh:
        return 'Minty Fresh';
      case AppThemeMode.oceanView:
        return 'Ocean View';
      case AppThemeMode.sunsetGlow:
        return 'Sunset Glow';
      case AppThemeMode.midnightMystery:
        return 'Midnight';
      case AppThemeMode.royalPurple:
        return 'Royal';
      case AppThemeMode.berryBlast:
        return 'Berry';
      case AppThemeMode.custom:
        return 'Custom';
    }
  }
}

class ThemeState {
  final AppThemeMode mode;
  final List<Color> customColors;

  ThemeState({
    required this.mode,
    this.customColors = const [Color(0xFF6A11CB), Color(0xFF2575FC)],
  });

  LinearGradient get gradient {
    if (mode == AppThemeMode.custom) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: customColors,
      );
    }

    switch (mode) {
      case AppThemeMode.mintyFresh:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6F6F1), Color(0xFF86E2C6)],
        );
      case AppThemeMode.oceanView:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6F0FF), Color(0xFF6B9CFF)],
        );
      case AppThemeMode.sunsetGlow:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0E6), Color(0xFFFF9F43)],
        );
      case AppThemeMode.midnightMystery:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF232526), Color(0xFF414345)],
        );
      case AppThemeMode.royalPurple:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6441A5), Color(0xFF2a0845)],
        );
      case AppThemeMode.berryBlast:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        );
      case AppThemeMode.custom:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: customColors,
        );
    }
  }

  ThemeState copyWith({AppThemeMode? mode, List<Color>? customColors}) {
    return ThemeState(
      mode: mode ?? this.mode,
      customColors: customColors ?? this.customColors,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return ThemeState(mode: AppThemeMode.mintyFresh);
  }

  void setTheme(AppThemeMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setCustomColors(List<Color> colors) {
    state = state.copyWith(mode: AppThemeMode.custom, customColors: colors);
  }
}

final appThemeNavigatorProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  () => ThemeNotifier(),
);
