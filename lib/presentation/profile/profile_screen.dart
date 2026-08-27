import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/liquid_glass.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/translation_provider.dart';
import '../../providers/contexts_provider.dart';
import '../../data/remote/github_service.dart';
import '../admin/admin_screen.dart';
import 'changelog_screen.dart';

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

            // About — App Info Card
            Text(context.l.aboutSection.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, letterSpacing: 1.0)),
            const SizedBox(height: 10),
            _AppInfoCard(accent: accent, isDark: isDark),
            const SizedBox(height: 20),

            // Ban banner (if banned)
            if (user.isBanned) ...[
              _BanBanner(ban: user.ban!, isDark: isDark),
              const SizedBox(height: 20),
            ],

            // Delete account — moved to very bottom
            GestureDetector(
              onTap: user.isBanned
                  ? null
                  : () async {
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
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: user.isBanned ? AppColors.danger.withValues(alpha: 0.3) : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)), width: 1)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(CupertinoIcons.trash, size: 15, color: user.isBanned ? AppColors.danger : (isDark ? Colors.white38 : Colors.black38)),
                  const SizedBox(width: 8),
                  Text(user.isBanned ? context.l.deleteBlocked : context.l.deleteAccount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: user.isBanned ? AppColors.danger : (isDark ? Colors.white54 : Colors.black45))),
                ]),
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _BanBanner extends StatelessWidget {
  final BanInfo ban;
  final bool isDark;

  const _BanBanner({required this.ban, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l = AppStrings.of(context);
    final expires = ban.expiresAtDate?.toLocal();
    final String dateText;
    if (expires != null) {
      dateText = '${expires.day.toString().padLeft(2, '0')}.${expires.month.toString().padLeft(2, '0')}.${expires.year}';
    } else {
      dateText = '';
    }

    final banText = ban.isPermanent
        ? l.banPermanentText
        : dateText.isNotEmpty
            ? '${l.banUntilText} $dateText'
            : l.banTemporaryText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.danger.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(CupertinoIcons.exclamationmark_shield_fill, color: AppColors.danger, size: 18),
            const SizedBox(width: 8),
            Text(banText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.danger)),
          ]),
          if (ban.reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('${l.banReasonText} ${ban.reason}', style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87)),
          ],
          if (ban.warningMessage.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(ban.warningMessage, style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.black54)),
          ],
        ],
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

class _AppInfoCard extends StatefulWidget {
  final Color accent;
  final bool isDark;

  const _AppInfoCard({required this.accent, required this.isDark});

  @override
  State<_AppInfoCard> createState() => _AppInfoCardState();
}

class _AppInfoCardState extends State<_AppInfoCard> {
  String? _githubLatest;
  String _localVersion = '...';
  bool _isUpdate = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final info = await PackageInfo.fromPlatform();
    final local = info.version;
    final latest = await GitHubService().getLatestVersion();

    // The installed version is remembered on first run. If GitHub has
    // more commits than at install time → an update is available.
    final installed = prefs.getString('installed_version');
    if (installed == null && latest != null) {
      await prefs.setString('installed_version', latest);
    }

    if (!mounted) return;
    setState(() {
      _localVersion = local;
      _githubLatest = latest;
      final reference = installed ?? latest ?? local;
      _isUpdate = latest != null && _isNewer(latest, reference);
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final isDark = widget.isDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? const Color(0xFF1E1E2C).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          // App icon
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent, accent.withValues(alpha: 0.7)],
              ),
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: const Icon(CupertinoIcons.globe, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Text(context.l.appInfoTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 4),
          Text(context.l.appInfoSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.black45)),
          const SizedBox(height: 16),

          // Version badge + update check
          if (!_loaded)
            const SizedBox(height: 10, width: 10, child: CircularProgressIndicator(strokeWidth: 2))
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _isUpdate ? AppColors.success.withValues(alpha: 0.12) : accent.withValues(alpha: 0.12),
              ),
              child: Text('${context.l.appInfoVersion} $_localVersion',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _isUpdate ? AppColors.success : accent)),
            ),
            if (_githubLatest != null) ...[
              const SizedBox(height: 6),
              Text('${context.l.appInfoLatest}: $_githubLatest',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
            ],
            if (_isUpdate) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.success.withValues(alpha: 0.15),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(CupertinoIcons.arrow_down_circle_fill, size: 13, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(context.l.appInfoUpdateAvailable,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
                ]),
              ),
            ],
          ],
          const SizedBox(height: 18),

          // Action rows
          _infoAction(
            context,
            icon: CupertinoIcons.doc_text,
            label: context.l.appInfoChangelog,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangelogScreen())),
            isDark: isDark,
          ),
          const SizedBox(height: 2),
          _infoAction(
            context,
            icon: CupertinoIcons.link,
            label: context.l.appInfoGitHub,
            onTap: () async {
              final uri = Uri.parse('https://github.com/daurge-fff/ai-translator');
              if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            isDark: isDark,
          ),
          const SizedBox(height: 2),
          _infoAction(
            context,
            icon: CupertinoIcons.doc_checkmark,
            label: context.l.appInfoLicense,
            onTap: () async {
              final uri = Uri.parse('https://opensource.org/licenses/MIT');
              if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _infoAction(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap, required bool isDark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isDark ? Colors.white54 : Colors.black45),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87))),
            Icon(CupertinoIcons.chevron_right, size: 14, color: isDark ? Colors.white24 : Colors.black26),
          ],
        ),
      ),
    );
  }

  /// Compare two version strings "x.y.z". Returns true if a is newer than b.
  bool _isNewer(String a, String b) {
    int parse(String v) {
      final match = RegExp(r'(\d+)\.(\d+)\.(\d+)').firstMatch(v);
      if (match == null) return 0;
      return (int.parse(match.group(1)!) * 100000) +
          (int.parse(match.group(2)!) * 1000) +
          int.parse(match.group(3)!);
    }

    return parse(a) > parse(b);
  }
}
