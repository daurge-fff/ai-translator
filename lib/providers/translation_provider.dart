import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../data/local/database.dart';
import '../data/remote/api_client.dart';
import 'api_client_provider.dart';
import 'auth_provider.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

class TranslationState {
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final String userContext;
  final String regionalVariant;
  final bool isLoading;
  final String? errorMessage;
  final BanInfo? ban;

  TranslationState({
    this.sourceText = '',
    this.translatedText = '',
    this.sourceLang = 'Русский',
    this.targetLang = 'English (US)',
    this.userContext = '',
    this.regionalVariant = '',
    this.isLoading = false,
    this.errorMessage,
    this.ban,
  });

  static const Object _unset = Object();

  TranslationState copyWith({
    String? sourceText,
    String? translatedText,
    String? sourceLang,
    String? targetLang,
    String? userContext,
    String? regionalVariant,
    bool? isLoading,
    String? errorMessage,
    Object? ban = _unset,
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
      ban: identical(ban, _unset) ? this.ban : ban as BanInfo?,
    );
  }
}

class TranslationNotifier extends StateNotifier<TranslationState> {
  final ApiClient _apiClient;
  final AppDatabase _db;
  final ValueChanged<BanInfo?> _onBan;
  Timer? _debounceTimer;

  TranslationNotifier(this._apiClient, this._db, this._onBan) : super(TranslationState());

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
      state = state.copyWith(translatedText: translated, isLoading: false, ban: null);
      _onBan(null);

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
        _onBan(ban);
        state = state.copyWith(
          isLoading: false,
          ban: ban,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Translation error: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    }
  }
}

final translationProvider = StateNotifierProvider<TranslationNotifier, TranslationState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final db = ref.watch(databaseProvider);
  final auth = ref.watch(authProvider.notifier);
  return TranslationNotifier(apiClient, db, (ban) => auth.setBan(ban));
});
