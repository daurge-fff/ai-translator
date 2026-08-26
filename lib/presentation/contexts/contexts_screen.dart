import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/liquid_glass.dart';
import '../../providers/contexts_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/translation_provider.dart';
import 'context_editor_sheet.dart';

class ContextsScreen extends ConsumerWidget {
  const ContextsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(contextsProvider);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l.contextsTitle,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.08),
                      Text(
                        context.l.contextsSubtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons.add_circled_solid, color: accent, size: 28),
                    onPressed: () => ContextEditorSheet.show(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: templates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = templates[index];
                    return GestureDetector(
                      onDoubleTap: () => ContextEditorSheet.show(context, existingItem: item),
                      child: LiquidGlassPanel(
                        onTap: () {
                          ref.read(translationProvider.notifier).setUserContext(item.contextText);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${context.l.contextActivated}${item.title}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                CupertinoIcons.bookmark_fill,
                                color: accent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.contextText,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(CupertinoIcons.pencil, size: 18, color: accent),
                              onPressed: () {
                                ContextEditorSheet.show(context, existingItem: item);
                              },
                            ),
                            if (item.id != null)
                              IconButton(
                                icon: const Icon(CupertinoIcons.trash, size: 18, color: Colors.grey),
                                onPressed: () {
                                  ref.read(contextsProvider.notifier).deleteTemplate(item.id!);
                                },
                              ),
                          ],
                        ),
                      ),
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
