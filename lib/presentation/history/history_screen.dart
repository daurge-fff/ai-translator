import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/liquid_glass.dart';
import '../../data/local/database.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = themeState.accentColor.color;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            20, MediaQuery.of(context).padding.top + 8, 20, 0),
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
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      setState(() => _query = v.trim().toLowerCase()),
                  style: TextStyle(
                    fontSize: 15,
                    color:
                        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: context.l.historySearchHint,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      size: 18,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            child: const Icon(CupertinoIcons.xmark_circle_fill,
                                size: 18, color: Colors.grey),
                          )
                        : null,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: InputBorder.none,
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
                                    Text(
                                      '${item.sourceLang} → ${item.targetLang}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: accent,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
                                            item.userContext!,
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
