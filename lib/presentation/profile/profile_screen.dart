import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Widget _avatarLetter(UserProfile user, Color accent) {
    return Container(
      color: accent.withValues(alpha: 0.2),
      alignment: Alignment.center,
      child: Text(
        user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: accent),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = themeState.effectiveAccent;

    Widget panel({required Widget child, EdgeInsetsGeometry? padding, double borderRadius = 28}) {
      return Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: isDark
              ? const Color(0xFF1E1E2C).withValues(alpha: themeState.glassOpacity)
              : Colors.white.withValues(alpha: themeState.glassOpacity),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.55),
            width: 1,
          ),
        ),
        child: child,
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 4, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.l.profileTitle, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary))
                    .animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.08),
                GestureDetector(
                  onTap: () => ref.read(authProvider.notifier).signOut(),
                  child: Text(context.l.signOut, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User Info Card
            panel(
              borderRadius: 24,
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: isDark ? 0.30 : 0.18), border: Border.all(color: accent.withValues(alpha: 0.4), width: 2)),
                    child: ClipOval(
                      child: user.avatarUrl.isNotEmpty
                          ? Image.network(
                              user.avatarUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return Center(child: CircularProgressIndicator(strokeWidth: 2, color: accent));
                              },
                              errorBuilder: (_, __, ___) => _avatarLetter(user, accent),
                            )
                          : _avatarLetter(user, accent),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Flexible(child: Text(user.displayName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
                        const SizedBox(width: 8),
                        if (user.isAdmin) Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                          child: const Text('ADMIN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.6, color: AppColors.danger)),
                        ),
                      ]),
                      const SizedBox(height: 3),
                      Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Language
            Text(context.l.language, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, letterSpacing: 1.0)),
            const SizedBox(height: 10),
            panel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                _LangFlagButton(flag: const Text('🇺🇸', style: TextStyle(fontSize: 20)), label: 'EN', isSelected: Localizations.localeOf(context).languageCode == 'en', accent: accent, isDark: isDark, onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en'))),
                const SizedBox(width: 10),
                _LangFlagButton(flag: _RuFlag(), label: 'RU', isSelected: Localizations.localeOf(context).languageCode == 'ru', accent: accent, isDark: isDark, onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('ru'))),
              ]),
            ),
            const SizedBox(height: 20),

            // Reduce transparency
            Text(context.l.accessibilitySection, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, letterSpacing: 1.0)),
            const SizedBox(height: 10),
            panel(
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: themeState.reduceTransparency ? accent.withValues(alpha: isDark ? 0.20 : 0.14) : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05))),
                  child: Icon(CupertinoIcons.eye_slash, size: 16, color: themeState.reduceTransparency ? accent : (isDark ? Colors.white54 : Colors.black45)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(context.l.reduceTransparency, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(context.l.reduceTransparencyDesc, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                ])),
                CupertinoSwitch(value: themeState.reduceTransparency, activeTrackColor: accent, onChanged: (_) => ref.read(themeProvider.notifier).toggleReduceTransparency()),
              ]),
            ),
            const SizedBox(height: 20),

            // Accent color
            Text(context.l.accentColor.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, letterSpacing: 1.0)),
            const SizedBox(height: 10),
            panel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: BrandAccentColor.values.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final selected = themeState.useDeviceTheme;
                      return GestureDetector(
                        onTap: () => ref.read(themeProvider.notifier).setUseDeviceTheme(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [Color(0xFF007AFF), Color(0xFF34C759), Color(0xFFFF9500)]),
                            border: Border.all(color: selected ? (isDark ? Colors.white : Colors.black) : Colors.transparent, width: 2),
                          ),
                          child: selected ? const Icon(Icons.check, size: 18, color: Colors.white) : const Icon(Icons.phone_android, size: 16, color: Colors.white),
                        ),
                      );
                    }
                    final col = BrandAccentColor.values[index - 1];
                    final selected = !themeState.useDeviceTheme && themeState.accentColor == col;
                    return GestureDetector(
                      onTap: () => ref.read(themeProvider.notifier).setAccentColor(col),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36, height: 36,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: col.color, border: Border.all(color: selected ? (isDark ? Colors.white : Colors.black) : Colors.transparent, width: 2)),
                        child: selected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Theme settings
            Text(context.l.themeSection, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, letterSpacing: 1.0)),
            const SizedBox(height: 10),
            panel(
              child: Row(children: [
                _ThemeChip(mode: ThemeMode.light, current: themeState.themeMode, accent: accent, isDark: isDark, label: context.l.light, icon: CupertinoIcons.sun_max_fill, onTap: () => ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light)),
                const SizedBox(width: 10),
                _ThemeChip(mode: ThemeMode.dark, current: themeState.themeMode, accent: accent, isDark: isDark, label: context.l.dark, icon: CupertinoIcons.moon_fill, onTap: () => ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark)),
                const SizedBox(width: 10),
                _ThemeChip(mode: ThemeMode.system, current: themeState.themeMode, accent: accent, isDark: isDark, label: context.l.system, icon: CupertinoIcons.circle_lefthalf_fill, onTap: () => ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system)),
              ]),
            ),
            const SizedBox(height: 20),

            if (user.isAdmin) ...[
              Text(context.l.adminSection, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.danger, letterSpacing: 1.0)),
              const SizedBox(height: 10),
              GlassButton(
                width: double.infinity, height: 54,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen())),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(CupertinoIcons.shield_fill, color: AppColors.danger, size: 18),
                  const SizedBox(width: 10),
                  Text(context.l.adminPanel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.danger)),
                  const SizedBox(width: 6),
                  Icon(CupertinoIcons.chevron_right, size: 16, color: isDark ? Colors.white38 : Colors.black38),
                ]),
              ),
              const SizedBox(height: 20),
            ],

            // Privacy
            Text(context.l.privacySection, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, letterSpacing: 1.0)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final confirmed = await showGlassDialog<bool>(context,
                  title: Text(context.l.deleteDataTitle),
                  content: Text(context.l.deleteDataMessage),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l.cancel)),
                    GlassButton(primary: true, color: AppColors.danger, height: 44, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), onPressed: () => Navigator.pop(context, true), child: Text(context.l.delete, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white))),
                  ],
                );
                if (confirmed == true && context.mounted) {
                  final db = ref.read(databaseProvider);
                  await db.deleteAllTranslations();
                  ref.read(contextsProvider.notifier).clearAll();
                  ref.read(authProvider.notifier).signOut();
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l.dataDeleted)));
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06), width: 1)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(CupertinoIcons.trash, size: 15, color: isDark ? Colors.white38 : Colors.black38),
                  const SizedBox(width: 8),
                  Text(context.l.deleteAccount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white54 : Colors.black45)),
                ]),
              ),
            ),
            const SizedBox(height: 20),

            // About
            Text(context.l.aboutSection.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, letterSpacing: 1.0)),
            const SizedBox(height: 10),
            panel(
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final info = snapshot.data;
                  final version = info != null ? '${info.version} (${info.buildNumber})' : '...';
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _AboutRow(label: context.l.version, value: version, isDark: isDark),
                    const SizedBox(height: 12),
                    _AboutRow(label: context.l.license, value: 'MIT', isDark: isDark),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse('https://github.com/daurge-fff/ai-translator');
                        if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      child: Row(children: [
                        Icon(CupertinoIcons.link, size: 14, color: accent),
                        const SizedBox(width: 6),
                        Expanded(child: Text('github.com/daurge-fff/ai-translator', style: TextStyle(fontSize: 13, color: accent, decoration: TextDecoration.underline))),
                        Icon(CupertinoIcons.arrow_up_right, size: 12, color: accent),
                      ]),
                    ),
                  ]);
                },
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _RuFlag extends StatelessWidget {
  const _RuFlag();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/flag_ru.png',
      width: 36, height: 26,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Text('🇷🇺', style: TextStyle(fontSize: 20)),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final ThemeMode mode;
  final ThemeMode current;
  final Color accent;
  final bool isDark;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ThemeChip({required this.mode, required this.current, required this.accent, required this.isDark, required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = mode == current;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected ? accent.withValues(alpha: isDark ? 0.20 : 0.14) : Colors.transparent,
            border: Border.all(color: selected ? accent.withValues(alpha: 0.7) : AppColors.separator(isDark), width: selected ? 2 : 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(children: [
            Icon(icon, size: 20, color: selected ? accent : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? accent : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary))),
          ]),
        ),
      ),
    );
  }
}

class _LangFlagButton extends StatelessWidget {
  final Widget flag;
  final String label;
  final bool isSelected;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  const _LangFlagButton({required this.flag, required this.label, required this.isSelected, required this.accent, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected ? accent.withValues(alpha: isDark ? 0.20 : 0.12) : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
            border: Border.all(color: isSelected ? accent.withValues(alpha: 0.6) : AppColors.separator(isDark), width: isSelected ? 1.5 : 1),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            flag,
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? accent : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary))),
          ]),
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _AboutRow({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
      ],
    );
  }
}
