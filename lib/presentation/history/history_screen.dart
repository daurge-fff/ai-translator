import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/constants/languages.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/liquid_glass.dart';
import '../../data/local/database.dart';
import '../../providers/contexts_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/translation_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAllHistory(BuildContext context, AppDatabase db) {
    showGlassDialog<bool>(
      context,
      title: Text(context.l.clearHistoryTitle),
      content: Text(context.l.clearHistoryMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l.cancel),
        ),
        GlassButton(
          primary: true,
          color: AppColors.danger,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            context.l.clear,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ).then((confirmed) async {
      if (confirmed == true) {
        await db.deleteAllTranslations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final themeState = ref.watch(themeProvider);
    final contexts = ref.watch(contextsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = themeState.accentColor.color;

    String contextTitle(String? userContext) {
      if (userContext == null || userContext.isEmpty) return '';
      for (final c in contexts) {
        if (c.contextText == userContext) return c.title;
      }
      return userContext;
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            20, MediaQuery.of(context).padding.top + 4, 20, 0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l.historyTitle,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.08),
                  IconButton(
                    icon: const Icon(CupertinoIcons.trash, color: AppColors.danger),
                    onPressed: () => _clearAllHistory(context, db),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search field
              TextField(
                controller: _searchController,
                onChanged: (v) =>
                    setState(() => _query = v.trim().toLowerCase()),
                style: TextStyle(
                  fontSize: 15,
                  color:
                      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                cursorColor: accent,
                decoration: InputDecoration(
                  hintText: context.l.historySearchHint,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 15,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 14, right: 8),
                    child: Icon(CupertinoIcons.search, size: 18, color: Colors.grey),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixIcon: _query.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            child: const Icon(CupertinoIcons.xmark_circle_fill,
                                size: 18, color: Colors.grey),
                          ),
                        )
                      : null,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // List
              Expanded(
                child: StreamBuilder<List<TranslationItem>>(
                  stream: db.watchAllTranslations(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var items = snapshot.data ?? [];

                    if (_query.isNotEmpty) {
                      items = items.where((item) {
                        return item.sourceText.toLowerCase().contains(_query) ||
                            item.translatedText.toLowerCase().contains(_query) ||
                            (item.userContext?.toLowerCase().contains(_query) ?? false);
                      }).toList();
                    }

                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.clock,
                                size: 48,
                                color: isDark ? Colors.white24 : Colors.black26),
                            const SizedBox(height: 12),
                            Text(
                              _query.isNotEmpty
                                  ? context.l.noResults
                                  : context.l.historyEmpty,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: isDark ? Colors.white38 : Colors.black38),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 120),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];

                        LanguageItem? langItemFor(String langName) {
                          for (final l in WorldLanguages.list) {
                            if (l.name == langName) return l;
                          }
                          return null;
                        }

                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => db.deleteTranslation(item.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Icon(CupertinoIcons.trash, color: AppColors.danger),
                          ),
                          child: LiquidGlassPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (langItemFor(item.sourceLang) != null)
                                      languageFlagWidget(langItemFor(item.sourceLang)!, size: 12),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        item.sourceLang,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: accent,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Text(
                                        '→',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.white38 : Colors.black38,
                                        ),
                                      ),
                                    ),
                                    if (langItemFor(item.targetLang) != null)
                                      languageFlagWidget(langItemFor(item.targetLang)!, size: 12),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        item.targetLang,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: accent,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    if (item.userContext != null &&
                                        item.userContext!.isNotEmpty)
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: accent.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            contextTitle(item.userContext),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 11, color: accent),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.sourceText,
                                  style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.translatedText,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }
}
