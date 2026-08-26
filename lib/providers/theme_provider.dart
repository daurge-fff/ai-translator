import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BrandAccentColor {
  blue(Color(0xFF007AFF), 'Blue'),
  indigo(Color(0xFF5856D6), 'Indigo'),
  purple(Color(0xFFAF52DE), 'Purple'),
  teal(Color(0xFF30B0C7), 'Teal'),
  rose(Color(0xFFFF2D55), 'Rose'),
  orange(Color(0xFFFF9500), 'Orange'),
  green(Color(0xFF34C759), 'Green'),
  cyan(Color(0xFF00C7BE), 'Cyan'),
  pink(Color(0xFFFF6B9D), 'Pink'),
  amber(Color(0xFFFFCC02), 'Amber'),
  red(Color(0xFFFF3B30), 'Red'),
  mint(Color(0xFF00D68F), 'Mint');

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

  ThemeState({
    this.themeMode = ThemeMode.system,
    this.reduceTransparency = false,
    this.glassBlurSigma = 25.0,
    this.glassOpacity = 0.60,
    this.accentColor = BrandAccentColor.blue,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? reduceTransparency,
    double? glassBlurSigma,
    double? glassOpacity,
    BrandAccentColor? accentColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      reduceTransparency: reduceTransparency ?? this.reduceTransparency,
      glassBlurSigma: glassBlurSigma ?? this.glassBlurSigma,
      glassOpacity: glassOpacity ?? this.glassOpacity,
      accentColor: accentColor ?? this.accentColor,
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
    state = state.copyWith(accentColor: color);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);
