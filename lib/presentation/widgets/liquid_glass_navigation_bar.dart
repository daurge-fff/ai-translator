import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.label,
    IconData? activeIcon,
  }) : activeIcon = activeIcon ?? icon;
}

class LiquidGlassNavigationBar extends ConsumerStatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<NavigationItem> items;
  final bool dimmed;

  const LiquidGlassNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.items,
    this.dimmed = false,
  });

  @override
  ConsumerState<LiquidGlassNavigationBar> createState() =>
      _LiquidGlassNavigationBarState();
}

class _LiquidGlassNavigationBarState
    extends ConsumerState<LiquidGlassNavigationBar>
    with SingleTickerProviderStateMixin {
  static const SpringDescription _spring = SpringDescription(
    mass: 1.0,
    stiffness: 400,
    damping: 38,
  );

  late final AnimationController _slideController;
  double _fromIndex = 0;
  double _toIndex = 0;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.currentIndex.toDouble();
    _toIndex = widget.currentIndex.toDouble();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 640),
    );
  }

  @override
  void didUpdateWidget(covariant LiquidGlassNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _fromIndex = _currentIndexValue;
      _toIndex = widget.currentIndex.toDouble();
      final simulation = SpringSimulation(_spring, 0.0, 1.0, 0);
      _slideController.animateWith(simulation);
    }
  }

  double get _currentIndexValue =>
      _fromIndex + (_toIndex - _fromIndex) * _slideController.value;

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final accent = themeState.accentColor.color;
    final metrics = _NavMetrics.of(context);

    final reduceGlass = themeState.reduceTransparency ||
        mediaQuery.accessibleNavigation ||
        mediaQuery.highContrast;

    final blurSigma = themeState.glassBlurSigma;
    final surfaceColor = isDark
        ? const Color(0xFF1C1C24).withValues(alpha: themeState.glassOpacity)
        : Colors.white.withValues(alpha: themeState.glassOpacity);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.55);
    final specularTop = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.white.withValues(alpha: 0.18);

    final content = Stack(
      children: [
        Positioned.fill(
          child: _SpecularHighlight(radius: metrics.radius, topColor: specularTop),
        ),
        _itemsLayer(metrics, accent, isDark),
      ],
    );

    final decorated = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(metrics.radius),
        color: reduceGlass
            ? (isDark ? const Color(0xFF1C1C24) : Colors.white)
            : surfaceColor,
        border: Border.all(
          color: reduceGlass
              ? (isDark ? Colors.white12 : Colors.black12)
              : borderColor,
          width: 1,
        ),
      ),
      child: content,
    );

    final frosted = reduceGlass
        ? decorated
        : ClipRRect(
            borderRadius: BorderRadius.circular(metrics.radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: decorated,
            ),
          );

    final pill = Container(
      height: metrics.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(metrics.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: reduceGlass ? 0.10 : (isDark ? 0.28 : 0.07),
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: frosted,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        metrics.horizontalMargin,
        0,
        metrics.horizontalMargin,
        metrics.bottomInset + metrics.bottomGap,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SizedBox(
            width: double.infinity,
            child: RepaintBoundary(
              child: AnimatedScale(
                scale: widget.dimmed ? 0.96 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: widget.dimmed ? 0.82 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: pill,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemsLayer(_NavMetrics metrics, Color accent, bool isDark) {
    final count = widget.items.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / count;
        final indicatorWidth =
            itemWidth - metrics.indicatorHorizontalInset * 2;
        final indicatorHeight =
            metrics.height - metrics.indicatorVerticalInset * 2;

        return Stack(
          children: [
            AnimatedBuilder(
              animation: _slideController,
              builder: (context, _) {
                final index = _currentIndexValue
                    .clamp(0.0, (count - 1).toDouble());
                final maxLeft = constraints.maxWidth -
                    indicatorWidth -
                    metrics.indicatorHorizontalInset;
                final rawLeft =
                    index * itemWidth + metrics.indicatorHorizontalInset;
                final left = rawLeft
                    .clamp(metrics.indicatorHorizontalInset, maxLeft)
                    .toDouble();
                return Positioned(
                  left: left,
                  top: metrics.indicatorVerticalInset,
                  width: indicatorWidth,
                  height: indicatorHeight,
                  child: _SelectedIndicator(
                    radius: metrics.radius,
                    accent: accent,
                    isDark: isDark,
                  ),
                );
              },
            ),
            Row(
              children: List.generate(count, (index) {
                final item = widget.items[index];
                return Expanded(
                  child: _NavItemButton(
                    item: item,
                    selected: index == widget.currentIndex,
                    accent: accent,
                    isDark: isDark,
                    onTap: () => widget.onIndexChanged(index),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _NavMetrics {
  final double height;
  final double radius;
  final double horizontalMargin;
  final double bottomInset;
  final double bottomGap;
  final double indicatorVerticalInset;
  final double indicatorHorizontalInset;

  const _NavMetrics({
    required this.height,
    required this.radius,
    required this.horizontalMargin,
    required this.bottomInset,
    required this.bottomGap,
    required this.indicatorVerticalInset,
    required this.indicatorHorizontalInset,
  });

  factory _NavMetrics.of(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final platform = Theme.of(context).platform;
    final isApple = platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS;

    final width = mediaQuery.size.width;
    final height = 62.0;
    final horizontalMargin = (width * 0.05).clamp(16.0, 24.0).toDouble();
    final bottomInset = mediaQuery.padding.bottom;
    final bottomGap = isApple ? 12.0 : 8.0;
    final radius = isApple ? height * 0.5 : 28.0;

    return _NavMetrics(
      height: height,
      radius: radius,
      horizontalMargin: horizontalMargin,
      bottomInset: bottomInset,
      bottomGap: bottomGap,
      indicatorVerticalInset: 6.0,
      indicatorHorizontalInset: 6.0,
    );
  }
}

class _SpecularHighlight extends StatelessWidget {
  final double radius;
  final Color topColor;

  const _SpecularHighlight({required this.radius, required this.topColor});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.12, 0.6, 1.0],
            colors: [
              topColor,
              topColor.withValues(alpha: 0.0),
              Colors.transparent,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedIndicator extends StatelessWidget {
  final double radius;
  final Color accent;
  final bool isDark;

  const _SelectedIndicator({
    required this.radius,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final innerRadius = math.max(radius - 6, 20.0);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(innerRadius),
        color: accent.withValues(alpha: isDark ? 0.22 : 0.16),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.28 : 0.18),
          width: 0.8,
        ),
      ),
    );
  }
}

class _NavItemButton extends StatelessWidget {
  final NavigationItem item;
  final bool selected;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItemButton({
    required this.item,
    required this.selected,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0xFF8E8E93);
    final iconColor = selected ? accent : mutedColor;
    final labelColor = selected ? accent : mutedColor;

    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: iconColor),
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                builder: (context, color, child) => Icon(
                  selected ? item.activeIcon : item.icon,
                  size: 23,
                  color: color ?? iconColor,
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: labelColor,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
