import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/constants/languages.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/liquid_glass.dart';
import '../../providers/translation_provider.dart';
import '../../data/remote/api_client.dart';
import '../../providers/contexts_provider.dart';
import '../widgets/language_selector_sheet.dart';

class TranslateScreen extends ConsumerStatefulWidget {
  const TranslateScreen({super.key});

  @override
  ConsumerState<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends ConsumerState<TranslateScreen> {
  late final TextEditingController _sourceController;
  late final TextEditingController _contextController;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isContextExpanded = false;

  @override
  void initState() {
    super.initState();
    _sourceController = TextEditingController();
    _contextController = TextEditingController();

    // Sync sourceController when state changes externally (e.g. swapLanguages)
    ref.listenManual(translationProvider, (prev, next) {
      if (_sourceController.text != next.sourceText) {
        _sourceController.text = next.sourceText;
      }
    });
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _contextController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speakText(String text, String langCode) async {
    if (text.isEmpty) return;
    try {
      final ttsCode = _ttsLocale(langCode);
      await _flutterTts.setLanguage(ttsCode);
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  String _ttsLocale(String code) {
    const ttsMap = {
      'ru': 'ru-RU',
      'en-US': 'en-US',
      'en-UK': 'en-GB',
      'en-AU': 'en-AU',
      'en-CA': 'en-CA',
      'en-IN': 'en-IN',
      'en-PH': 'en-PH',
      'es': 'es-ES',
      'es-MX': 'es-MX',
      'es-AR': 'es-AR',
      'es-PR': 'es-PR',
      'es-CO': 'es-CO',
      'es-CL': 'es-CL',
      'es-CU': 'es-CU',
      'es-DO': 'es-DO',
      'fr': 'fr-FR',
      'fr-CA': 'fr-CA',
      'fr-BE': 'fr-BE',
      'fr-CH': 'fr-CH',
      'de': 'de-DE',
      'de-AT': 'de-AT',
      'de-CH': 'de-CH',
      'it': 'it-IT',
      'pt-PT': 'pt-PT',
      'pt-BR': 'pt-BR',
      'pt-AO': 'pt-AO',
      'zh-CN': 'zh-CN',
      'zh-TW': 'zh-TW',
      'zh-HK': 'zh-HK',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'ar': 'ar-SA',
      'ar-EG': 'ar-EG',
      'ar-AE': 'ar-AE',
      'tr': 'tr-TR',
      'nl': 'nl-NL',
      'pl': 'pl-PL',
      'uk': 'uk-UA',
      'hi': 'hi-IN',
      'hi-Latn': 'hi-IN',
      'he': 'he-IL',
      'sv': 'sv-SE',
      'no': 'no-NO',
      'da': 'da-DK',
      'fi': 'fi-FI',
      'el': 'el-GR',
      'cs': 'cs-CZ',
      'hu': 'hu-HU',
      'ro': 'ro-RO',
      'bg': 'bg-BG',
      'sk': 'sk-SK',
      'hr': 'hr-HR',
      'sr': 'sr-RS',
      'sl': 'sl-SI',
      'ca': 'ca-ES',
      'fa': 'fa-IR',
      'ur': 'ur-PK',
      'bn': 'bn-BD',
      'th': 'th-TH',
      'vi': 'vi-VN',
      'id': 'id-ID',
      'ms': 'ms-MY',
      'sw': 'sw-KE',
      'af': 'af-ZA',
      'et': 'et-EE',
      'lv': 'lv-LV',
      'lt': 'lt-LT',
      'be': 'by-BY',
      'kk': 'kk-KZ',
      'ka': 'ka-GE',
      'hy': 'hy-AM',
      'sq': 'sq-AL',
      'mk': 'mk-MK',
      'bs': 'bs-BA',
      'mt': 'mt-MT',
      'is': 'is-IS',
      'ga': 'ga-IE',
      'cy': 'cy-GB',
    };
    return ttsMap[code] ?? code;
  }

  void _openLanguagePicker(bool isTarget) {
    final trState = ref.read(translationProvider);
    final trNotifier = ref.read(translationProvider.notifier);
    final current = isTarget ? trState.targetLang : trState.sourceLang;

    LanguageSelectorSheet.show(context, current, isTarget, (selectedLang) {
      if (isTarget) {
        trNotifier.setLanguages(trState.sourceLang, selectedLang.name);
      } else {
        trNotifier.setLanguages(selectedLang.name, trState.targetLang);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final trState = ref.watch(translationProvider);
    final trNotifier = ref.read(translationProvider.notifier);
    final templates = ref.watch(contextsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRu = Localizations.localeOf(context).languageCode == 'ru';

    String displayLang(String langName) {
      if (langName == 'Автоопределение' || langName == 'Auto Detect') {
        return isRu ? 'Автоопределение' : 'Auto Detect';
      }
      return langName;
    }

    LanguageItem? langItemByName(String langName) {
      for (final l in WorldLanguages.list) {
        if (l.name == langName || l.displayName(isRu) == langName) return l;
      }
      return null;
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  children: [
                    // Title Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l.translateSectionLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlue,
                                letterSpacing: 1.0,
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.1),
                            Text(
                              context.l.translateTitle,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideX(begin: -0.1),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Language Selector Capsule Bar
                    LiquidGlassPanel(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        borderRadius: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                    // Source Language Button (allows Auto Detect)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openLanguagePicker(false),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (trState.sourceLang != 'Автоопределение' &&
                                trState.sourceLang != 'Auto Detect')
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: langItemByName(trState.sourceLang) != null
                                    ? languageFlagWidget(langItemByName(trState.sourceLang)!, size: 14)
                                    : const SizedBox.shrink(),
                              ),
                            Flexible(
                              child: Text(
                                displayLang(trState.sourceLang),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(CupertinoIcons.chevron_down, size: 11, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    // Swap Languages Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () => trNotifier.swapLanguages(),
                        child: const Icon(CupertinoIcons.arrow_right_arrow_left, size: 14, color: AppColors.primaryBlue),
                      ),
                    ),

                    // Target Language Button (excludes Auto Detect)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openLanguagePicker(true),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: langItemByName(trState.targetLang) != null
                                  ? languageFlagWidget(langItemByName(trState.targetLang)!, size: 14)
                                  : const SizedBox.shrink(),
                            ),
                            Flexible(
                              child: Text(
                                displayLang(trState.targetLang),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(CupertinoIcons.chevron_down, size: 11, color: AppColors.primaryBlue),
                          ],
                        ),
                      ),
                    ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Main Integrated Liquid Glass Canvas
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  LiquidGlassPanel(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Input Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l.sourceText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                letterSpacing: 1.0,
                              ),
                            ),
                            if (_sourceController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _sourceController.clear();
                                  trNotifier.setSourceText('');
                                },
                                child: const Icon(CupertinoIcons.xmark_circle_fill, size: 18, color: Colors.grey),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Source Text Field
                        TextField(
                          controller: _sourceController,
                          maxLines: 4,
                          minLines: 3,
                          onChanged: (text) => trNotifier.setSourceText(text),
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: context.l.translateHint,
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Quick Context Section
                        Text(
                          context.l.contextAndSituation,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: templates.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final t = templates[index];
                              final isSelected = trState.userContext == t.contextText;
                              return LiquidGlassPill(
                                isSelected: isSelected,
                                onTap: () {
                                  if (isSelected) {
                                    trNotifier.setUserContext('');
                                    _contextController.clear();
                                  } else {
                                    trNotifier.setUserContext(t.contextText);
                                    _contextController.text = t.contextText;
                                  }
                                },
                                child: Text(
                                  t.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? Colors.white70 : Colors.black87),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Expandable Custom Context Area
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isContextExpanded = !_isContextExpanded;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.chat_bubble_text,
                                        size: 16,
                                        color: trState.userContext.isNotEmpty
                                            ? AppColors.primaryBlue
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          trState.userContext.isNotEmpty
                                              ? '${context.l.contextActivated.trim()}: ${trState.userContext}'
                                              : context.l.customContext,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: trState.userContext.isNotEmpty
                                                ? AppColors.primaryBlue
                                                : (isDark ? Colors.white60 : Colors.black54),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  _isContextExpanded
                                      ? CupertinoIcons.chevron_up
                                      : CupertinoIcons.chevron_down,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isContextExpanded) ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: _contextController,
                            onChanged: (text) => trNotifier.setUserContext(text),
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: context.l.contextHint,
                              border: InputBorder.none,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Translation Result Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              Text(
                                context.l.resultLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBlue,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            if (trState.isLoading)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (trState.ban != null)
                          _BanMessage(ban: trState.ban!)
                        else if (trState.errorMessage != null)
                          Text(
                            trState.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 15,
                            ),
                          )
                        else if (trState.translatedText.isEmpty)
                          Text(
                            context.l.resultPlaceholder,
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.white30 : Colors.black38,
                            ),
                          )
                        else
                          SelectableText(
                            trState.translatedText,
                            style: TextStyle(
                              fontSize: 19,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),

                        // Bottom Action Buttons
                        if (trState.translatedText.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GlassIconButton(
                                icon: CupertinoIcons.doc_on_doc,
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text: trState.translatedText));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(context.l.copied),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              GlassIconButton(
                                icon: CupertinoIcons.speaker_2,
                                onPressed: () => _speakText(
                                    trState.translatedText, trState.targetLang),
                              ),
                              const SizedBox(width: 8),
                              GlassIconButton(
                                icon: CupertinoIcons.share,
                                onPressed: () async {
                                  try {
                                    await Share.share(trState.translatedText);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(context.l.errorSharing),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ]),
              ),
            ),
          ],
        ),
    );
  }
}

class _BanMessage extends StatelessWidget {
  final BanInfo ban;
  const _BanMessage({required this.ban});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppStrings.of(context);
    final isRu = l.isRu;

    // Date + time formatting with proper locale
    final expires = ban.expiresAtDate?.toLocal();
    final now = DateTime.now();
    final daysLeft = expires?.difference(now).inDays;
    final hoursLeft = expires == null ? null : expires.difference(now).inHours % 24;

    final String whenText;
    if (expires == null) {
      whenText = isRu ? 'скоро' : 'soon';
    } else if (daysLeft! > 0) {
      whenText = isRu
          ? 'через $daysLeft дн. $hoursLeft ч.'
          : 'in $daysLeft d $hoursLeft h';
    } else {
      final date = '${expires.day.toString().padLeft(2, '0')}.${expires.month.toString().padLeft(2, '0')}.${expires.year}';
      final time = '${expires.hour.toString().padLeft(2, '0')}:${expires.minute.toString().padLeft(2, '0')}';
      whenText = isRu ? 'до $date в $time' : 'until $date at $time';
    }

    final reason = ban.reason.isEmpty
        ? (isRu ? 'нарушение правил' : 'rules violation')
        : ban.reason;

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
            const Icon(CupertinoIcons.exclamationmark_shield_fill, color: AppColors.danger, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ban.isPermanent
                    ? (isRu ? 'Вы заблокированы навсегда' : 'You are permanently banned')
                    : (isRu ? 'Вы временно заблокированы' : 'You are temporarily banned'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.danger),
              ),
            ),
          ]),
          if (!ban.isPermanent) ...[
            const SizedBox(height: 8),
            Text(
              '${isRu ? 'Срок' : 'Until'}: $whenText',
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            '${isRu ? 'Причина' : 'Reason'}: $reason',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
          ),
          if (ban.warningMessage.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(ban.warningMessage, style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.black54)),
          ],
        ],
      ),
    );
  }
}
