import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/languages.dart';
import '../../core/l10n/app_strings.dart';
import '../../providers/theme_provider.dart';

class LanguageSelectorSheet extends ConsumerStatefulWidget {
  final String currentLanguage;
  final bool isTarget;
  final ValueChanged<LanguageItem> onSelected;

  const LanguageSelectorSheet({
    super.key,
    required this.currentLanguage,
    this.isTarget = false,
    required this.onSelected,
  });

  static void show(
    BuildContext context,
    String currentLanguage,
    bool isTarget,
    ValueChanged<LanguageItem> onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSelectorSheet(
        currentLanguage: currentLanguage,
        isTarget: isTarget,
        onSelected: onSelected,
      ),
    );
  }

  @override
  ConsumerState<LanguageSelectorSheet> createState() =>
      _LanguageSelectorSheetState();
}

class _LanguageSelectorSheetState extends ConsumerState<LanguageSelectorSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = ref.watch(themeProvider).accentColor.color;
    final isRu = Localizations.localeOf(context).languageCode == 'ru';

    final availableLanguages = widget.isTarget
        ? WorldLanguages.list.where((lang) => lang.code != 'Auto').toList()
        : WorldLanguages.list;

    final filteredLanguages = availableLanguages.where((lang) {
      final q = _searchQuery.toLowerCase();
      return lang.name.toLowerCase().contains(q) ||
          lang.nativeName.toLowerCase().contains(q) ||
          lang.code.toLowerCase().contains(q);
    }).toList();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.80,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            color: isDark
                ? const Color(0xFF161622).withValues(alpha: 0.90)
                : Colors.white.withValues(alpha: 0.90),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 38,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white30 : Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.isTarget
                    ? context.l.targetLanguageTitle
                    : context.l.sourceLanguageTitle,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              // Search Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.search, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: context.l.searchLanguagesHint,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Languages List
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: filteredLanguages.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 44),
                  itemBuilder: (context, index) {
                    final item = filteredLanguages[index];
                    final isSelected = widget.currentLanguage == item.name ||
                        widget.currentLanguage == item.displayName(isRu);

                    return ListTile(
                      leading: Text(item.flag, style: const TextStyle(fontSize: 24)),
                      title: Text(
                        item.displayName(isRu),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? accent : null,
                        ),
                      ),
                      subtitle: Text(
                        item.nativeName,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(CupertinoIcons.checkmark_alt, color: accent)
                          : null,
                      onTap: () {
                        widget.onSelected(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
