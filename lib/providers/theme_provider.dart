import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BrandAccentColor {
  blue(Color(0xFF007AFF), 'Синий Apple'),
  indigo(Color(0xFF5856D6), 'Индиго'),
  purple(Color(0xFFAF52DE), 'Фиолетовый'),
  teal(Color(0xFF30B0C7), 'Бирюзовый'),
  rose(Color(0xFFFF2D55), 'Розовый');

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
