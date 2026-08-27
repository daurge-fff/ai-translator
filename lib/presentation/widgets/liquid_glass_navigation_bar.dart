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
  double _dragStartX = 0;
  double _dragBaseIndex = 0;
  bool _isDragging = false;

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
    if (oldWidget.currentIndex != widget.currentIndex && !_isDragging) {
      _fromIndex = _currentIndexValue;
      _toIndex = widget.currentIndex.toDouble();
      final simulation = SpringSimulation(_spring, 0.0, 1.0, 0);
      _slideController.animateWith(simulation);
    }
  }

  double get _currentIndexValue =>
      _fromIndex + (_toIndex - _fromIndex) * _slideController.value;

  void _onDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
    _dragBaseIndex = widget.currentIndex.toDouble();
    _isDragging = true;
    _slideController.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final delta = (_dragStartX - details.globalPosition.dx) / 120;
    final newIndex = (_dragBaseIndex + delta)
        .clamp(0.0, (widget.items.length - 1).toDouble());
    _fromIndex = newIndex;
    _toIndex = newIndex;
    _slideController.value = 1.0;
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final current = _fromIndex;
    final target = (current + (velocity > 0 ? 0.5 : -0.5)).round()
        .clamp(0, widget.items.length - 1);
    if (target != widget.currentIndex) {
      widget.onIndexChanged(target);
    } else {
      _fromIndex = widget.currentIndex.toDouble();
      _toIndex = widget.currentIndex.toDouble();
      final simulation = SpringSimulation(_spring, 0.0, 1.0, 0);
      _slideController.animateWith(simulation);
    }
  }

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
    final accent = themeState.effectiveAccent;
    final metrics = _NavMetrics.of(context);

    final reduceGlass = themeState.reduceTransparency ||
        mediaQuery.accessibleNavigation ||
        mediaQuery.highContrast;

    final blurSigma = themeState.glassBlurSigma;

    // ── iOS System Tab Bar surface ──────────────────────────────────
    // No border, no specular highlight, no shadow.
    // Just a clean translucent fill + subtle separator line on top.
    final surfaceColor = isDark
        ? const Color(0xFF1C1C1C).withValues(alpha: reduceGlass ? 1.0 : 0.92)
        : const Color(0xFFF9F9F9).withValues(alpha: reduceGlass ? 1.0 : 0.94);
    final separatorColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.09);

    final content = GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: _itemsLayer(metrics, accent, isDark),
    );

    final decorated = Container(
      decoration: BoxDecoration(color: surfaceColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thin separator line (like iOS system tab bar)
          Container(
            height: 0.5,
            color: separatorColor,
          ),
          Expanded(child: content),
        ],
      ),
    );

    final frosted = reduceGlass
        ? decorated
        : ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: decorated,
            ),
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
            height: metrics.height,
            child: RepaintBoundary(
              child: AnimatedScale(
                scale: widget.dimmed ? 0.96 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: widget.dimmed ? 0.82 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(metrics.radius),
                    child: frosted,
                  ),
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
            metrics.height - metrics.indicatorVerticalInset * 2 - 0.5; // account for separator

        return Stack(
          clipBehavior: Clip.none,
          children: [
            ExcludeSemantics(
              child: AnimatedBuilder(
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
                      radius: indicatorHeight / 2,
                      isDark: isDark,
                    ),
                  );
                },
              ),
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
    final height = 56.0;
    final horizontalMargin = isApple
        ? (width * 0.08).clamp(20.0, 32.0).toDouble()
        : (width * 0.06).clamp(16.0, 28.0).toDouble();
    final bottomInset = mediaQuery.padding.bottom;
    final bottomGap = isApple ? 8.0 : 4.0;
    final radius = height * 0.5;

    return _NavMetrics(
      height: height,
      radius: radius,
      horizontalMargin: horizontalMargin,
      bottomInset: bottomInset,
      bottomGap: bottomGap,
      indicatorVerticalInset: 4.0,
      indicatorHorizontalInset: 4.0,
    );
  }
}

class _SelectedIndicator extends StatelessWidget {
  final double radius;
  final bool isDark;

  const _SelectedIndicator({
    required this.radius,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // iOS-style: subtle translucent fill, no border
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: 0.06),
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
    // iOS system: inactive = grey (0.6 opacity), active = accent/blue
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.60)
        : const Color(0xFF8E8E93);
    final iconColor = selected ? accent : inactiveColor;
    final labelColor = selected ? accent : inactiveColor;

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
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: iconColor),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              builder: (context, color, child) => Icon(
                selected ? item.activeIcon : item.icon,
                size: 22,
                color: color ?? iconColor,
              ),
            ),
            const SizedBox(height: 2),
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: labelColor),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              builder: (context, color, child) => Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: color ?? labelColor,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
