import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/liquid_glass.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/translation_provider.dart';
import '../../providers/contexts_provider.dart';
import '../admin/admin_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = themeState.accentColor.color;

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            20, MediaQuery.of(context).padding.top + 8, 20, 0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + sign-out
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l.profileTitle,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.08),
                  GestureDetector(
                    onTap: () {
                      ref.read(authProvider.notifier).signOut();
                    },
                    child: Text(
                      context.l.signOut,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // User Info Card
              LiquidGlassPanel(
                borderRadius: 24,
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: isDark ? 0.30 : 0.18),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: user.avatarUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(user.avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _avatarLetter(user, accent)),
                            )
                          : _avatarLetter(user, accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.displayName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (user.isAdmin)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withValues(
                                        alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'ADMIN',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.6,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Theme settings
              Text(
                context.l.themeSection,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              LiquidGlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _ThemeCard(
                          mode: ThemeMode.light,
                          current: themeState.themeMode,
                          accent: accent,
                          isDark: isDark,
                          onTap: () => ref
                              .read(themeProvider.notifier)
                              .setThemeMode(ThemeMode.light),
                        ),
                        const SizedBox(width: 10),
                        _ThemeCard(
                          mode: ThemeMode.dark,
                          current: themeState.themeMode,
                          accent: accent,
                          isDark: isDark,
                          onTap: () => ref
                              .read(themeProvider.notifier)
                              .setThemeMode(ThemeMode.dark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _ThemeCard(
                      mode: ThemeMode.system,
                      current: themeState.themeMode,
                      accent: accent,
                      isDark: isDark,
                      onTap: () => ref
                          .read(themeProvider.notifier)
                          .setThemeMode(ThemeMode.system),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Accent color
              Text(
                context.l.accentColor.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              LiquidGlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: BrandAccentColor.values.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final col = BrandAccentColor.values[index];
                      final selected = themeState.accentColor == col;
                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(themeProvider.notifier)
                              .setAccentColor(col);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: col.color,
                            border: Border.all(
                              color: selected
                                  ? (isDark
                                      ? Colors.white
                                      : Colors.black)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? const Icon(Icons.check,
                                  size: 18, color: Colors.white)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Accessibility
              Text(
                context.l.accessibilitySection,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              LiquidGlassPanel(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(context.l.reduceTransparency),
                      subtitle: Text(context.l.reduceTransparencyDesc,
                          style: const TextStyle(fontSize: 13)),
                      secondary:
                          const Icon(CupertinoIcons.eye_slash, size: 20),
                      value: themeState.reduceTransparency,
                      onChanged: (_) {
                        ref
                            .read(themeProvider.notifier)
                            .toggleReduceTransparency();
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(CupertinoIcons.globe, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(context.l.language,
                                style: const TextStyle(fontSize: 15)),
                          ),
                          CupertinoSlidingSegmentedControl<String>(
                            groupValue:
                                Localizations.localeOf(context).languageCode,
                            onValueChanged: (code) {
                              if (code == null) return;
                              if (code == 'ru' || code == 'en') {
                                ref
                                    .read(localeProvider.notifier)
                                    .setLocale(Locale(code));
                              }
                            },
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.07)
                                : Colors.black.withValues(alpha: 0.05),
                            thumbColor: accent,
                            children: const {
                              'en': Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: Text('EN'),
                              ),
                              'ru': Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: Text('RU'),
                              ),
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Admin section
              if (user.isAdmin) ...[
                Text(
                  context.l.adminSection,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                GlassButton(
                  width: double.infinity,
                  height: 54,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminScreen()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.shield_fill,
                          color: AppColors.danger, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        context.l.adminPanel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: isDark
                            ? Colors.white38
                            : Colors.black38,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Data removal
              Text(
                context.l.privacySection,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              LiquidGlassPanel(
                child: ListTile(
                  leading:
                      const Icon(CupertinoIcons.trash, color: AppColors.danger),
                  title: Text(
                    context.l.deleteAccount,
                    style: const TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w500,
                        fontSize: 15),
                  ),
                  onTap: () async {
                    final confirmed = await showGlassDialog<bool>(
                      context,
                      title: Text(context.l.deleteDataTitle),
                      content: Text(context.l.deleteDataMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(context.l.cancel),
                        ),
                        GlassButton(
                          primary: true,
                          color: AppColors.danger,
                          height: 44,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            context.l.delete,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                    if (confirmed == true && context.mounted) {
                      final db = ref.read(databaseProvider);
                      await db.deleteAllTranslations();
                      ref.read(contextsProvider.notifier).clearAll();
                      ref.read(authProvider.notifier).signOut();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.l.dataDeleted)),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Sign out button
              Center(
                child: GestureDetector(
                  onTap: () {
                    ref.read(authProvider.notifier).signOut();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      context.l.signOut,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
    );
  }

  Widget _avatarLetter(UserProfile user, Color accent) {
    return Container(
      color: accent,
      alignment: Alignment.center,
      child: Text(
        user.displayName.isNotEmpty
            ? user.displayName[0].toUpperCase()
            : '?',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final ThemeMode mode;
  final ThemeMode current;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.mode,
    required this.current,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = mode == current;
    final label = mode == ThemeMode.light
        ? context.l.light
        : mode == ThemeMode.dark
            ? context.l.dark
            : context.l.system;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected
                ? accent.withValues(alpha: isDark ? 0.20 : 0.14)
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.7)
                  : AppColors.separator(isDark),
              width: selected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              _MiniPreview(mode: mode, accent: accent),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? accent
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPreview extends StatelessWidget {
  final ThemeMode mode;
  final Color accent;

  const _MiniPreview({required this.mode, required this.accent});

  @override
  Widget build(BuildContext context) {
    final lightBg = const Color(0xFFF2F2F7);
    final darkBg = const Color(0xFF0D0D12);

    Widget preview(Color bg, Color card) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: bg,
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                width: 26,
                height: 10,
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      );
    }

    switch (mode) {
      case ThemeMode.light:
        return preview(lightBg, Colors.white);
      case ThemeMode.dark:
        return preview(darkBg, const Color(0xFF1C1C1E));
      case ThemeMode.system:
        return Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.06),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(color: lightBg),
                ),
                Expanded(
                  child: Container(color: darkBg),
                ),
              ],
            ),
          ),
        );
    }
  }
}
