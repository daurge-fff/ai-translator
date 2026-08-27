import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/liquid_glass.dart';
import '../../core/widgets/google_logo.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  bool _isSigningIn = false;
  late final PageController _pageController;
  int _currentPage = 0;

  // Animations
  late final AnimationController _blobController;
  late final AnimationController _fadeController;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.86, initialPage: 500);
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _blobController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = themeState.effectiveAccent;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background with floating blobs
          Positioned.fill(
            child: _AnimatedBackground(
              blobController: _blobController,
              isDark: isDark,
              accent: accent,
            ),
          ),

          // Main content
          FadeTransition(
            opacity: _fadeIn,
            child: Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 10),
                    // Header block (hero + title + tagline)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _HeroIcon(
                            accent: accent,
                            isDark: isDark,
                            pulse: _pulseController,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Contextual\nTranslator',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -0.5,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l.appTagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Feature cards carousel — full-bleed to the screen edges
                    _FeatureCarousel(
                      pageController: _pageController,
                      currentPage: _currentPage,
                      onPageChanged: (i) =>
                          setState(() => _currentPage = i),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 4),

                    // Swipe hint
                    Text(
                      context.l.swipeHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Page indicators
                    _PageIndicators(
                      count: 3,
                      currentPage: _currentPage % 3,
                      accent: accent,
                    ),
                    const SizedBox(height: 20),

                    // Mini feature stats
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: _StatsRow(isDark: isDark, accent: accent),
                    ),
                    const SizedBox(height: 26),

                    // Footer block (button + terms)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _GoogleSignInButton(
                            isSigningIn: _isSigningIn,
                            onPressed: () async {
                              setState(() => _isSigningIn = true);
                              final error = await ref
                                  .read(authProvider.notifier)
                                  .signInWithGoogle();
                              if (!context.mounted) return;
                              setState(() => _isSigningIn = false);
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${context.l.signInFailed}\n$error',
                                    ),
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                          Text(
                            context.l.authFooter,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: isDark
                                  ? Colors.white24
                                  : Colors.black26,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated gradient background with floating glass blobs
// ---------------------------------------------------------------------------

class _AnimatedBackground extends StatelessWidget {
  final AnimationController blobController;
  final bool isDark;
  final Color accent;

  const _AnimatedBackground({
    required this.blobController,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: blobController,
      builder: (context, _) {
        final t = blobController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0D0D14),
                      const Color(0xFF111122),
                      Color.lerp(const Color(0xFF0D0D14), accent, 0.06)!,
                    ]
                  : [
                      const Color(0xFFF0F2F5),
                      const Color(0xFFE8ECF0),
                      Color.lerp(Colors.white, accent, 0.04)!,
                    ],
            ),
          ),
          child: Stack(
            children: [
              // Blob 1 – top right
              Positioned(
                top: -80 + math.sin(t * math.pi * 2) * 30,
                right: -60 + math.cos(t * math.pi * 1.5) * 20,
                child: _GlassBlob(
                  size: 220,
                  color: accent.withValues(alpha: isDark ? 0.12 : 0.10),
                ),
              ),
              // Blob 2 – bottom left
              Positioned(
                bottom: -100 + math.cos(t * math.pi * 1.8) * 25,
                left: -80 + math.sin(t * math.pi * 1.3) * 15,
                child: _GlassBlob(
                  size: 280,
                  color: (isDark ? AppColors.primaryIndigo : AppColors.accentCyan)
                      .withValues(alpha: isDark ? 0.10 : 0.08),
                ),
              ),
              // Blob 3 – center (subtle)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.35,
                left: MediaQuery.of(context).size.width * 0.2,
                child: _GlassBlob(
                  size: 160,
                  color: accent.withValues(alpha: isDark ? 0.06 : 0.05),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlassBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _GlassBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero icon with glass glow
// ---------------------------------------------------------------------------

class _HeroIcon extends StatelessWidget {
  final Color accent;
  final bool isDark;
  final Animation<double> pulse;

  const _HeroIcon({
    required this.accent,
    required this.isDark,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final glassCircle = Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: isDark ? 0.28 : 0.22),
            accent.withValues(alpha: isDark ? 0.10 : 0.08),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.35),
          width: 1.2,
        ),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.18),
            ),
            child: Icon(
              CupertinoIcons.captions_bubble_fill,
              size: 38,
              color: accent,
            ),
          ),
        ),
      ),
    );

    // Gentle floating motion (no glow).
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -4 * (0.5 + 0.5 * pulse.value)),
        child: child,
      ),
      child: glassCircle,
    );
  }
}

