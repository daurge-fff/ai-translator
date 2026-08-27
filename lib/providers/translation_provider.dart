import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../data/local/database.dart';
import '../data/remote/api_client.dart';
import 'admin_provider.dart';
import 'auth_provider.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class TranslationState {
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final String userContext;
  final String regionalVariant;
  final bool isLoading;
  final String? errorMessage;

  TranslationState({
    this.sourceText = '',
    this.translatedText = '',
    this.sourceLang = 'Русский',
    this.targetLang = 'English (US)',
    this.userContext = '',
    this.regionalVariant = '',
    this.isLoading = false,
    this.errorMessage,
  });

  TranslationState copyWith({
    String? sourceText,
    String? translatedText,
    String? sourceLang,
    String? targetLang,
    String? userContext,
    String? regionalVariant,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TranslationState(
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      userContext: userContext ?? this.userContext,
      regionalVariant: regionalVariant ?? this.regionalVariant,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class TranslationNotifier extends StateNotifier<TranslationState> {
  final ApiClient _apiClient;
  final AppDatabase _db;
  Timer? _debounceTimer;

  TranslationNotifier(this._apiClient, this._db) : super(TranslationState());

  void _debouncedTranslate() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      performTranslation();
    });
  }

  void setSourceText(String text) {
    state = state.copyWith(sourceText: text, errorMessage: null);

    if (text.trim().isEmpty) {
      state = state.copyWith(translatedText: '', isLoading: false);
      return;
    }

    _debouncedTranslate();
  }

  void setUserContext(String contextText) {
    state = state.copyWith(userContext: contextText);
    if (state.sourceText.trim().isNotEmpty) {
      _debouncedTranslate();
    }
  }

  void setLanguages(String source, String target) {
    state = state.copyWith(sourceLang: source, targetLang: target);
    if (state.sourceText.trim().isNotEmpty) {
      _debouncedTranslate();
    }
  }

  void swapLanguages() {
    final oldSource = state.sourceLang;
    final oldTarget = state.targetLang;
    final oldSourceText = state.sourceText;
    final oldTranslated = state.translatedText;

    final isSourceAuto = oldSource == 'Автоопределение' || oldSource == 'Auto Detect';
    final isTargetAuto = oldTarget == 'Автоопределение' || oldTarget == 'Auto Detect';

    String newSource;
    String newTarget;

    if (isSourceAuto) {
      // Source was auto-detect → target becomes source, source defaults to English
      newTarget = isTargetAuto ? 'English' : oldTarget;
      newSource = 'English';
    } else if (isTargetAuto) {
      // Target was auto-detect → source becomes target, target defaults to English
      newSource = oldSource;
      newTarget = 'English';
    } else {
      newSource = oldTarget;
      newTarget = oldSource;
    }

    state = state.copyWith(
      sourceLang: newSource,
      targetLang: newTarget,
      sourceText: oldTranslated,
      translatedText: oldSourceText,
    );

    if (state.sourceText.trim().isNotEmpty) {
      _debouncedTranslate();
    }
  }

  Future<void> performTranslation() async {
    final text = state.sourceText.trim();
    if (text.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _apiClient.translate(
        sourceText: text,
        sourceLang: state.sourceLang,
        targetLang: state.targetLang,
        userContext: state.userContext,
        regionalVariant: state.regionalVariant,
      );
      final translated = result['translation'] ?? '';
      state = state.copyWith(translatedText: translated, isLoading: false);

      // Save to SQLite Local Database
      if (translated.isNotEmpty) {
        await _db.insertTranslation(
          TranslationItemsCompanion.insert(
            sourceText: text,
            translatedText: translated,
            sourceLang: state.sourceLang,
            targetLang: state.targetLang,
            userContext: drift.Value(state.userContext),
          ),
        );
      }
    } catch (e) {
      final ban = BanInfo.tryParse(e);
      if (ban != null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _formatBanMessage(ban),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Translation error: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    }
  }

  String _formatBanMessage(BanInfo ban) {
    if (ban.isPermanent) {
      return 'Вы заблокированы навсегда.\n\nПричина: ${ban.reason.isEmpty ? 'нарушение правил' : ban.reason}';
    }
    final expires = ban.expiresAtDate?.toLocal();
    final daysLeft = expires != null ? (expires.difference(DateTime.now()).inDays) : null;
    final when = daysLeft != null && daysLeft > 0
        ? 'через $daysLeft дн.'
        : expires != null
            ? '${expires.day}.${expires.month}.${expires.year} в ${expires.hour}:${expires.minute.toString().padLeft(2, '0')}'
            : 'скоро';
    return 'Вы временно заблокированы.\n\nСрок: до $when\nПричина: ${ban.reason.isEmpty ? 'нарушение правил' : ban.reason}';
  }
}

final translationProvider = StateNotifierProvider<TranslationNotifier, TranslationState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final db = ref.watch(databaseProvider);
  // Sync auth token to API client
  ref.listen(authProvider, (prev, next) {
    apiClient.setIdToken(next.idToken.isNotEmpty ? next.idToken : null);
  }, fireImmediately: true);
  return TranslationNotifier(apiClient, db);
});
