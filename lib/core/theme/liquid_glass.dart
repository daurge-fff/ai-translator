import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

// ---------------------------------------------------------------------------
// Glass variant – mirrors Apple's Glass struct (.regular, .clear, .tint, .interactive)
// ---------------------------------------------------------------------------

enum GlassStyle { regular, clear }

class Glass {
  final GlassStyle style;
  final Color? tintColor;
  final bool interactive;

  const Glass._({required this.style, this.tintColor, this.interactive = false});

  static const Glass regular = Glass._(style: GlassStyle.regular);
  static const Glass clear = Glass._(style: GlassStyle.clear);

  Glass tint(Color color) => Glass._(
        style: style,
        tintColor: color,
        interactive: interactive,
      );

  Glass interactiveMode() => Glass._(
        style: style,
        tintColor: tintColor,
        interactive: true,
      );
}

// ---------------------------------------------------------------------------
// LiquidGlassEffect – core widget that applies the glass material
// ---------------------------------------------------------------------------

class LiquidGlassEffect extends ConsumerWidget {
  final Widget child;
  final Glass glass;
  final ShapeBorder? shape;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? height;
  final double? width;

  const LiquidGlassEffect({
    super.key,
    required this.child,
    this.glass = Glass.regular,
    this.shape,
    this.borderRadius,
    this.padding,
    this.margin,
    this.onTap,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final disableGlass = themeState.reduceTransparency ||
        mediaQuery.accessibleNavigation ||
        mediaQuery.highContrast;

    final radius = borderRadius ?? 28.0;
    final blurSigma = themeState.glassBlurSigma;
    final opacity = glass.style == GlassStyle.clear
        ? math.min(themeState.glassOpacity * 0.5, 0.30)
        : themeState.glassOpacity;

    // Colors based on glass variant
    final surfaceColor = _surfaceColor(isDark, opacity, glass.tintColor);
    final borderColor = _borderColor(isDark, glass.tintColor);
    final specularColor = _specularColor(isDark);

    Widget content = Container(
      height: height,
      width: width,
      padding: padding ?? const EdgeInsets.all(22.0),
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: disableGlass
            ? (isDark ? const Color(0xFF1C1C24) : Colors.white)
            : surfaceColor,
        border: Border.all(
          color: disableGlass
              ? (isDark ? Colors.white12 : Colors.black12)
              : borderColor,
          width: 1.0,
        ),
      ),
      child: child,
    );

    if (disableGlass) {
      return onTap != null ? GestureDetector(onTap: onTap, child: content) : content;
    }

    // Specular rim – bright edge gradient mimicking Apple's glass reflection
    Widget glassWidget = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.3, 0.7, 1.0],
              colors: [
                specularColor.withValues(alpha: 0.12),
                Colors.transparent,
                Colors.transparent,
                specularColor.withValues(alpha: 0.06),
              ],
            ),
          ),
          child: content,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: glassWidget,
        ),
      );
    }
    return glassWidget;
  }

  Color _surfaceColor(bool isDark, double opacity, Color? tint) {
    if (tint != null) {
      return tint.withValues(alpha: isDark ? 0.18 : 0.22);
    }
    return isDark
        ? const Color(0xFF1E1E2C).withValues(alpha: opacity)
        : Colors.white.withValues(alpha: opacity);
  }

  Color _borderColor(bool isDark, Color? tint) {
    if (tint != null) {
      return tint.withValues(alpha: isDark ? 0.25 : 0.35);
    }
    return isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.55);
  }

  Color _specularColor(bool isDark) {
    return isDark ? Colors.white : const Color(0xFFB8C4D0);
  }
}

// ---------------------------------------------------------------------------
// LiquidGlassPanel – glass card (replaces old version, backward-compatible API)
// ---------------------------------------------------------------------------

class LiquidGlassPanel extends ConsumerWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Glass glass;

  const LiquidGlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 28.0,
    this.padding,
    this.margin,
    this.onTap,
    this.glass = Glass.regular,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LiquidGlassEffect(
      glass: glass,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// LiquidGlassPill – small selectable pill with glass effect
// ---------------------------------------------------------------------------

class LiquidGlassPill extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;
  final EdgeInsetsGeometry? padding;
  final Color? selectedColor;

  const LiquidGlassPill({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.padding,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = selectedColor ?? themeState.effectiveAccent;
    final mediaQuery = MediaQuery.of(context);
    final disableGlass = themeState.reduceTransparency ||
        mediaQuery.accessibleNavigation ||
        mediaQuery.highContrast;

    final bgColor = isSelected
        ? accent
        : (isDark ? Colors.white.withValues(alpha: 0.10) : Colors.white.withValues(alpha: 0.55));
    final borderColor = isSelected
        ? accent.withValues(alpha: 0.8)
        : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.50));

    Widget pill = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOutCubic,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: disableGlass ? bgColor : bgColor,
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(color: Colors.transparent, child: child),
    );

    if (!disableGlass && !isSelected) {
      pill = ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: themeState.glassBlurSigma * 0.6,
            sigmaY: themeState.glassBlurSigma * 0.6,
          ),
          child: pill,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: pill,
    );
  }
}

