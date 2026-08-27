import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  ThemeNotifier() : super(ThemeState()) {
    _load();
  }

  static const _kThemeMode = 'theme_mode';
  static const _kReduceTransparency = 'reduce_transparency';
  static const _kAccentIndex = 'accent_index';
  static const _kUseDeviceTheme = 'use_device_theme';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_kThemeMode) ?? 0;
    final accentIndex = prefs.getInt(_kAccentIndex) ?? 0;
    final useDevice = prefs.getBool(_kUseDeviceTheme) ?? false;
    final reduce = prefs.getBool(_kReduceTransparency) ?? false;

    state = state.copyWith(
      themeMode: ThemeMode.values[modeIndex.clamp(0, ThemeMode.values.length - 1)],
      accentColor: BrandAccentColor.values[accentIndex.clamp(0, BrandAccentColor.values.length - 1)],
      useDeviceTheme: useDevice,
      reduceTransparency: reduce,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeMode, state.themeMode.index);
    await prefs.setInt(_kAccentIndex, state.accentColor.index);
    await prefs.setBool(_kUseDeviceTheme, state.useDeviceTheme);
    await prefs.setBool(_kReduceTransparency, state.reduceTransparency);
  }

  void toggleTheme() {
    if (state.themeMode == ThemeMode.dark) {
      state = state.copyWith(themeMode: ThemeMode.light);
    } else {
      state = state.copyWith(themeMode: ThemeMode.dark);
    }
    _save();
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _save();
  }

  void toggleReduceTransparency() {
    state = state.copyWith(reduceTransparency: !state.reduceTransparency);
    _save();
  }

  void setGlassBlurSigma(double sigma) {
    state = state.copyWith(glassBlurSigma: sigma);
  }

  void setGlassOpacity(double opacity) {
    state = state.copyWith(glassOpacity: opacity);
  }

  void setAccentColor(BrandAccentColor color) {
    state = state.copyWith(accentColor: color, useDeviceTheme: false);
    _save();
  }

  void setUseDeviceTheme() {
    state = state.copyWith(useDeviceTheme: true);
    _save();
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);
