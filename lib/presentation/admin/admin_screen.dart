import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/liquid_glass.dart';
import '../../providers/admin_provider.dart';
import '../../providers/theme_provider.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    Future.microtask(() => ref.read(adminProvider.notifier).fetchIncidents());
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showIncidentDetail(BuildContext context, SecurityIncident inc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(36)),
                color: isDark
                    ? const Color(0xFF161622).withValues(alpha: 0.90)
                    : Colors.white.withValues(alpha: 0.90),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.60),
                  width: 1.2,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white30 : Colors.black26,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.exclamationmark_shield_fill,
                            color: AppColors.danger, size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Инцидент',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _detail(context.l.userField, inc.user, isDark),
                    _detail(context.l.ipField, inc.ip, isDark),
                    _detail(context.l.deviceField, inc.deviceId, isDark),
                    _detail(context.l.patternField, inc.pattern, isDark),
                    _detail(context.l.timeField, inc.timestamp, isDark),
                    _detail(context.l.levelField, inc.severity.toUpperCase(), isDark),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text('"${inc.snippet}"',
                          style: const TextStyle(
                              fontSize: 13, fontStyle: FontStyle.italic)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  void _showBanDialog(BuildContext context, {SecurityIncident? fromIncident}) {
    String banType = 'user';
    final reasonController = TextEditingController();
    final banValueController = TextEditingController(text: fromIncident?.user ?? '');
    String banValue = fromIncident?.user ?? '';
    final suggestions = {
      ...ref.read(adminProvider).incidents.map((i) => i.user),
      ...ref.read(adminProvider).bans.map((b) => b.value),
    }.where((e) => e.isNotEmpty).toList();

    final presets = [
      context.l.banPresetPrompt,
      context.l.banPresetInjections,
      context.l.banPresetAbuse,
      context.l.banPresetScraping,
    ];

    showGlassDialog<void>(
      context,
      title: Row(children: [
        const Icon(CupertinoIcons.hand_raised_fill, color: AppColors.danger, size: 20),
        const SizedBox(width: 8),
        Flexible(child: Text(context.l.banDialogTitle)),
      ]),
      content: StatefulBuilder(
        builder: (context, setInner) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _banTypeChip('user', 'User', CupertinoIcons.person,
                        banType, setInner, (v) {
                      banType = v;
                      if (fromIncident != null) banValue = fromIncident.user;
                    }),
                    const SizedBox(width: 8),
                    _banTypeChip('device', 'Device',
                        CupertinoIcons.device_phone_portrait, banType, setInner,
                        (v) {
                      banType = v;
                      if (fromIncident != null) {
                        banValue = fromIncident.deviceId;
                      }
                    }),
                    const SizedBox(width: 8),
                    _banTypeChip('ip', 'IP', CupertinoIcons.wifi, banType,
                        setInner, (v) {
                      banType = v;
                      if (fromIncident != null) banValue = fromIncident.ip;
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                Autocomplete<String>(
                  initialValue: TextEditingValue(text: banValue),
                  optionsBuilder: (textEditingValue) {
                    if (banType != 'user') {
                      return const Iterable<String>.empty();
                    }
                    if (textEditingValue.text.isEmpty) {
                      return suggestions;
                    }
                    final q = textEditingValue.text.toLowerCase();
                    return suggestions.where(
                        (u) => u.toLowerCase().contains(q));
                  },
                  onSelected: (selection) {
                    setInner(() {
                      banValue = selection;
                      banValueController.text = selection;
                    });
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: (v) => banValue = v,
                      decoration: InputDecoration(
                        labelText: banType == 'user'
                            ? context.l.emailLabel
                            : banType == 'device'
                                ? context.l.deviceIdLabel
                                : context.l.ipField,
                        prefixIcon: banType == 'user'
                            ? const Icon(CupertinoIcons.person_crop_circle,
                                size: 18)
                            : null,
                        suffixIcon: controller.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  controller.clear();
                                  setInner(() => banValue = '');
                                },
                                child: const Icon(
                                    CupertinoIcons.xmark_circle_fill,
                                    size: 18,
                                    color: Colors.grey),
                              )
                            : null,
                      ),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return _SuggestionList(
                      options: options.toList(),
                      onSelect: (v) => onSelected(v),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(context.l.reasonLabel,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: presets.map((p) {
                    final sel = reasonController.text == p;
                    return GestureDetector(
                      onTap: () => setInner(() => reasonController.text = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.danger.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: sel
                                  ? AppColors.danger
                                  : AppColors.separator(
                                      Theme.of(context).brightness ==
                                          Brightness.dark)),
                        ),
                        child: Text(p,
                            style: TextStyle(
                                fontSize: 12,
                                color: sel
                                    ? AppColors.danger
                                    : AppColors.lightTextSecondary)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  maxLines: 2,
                  decoration: InputDecoration(hintText: context.l.customReasonHint),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l.cancel),
        ),
        GlassButton(
          primary: true,
          color: AppColors.danger,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          onPressed: () {
            if (banValue.isNotEmpty && reasonController.text.isNotEmpty) {
              ref
                  .read(adminProvider.notifier)
                  .addBan(banValue, banType, reasonController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${context.l.blocked}$banValue'),
                  backgroundColor: AppColors.danger,
                ),
              );
            }
          },
          child: Text(
            context.l.block,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _banTypeChip(String value, String label, IconData icon, String current,
      StateSetter setInner, ValueChanged<String> onSelected) {
    final sel = current == value;
    return GestureDetector(
      onTap: () => setInner(() => onSelected(value)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: sel
              ? AppColors.primaryBlue.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: sel ? AppColors.primaryBlue : AppColors.lightSystemGray4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14, color: sel ? AppColors.primaryBlue : Colors.grey),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    color: sel ? AppColors.primaryBlue : Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = themeState.accentColor.color;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, isDark, accent),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: LiquidGlassPill(
                    isSelected: _tabController.index == 0,
                    onTap: () => _tabController.animateTo(0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        '${context.l.alerts} (${adminState.incidents.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _tabController.index == 0
                              ? Colors.white
                              : (isDark ? Colors.white54 : Colors.black45),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LiquidGlassPill(
                    isSelected: _tabController.index == 1,
                    onTap: () => _tabController.animateTo(1),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        '${context.l.bans} (${adminState.bans.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _tabController.index == 1
                              ? Colors.white
                              : (isDark ? Colors.white54 : Colors.black45),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIncidents(adminState, isDark, accent),
                _buildBans(adminState, isDark, accent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color accent) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GlassIconButton(
              icon: CupertinoIcons.back,
              buttonSize: 40,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l.adminBadge,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                        letterSpacing: 0.8,
                        height: 1.2),
                  ),
                  Text(
                    context.l.security,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
                  ),
                ],
              ),
            ),
            GlassIconButton(
              icon: CupertinoIcons.hand_raised,
              buttonSize: 40,
              color: AppColors.danger,
              onPressed: () => _showBanDialog(context),
            ),
            const SizedBox(width: 6),
            GlassIconButton(
              icon: CupertinoIcons.refresh,
              buttonSize: 40,
              color: accent,
              onPressed: () => ref.read(adminProvider.notifier).fetchIncidents(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidents(AdminState s, bool isDark, Color accent) {
    if (s.isLoading) return const Center(child: CircularProgressIndicator());

    if (s.incidents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.checkmark_shield_fill,
                color: AppColors.success, size: 44),
            const SizedBox(height: 12),
            Text(context.l.noIncidents,
                style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      itemCount: s.incidents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final inc = s.incidents[i];
        final sevColor = inc.severity == 'high'
            ? AppColors.danger
            : inc.severity == 'medium'
                ? AppColors.warning
                : Colors.grey;

        return GestureDetector(
          onTap: () => _showIncidentDetail(context, inc),
          child: LiquidGlassPanel(
            padding: const EdgeInsets.all(14),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.exclamationmark_triangle_fill,
                              color: sevColor, size: 14),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(inc.user,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: sevColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(inc.severity.toUpperCase(),
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: sevColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('"${inc.snippet}"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: Text('${inc.pattern} · ${inc.ip}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white38 : Colors.black38)),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showBanDialog(context, fromIncident: inc),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(context.l.ban,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.danger)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBans(AdminState s, bool isDark, Color accent) {
    if (s.bans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.person_badge_minus,
                color: isDark ? Colors.white30 : Colors.black26, size: 44),
            const SizedBox(height: 12),
            Text(context.l.empty,
                style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 16)),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(CupertinoIcons.hand_raised_fill, size: 16),
              label: Text(context.l.add),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              onPressed: () => _showBanDialog(context),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      itemCount: s.bans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final ban = s.bans[i];
        final icon = ban.type == 'user'
            ? CupertinoIcons.person_fill
            : ban.type == 'device'
                ? CupertinoIcons.device_phone_portrait
                : CupertinoIcons.wifi;

        return LiquidGlassPanel(
          padding: const EdgeInsets.all(14),
          borderRadius: 20,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.danger, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ban.value,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(ban.reason,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.xmark_circle_fill,
                    color: Colors.grey, size: 20),
                onPressed: () =>
                    ref.read(adminProvider.notifier).removeBan(ban.value),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SuggestionList extends StatelessWidget {
  final List<String> options;
  final ValueChanged<String> onSelect;

  const _SuggestionList({required this.options, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.only(top: 4),
          constraints: const BoxConstraints(maxHeight: 180, maxWidth: 360),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: isDark
                ? const Color(0xFF1A1A24).withValues(alpha: 0.96)
                : Colors.white.withValues(alpha: 0.96),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.55),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemCount: options.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 14,
              endIndent: 14,
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
            ),
            itemBuilder: (context, index) {
              final option = options[index];
              return InkWell(
                onTap: () => onSelect(option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        option.contains('@')
                            ? CupertinoIcons.person_crop_circle
                            : CupertinoIcons.antenna_radiowaves_left_right,
                        size: 16,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          option,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                      const Icon(CupertinoIcons.arrow_left,
                          size: 14, color: AppColors.primaryBlue),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