// ---------------------------------------------------------------------------
// Feature cards carousel with glass panels
// ---------------------------------------------------------------------------

class _FeatureCarousel extends StatelessWidget {
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final bool isDark;

  const _FeatureCarousel({
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final features = _buildFeatures(context.l);
    final featureCount = features.length;

    return SizedBox(
      height: 252,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: onPageChanged,
        itemCount: null,
        itemBuilder: (context, index) {
          final feature = features[index % featureCount];
          final isActive = (index % featureCount) ==
              (currentPage % featureCount);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: AnimatedBuilder(
              animation: pageController,
              builder: (context, child) {
                final double page =
                    pageController.hasClients ? (pageController.page ?? 0) : 0;
                final diff = (index - page).abs();
                final scale = 1.0 - 0.07 * diff.clamp(0.0, 1.0);
                final opacity = 1.0 - 0.5 * diff.clamp(0.0, 1.2);
                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: _FeatureCard(
                feature: feature,
                isActive: isActive,
                isDark: isDark,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData feature;
  final bool isActive;
  final bool isDark;

  const _FeatureCard({
    required this.feature,
    required this.isActive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = feature.color;
    return LiquidGlassPanel(
      borderRadius: 26,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon tile with soft gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: (isDark ? 0.22 : 0.16)),
                  color.withValues(alpha: (isDark ? 0.06 : 0.04)),
                ],
              ),
              border: Border.all(
                color: color.withValues(alpha: isActive ? 0.40 : 0.18),
                width: 1.1,
              ),
            ),
            child: Icon(feature.icon, size: 28, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            feature.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              height: 1.2,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 10),
          // Fixed-height description area → all cards have identical height
          SizedBox(
            height: 54,
            child: Text(
              feature.description,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.38,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

List<_FeatureData> _buildFeatures(AppStrings l) => [
      _FeatureData(
        icon: CupertinoIcons.bubble_left_bubble_right_fill,
        title: l.featureContextTitle,
        description: l.featureContextDesc,
        color: AppColors.primaryBlue,
      ),
      _FeatureData(
        icon: CupertinoIcons.lock_shield_fill,
        title: l.featureSecurityTitle,
        description: l.featureSecurityDesc,
        color: AppColors.success,
      ),
      _FeatureData(
        icon: CupertinoIcons.globe,
        title: l.featureLanguagesTitle,
        description: l.featureLanguagesDesc,
        color: AppColors.primaryIndigo,
      ),
    ];

// ---------------------------------------------------------------------------
// Page indicators
// ---------------------------------------------------------------------------

class _PageIndicators extends StatelessWidget {
  final int count;
  final int currentPage;
  final Color accent;

  const _PageIndicators({
    required this.count,
    required this.currentPage,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? accent
                : (isDark ? Colors.white24 : Colors.black12),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Mini feature stats (row of pills)
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  final bool isDark;
  final Color accent;

  const _StatsRow({required this.isDark, required this.accent});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final entries = [
      (icon: CupertinoIcons.sparkles, label: l.statAi),
      (icon: CupertinoIcons.globe, label: l.statLanguages),
      (icon: CupertinoIcons.text_bubble, label: l.statContext),
    ];
    return Row(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          Expanded(
            child: _StatChip(
              icon: entries[i].icon,
              label: entries[i].label,
              isDark: isDark,
              accent: accent,
            ),
          ),
          if (i != entries.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color accent;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.55),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.60),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Google Sign-In button with real Google colors
// ---------------------------------------------------------------------------

class _GoogleSignInButton extends StatelessWidget {
  final bool isSigningIn;
  final VoidCallback onPressed;

  const _GoogleSignInButton({
    required this.isSigningIn,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF3C4043),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: Color(0xFFDADCE0), width: 1.0),
          ),
          shadowColor: Colors.black.withValues(alpha: 0.08),
        ),
        onPressed: isSigningIn ? null : onPressed,
        child: isSigningIn
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: AppColors.primaryBlue,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GoogleLogo(size: 22),
                  const SizedBox(width: 12),
                  Text(
                    context.l.signInWithGoogle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3C4043),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Google "G" logo painter
// ---------------------------------------------------------------------------

