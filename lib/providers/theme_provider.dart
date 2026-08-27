import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BrandAccentColor {
  blue(Color(0xFF007AFF), 'Blue'),
  indigo(Color(0xFF5856D6), 'Indigo'),
  purple(Color(0xFFAF52DE), 'Purple'),
  pink(Color(0xFFFF2D55), 'Pink'),
  red(Color(0xFFFF3B30), 'Red'),
  orange(Color(0xFFFF9500), 'Orange'),
  green(Color(0xFF34C759), 'Green'),
  teal(Color(0xFF30B0C7), 'Teal');

  final Color color;
  final String label;
  const BrandAccentColor(this.color, this.label);
}

class ThemeState {
  final ThemeMode themeMode;
  final bool reduceTransparency;
  final double glassBlurSigma;
  final double glassOpacity;
  final BrandAccentColor accentColor;
  final bool useDeviceTheme;

  ThemeState({
    this.themeMode = ThemeMode.system,
    this.reduceTransparency = false,
    this.glassBlurSigma = 25.0,
    this.glassOpacity = 0.60,
    this.accentColor = BrandAccentColor.blue,
    this.useDeviceTheme = false,
  });

  Color get effectiveAccent {
    if (useDeviceTheme) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? const Color(0xFF8AB4F8)
          : const Color(0xFF1A73E8);
    }
    return accentColor.color;
  }

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? reduceTransparency,
    double? glassBlurSigma,
    double? glassOpacity,
    BrandAccentColor? accentColor,
    bool? useDeviceTheme,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      reduceTransparency: reduceTransparency ?? this.reduceTransparency,
      glassBlurSigma: glassBlurSigma ?? this.glassBlurSigma,
      glassOpacity: glassOpacity ?? this.glassOpacity,
      accentColor: accentColor ?? this.accentColor,
      useDeviceTheme: useDeviceTheme ?? this.useDeviceTheme,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState());

  void toggleTheme() {
    if (state.themeMode == ThemeMode.dark) {
      state = state.copyWith(themeMode: ThemeMode.light);
    } else {
      state = state.copyWith(themeMode: ThemeMode.dark);
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void toggleReduceTransparency() {
    state = state.copyWith(reduceTransparency: !state.reduceTransparency);
  }

  void setGlassBlurSigma(double sigma) {
    state = state.copyWith(glassBlurSigma: sigma);
  }

  void setGlassOpacity(double opacity) {
    state = state.copyWith(glassOpacity: opacity);
  }

  void setAccentColor(BrandAccentColor color) {
    state = state.copyWith(accentColor: color, useDeviceTheme: false);
  }

  void setUseDeviceTheme() {
    state = state.copyWith(useDeviceTheme: true);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);
