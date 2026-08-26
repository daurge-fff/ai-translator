import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static const double buttonRadius = 22.0;

  static ThemeData get lightTheme => _build(
        brightness: Brightness.light,
        scaffold: AppColors.lightBackground,
        cardColor: Colors.white,
        scheme: const ColorScheme.light(
          primary: AppColors.primaryBlue,
          secondary: AppColors.primaryIndigo,
          surface: Colors.white,
          onSurface: AppColors.lightTextPrimary,
        ),
      );

  static ThemeData get darkTheme => _build(
        brightness: Brightness.dark,
        scaffold: AppColors.darkBackground,
        cardColor: AppColors.darkSystemGray6,
        scheme: const ColorScheme.dark(
          primary: AppColors.primaryBlue,
          secondary: AppColors.primaryIndigo,
          surface: AppColors.darkSystemGray6,
          onSurface: AppColors.darkTextPrimary,
        ),
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color scaffold,
    required Color cardColor,
    required ColorScheme scheme,
  }) {
    final isDark = brightness == Brightness.dark;
    final accent = scheme.primary;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final divider = AppColors.separator(isDark);

    final baseText = ThemeData(brightness: brightness).textTheme;
    final textTheme = baseText.copyWith(
      titleLarge: baseText.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: textPrimary,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(
        fontSize: 17,
        height: 1.35,
        color: textPrimary,
      ),
      bodyMedium: baseText.bodyMedium?.copyWith(
        fontSize: 15,
        height: 1.35,
        color: textPrimary,
      ),
      bodySmall: baseText.bodySmall?.copyWith(
        fontSize: 13,
        color: textSecondary,
      ),
      labelLarge: baseText.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );

    final buttonShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: scheme,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: accent.withValues(alpha: isDark ? 0.14 : 0.10),
      hoverColor: accent.withValues(alpha: 0.04),
      dividerColor: divider,
      disabledColor: isDark ? Colors.white30 : Colors.black26,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.08),
          disabledForegroundColor: isDark ? Colors.white38 : Colors.black38,
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: buttonShape,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: buttonShape,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: accent.withValues(alpha: 0.6), width: 1),
          shape: buttonShape,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : const Color(0xFFD1D1D6),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accent
              : (isDark
                  ? AppColors.darkSystemGray4
                  : AppColors.lightSystemGray5),
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: isDark
            ? AppColors.darkSystemGray4
            : AppColors.lightSystemGray5,
        thumbColor: Colors.white,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
        trackHeight: 4,
        overlayColor: accent.withValues(alpha: 0.14),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
        valueIndicatorColor: accent,
        showValueIndicator: ShowValueIndicator.onlyForDiscrete,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        contentTextStyle: TextStyle(fontSize: 15, color: textPrimary),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: false,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fill(isDark),
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
        labelStyle: TextStyle(color: textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.6), width: 1.2),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C1C1E),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        circularTrackColor: Colors.transparent,
        linearTrackColor: isDark ? Colors.white12 : Colors.black12,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.fill(isDark),
        disabledColor: AppColors.fill(isDark),
        selectedColor: accent.withValues(alpha: 0.18),
        secondarySelectedColor: accent.withValues(alpha: 0.18),
        labelStyle: TextStyle(fontSize: 13, color: textPrimary),
        secondaryLabelStyle: TextStyle(fontSize: 13, color: accent),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide.none,
      ),

      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 0.5,
        space: 0.5,
      ),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        iconColor: accent,
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        labelColor: accent,
        unselectedLabelColor: textSecondary,
        indicatorSize: TabBarIndicatorSize.label,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),

      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: accent,
        scaffoldBackgroundColor: scaffold,
      ),
    );
  }
}
