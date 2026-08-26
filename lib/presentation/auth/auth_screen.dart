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
    _pageController = PageController(viewportFraction: 0.9, initialPage: 500);
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
    final accent = themeState.accentColor.color;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background with floating blobs
          _AnimatedBackground(
            blobController: _blobController,
            isDark: isDark,
            accent: accent,
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header block (hero + title) — padded
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        accent: accent,
                        isDark: isDark,
                        pulse: _pulseController,
                      ),
                      const SizedBox(height: 14),

                      // Footer block (indicators + button) — padded
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PageIndicators(
                              count: 3,
                              currentPage: _currentPage % 3,
                              accent: accent,
                            ),
                            const SizedBox(height: 32),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
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
            accent.withValues(alpha: isDark ? 0.25 : 0.20),
            accent.withValues(alpha: isDark ? 0.10 : 0.08),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.30),
          width: 1.2,
        ),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.20),
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

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing aura rings
          ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.22).animate(pulse),
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, child) {
                final a = 0.05 + 0.05 * pulse.value;
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: a),
                        accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Glow shadow
          AnimatedBuilder(
            animation: pulse,
            builder: (context, child) => Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(
                        alpha: 0.18 + 0.14 * pulse.value),
                    blurRadius: 26 + 16 * pulse.value,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: child,
            ),
            child: Transform.scale(
              scale: 0.96 + 0.04 * pulse.value,
              child: glassCircle,
            ),
          ),
        ],
      ),
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
  final Color accent;
  final bool isDark;
  final Animation<double> pulse;

  const _FeatureCarousel({
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.accent,
    required this.isDark,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final features = _buildFeatures(context.l);
    final featureCount = features.length;
    return SizedBox(
      height: 216,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: onPageChanged,
        itemCount: null,
        itemBuilder: (context, index) {
          final f = features[index % featureCount];
          final isActive = (index % featureCount) ==
              (currentPage % featureCount);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, child) => Transform.scale(
                scale: isActive ? 1.0 + 0.02 + 0.015 * pulse.value : 0.99,
                child: child,
              ),
              child: LiquidGlassPanel(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glass icon container
                    AnimatedBuilder(
                      animation: pulse,
                      builder: (context, child) => Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: f.color
                              .withValues(alpha: (isDark ? 0.15 : 0.12) +
                                  0.05 * pulse.value),
                          boxShadow: [
                            BoxShadow(
                              color: f.color
                                  .withValues(alpha: 0.12 + 0.12 * pulse.value),
                              blurRadius: 14 + 10 * pulse.value,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(f.icon, size: 28, color: f.color),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      f.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      f.description,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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

