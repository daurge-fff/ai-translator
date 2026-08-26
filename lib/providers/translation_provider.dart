import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../data/local/database.dart';
import '../data/remote/api_client.dart';

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
    this.targetLang = 'English',
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

  void setSourceText(String text) {
    state = state.copyWith(sourceText: text, errorMessage: null);

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (text.trim().isEmpty) {
      state = state.copyWith(translatedText: '', isLoading: false);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 700), () {
      performTranslation();
    });
  }

  void setUserContext(String contextText) {
    state = state.copyWith(userContext: contextText);
    if (state.sourceText.trim().isNotEmpty) {
      performTranslation();
    }
  }

  void setLanguages(String source, String target) {
    state = state.copyWith(sourceLang: source, targetLang: target);
    if (state.sourceText.trim().isNotEmpty) {
      performTranslation();
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
      performTranslation();
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
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка перевода: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }
}

final translationProvider = StateNotifierProvider<TranslationNotifier, TranslationState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final db = ref.watch(databaseProvider);
  return TranslationNotifier(apiClient, db);
});