// ---------------------------------------------------------------------------
// LiquidGlassCapsule – floating capsule shape for bottom nav / floating actions
// ---------------------------------------------------------------------------

class LiquidGlassCapsule extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? height;
  final Color? tintColor;

  const LiquidGlassCapsule({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.height,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final disableGlass = themeState.reduceTransparency ||
        mediaQuery.accessibleNavigation ||
        mediaQuery.highContrast;

    final opacity = themeState.glassOpacity;
    final blurSigma = themeState.glassBlurSigma;

    final surfaceColor = tintColor != null
        ? tintColor!.withValues(alpha: isDark ? 0.20 : 0.25)
        : (isDark ? const Color(0xFF1B1B26) : Colors.white).withValues(alpha: opacity);

    final border = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.55);

    Widget capsule = Container(
      height: height,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        color: surfaceColor,
        border: Border.all(color: border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(color: Colors.transparent, child: child),
    );

    if (!disableGlass) {
      capsule = ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: capsule,
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: capsule,
      );
    }
    return capsule;
  }
}

// ---------------------------------------------------------------------------
// GlassButton – primary (accent-filled) / secondary (glass) pill button
// ---------------------------------------------------------------------------

class GlassButton extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool primary;
  final Color? color;
  final double height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.primary = false,
    this.color,
    this.height = 54,
    this.width,
    this.padding,
    this.borderRadius = 27,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = color ?? themeState.effectiveAccent;
    final mediaQuery = MediaQuery.of(context);
    final disableGlass = themeState.reduceTransparency ||
        mediaQuery.accessibleNavigation ||
        mediaQuery.highContrast;
    final enabled = onPressed != null;

    final content = AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: child,
    );

    Widget button;
    if (primary) {
      button = Container(
        height: height,
        width: width,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: accent,
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.22 : 0.45),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isDark ? 0.40 : 0.28),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: content,
      );
    } else {
      final surface = (isDark ? const Color(0xFF1C1C24) : Colors.white)
          .withValues(alpha: themeState.glassOpacity);
      button = Container(
        height: height,
        width: width,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: disableGlass
              ? (isDark ? const Color(0xFF1C1C24) : Colors.white)
              : surface,
          border: Border.all(
            color: disableGlass
                ? (isDark ? Colors.white12 : Colors.black12)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.55)),
            width: 1,
          ),
        ),
        child: content,
      );
      if (!disableGlass) {
        button = ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: themeState.glassBlurSigma * 0.6,
              sigmaY: themeState.glassBlurSigma * 0.6,
            ),
            child: button,
          ),
        );
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onPressed : null,
      child: button,
    );
  }
}

// ---------------------------------------------------------------------------
// GlassIconButton – circular glass icon button
// ---------------------------------------------------------------------------

class GlassIconButton extends ConsumerWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double buttonSize;
  final Color? color;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 18,
    this.buttonSize = 36,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final disableGlass = themeState.reduceTransparency ||
        mediaQuery.accessibleNavigation ||
        mediaQuery.highContrast;

    final iconColor = color ?? (isDark ? Colors.white : const Color(0xFF1C1C1E));
    final surface = (isDark ? const Color(0xFF1C1C24) : Colors.white)
        .withValues(alpha: themeState.glassOpacity);

    Widget button = Container(
      width: buttonSize,
      height: buttonSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: disableGlass
            ? (isDark ? const Color(0xFF1C1C24) : Colors.white)
            : surface,
        border: Border.all(
          color: disableGlass
              ? (isDark ? Colors.white12 : Colors.black12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.55)),
          width: 1,
        ),
      ),
      child: Icon(icon, size: size, color: iconColor),
    );

    if (!disableGlass) {
      button = ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: themeState.glassBlurSigma * 0.5,
            sigmaY: themeState.glassBlurSigma * 0.5,
          ),
          child: button,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: button,
    );
  }
}

// ---------------------------------------------------------------------------
// GlassDialog – liquid glass alert dialog
// ---------------------------------------------------------------------------

class GlassDialog extends ConsumerWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  const GlassDialog({super.key, this.title, this.content, this.actions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: LiquidGlassEffect(
        borderRadius: 28,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
                child: title!,
              ),
              const SizedBox(height: 12),
            ],
            if (content != null) ...[
              DefaultTextStyle.merge(
                style: TextStyle(fontSize: 15, height: 1.4, color: textColor),
                child: content!,
              ),
              const SizedBox(height: 20),
            ],
            if (actions != null && actions!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (var i = 0; i < actions!.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    actions![i],
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

Future<T?> showGlassDialog<T>(
  BuildContext context, {
  Widget? title,
  Widget? content,
  List<Widget>? actions,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    builder: (_) => GlassDialog(
      title: title,
      content: content,
      actions: actions,
    ),
  );
}


