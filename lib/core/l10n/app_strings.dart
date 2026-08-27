import 'package:flutter/material.dart';

class AppStrings {
  final bool isRu;
  const AppStrings(this.isRu);

  static AppStrings of(BuildContext context) =>
      AppStrings(Localizations.localeOf(context).languageCode == 'ru');

  String t(String en, String ru) => isRu ? ru : en;

  // Navigation
  String get navTranslate => t('Translate', 'Перевод');
  String get navContexts => t('Contexts', 'Контексты');
  String get navHistory => t('History', 'История');
  String get navProfile => t('Profile', 'Профиль');

  // Auth
  String get appTagline => t('Translator that understands context', 'Переводчик, который понимает контекст');
  String get featureContextTitle => t('Contextual translation', 'Контекстный перевод');
  String get featureContextDesc => t('Describe the situation — who you write to and why. The word "football" becomes "soccer" for an American.', 'Укажите ситуацию — кому пишете и зачем. Слово "футбол" для американца станет soccer.');
  String get featureSecurityTitle => t('Security', 'Безопасность');
  String get featureSecurityDesc => t('The app translates, it does not chat. Attempts to use it as a chatbot are blocked.', 'Приложение переводит, а не отвечает. Попытки использовать как чат-бот блокируются.');
  String get featureLanguagesTitle => t('100+ languages', '100+ языков');
  String get featureLanguagesDesc => t('Dialects: US, UK, AU, CA. Pick the exact variant for a perfect translation.', 'Диалекты: US, UK, AU, CA. Выбирайте точный вариант для идеального перевода.');
  String get signInWithGoogle => t('Sign in with Google', 'Войти через Google');
  String get signInFailed => t('Could not sign in. Please try again.', 'Не удалось войти. Попробуйте ещё раз.');

  // Translate
  String get translateTitle => t('Translator', 'Переводчик');
  String get translateSectionLabel => t('CONTEXTUAL AI', 'КОНТЕКСТНЫЙ ИИ');
  String get sourceText => t('SOURCE TEXT', 'ИСХОДНЫЙ ТЕКСТ');
  String get translateHint => t('Enter text to translate...', 'Введите текст для перевода...');
  String get contextAndSituation => t('CONTEXT AND SITUATION', 'КОНТЕКСТ И СИТУАЦИЯ');
  String get customContext => t('Custom context (in your own words)...', 'Свой контекст (своими словами)...');
  String get contextHint => t('e.g. "writing to my colleague on Slack, polite business tone"...', 'Например: "пишу коллеге в Slack, вежливый деловой тон"...');
  String get resultLabel => t('TRANSLATION RESULT', 'РЕЗУЛЬТАТ ПЕРЕВОДА');
  String get resultPlaceholder => t('The contextual translation will appear here...', 'Здесь появится смысловой перевод, адаптированный под выбранную ситуацию...');
  String get copied => t('Copied to clipboard', 'Скопировано в буфер обмена');
  String get errorSharing => t('Could not share', 'Не удалось поделиться');
  String get translationError => t('Translation error: ', 'Ошибка перевода: ');

  // Language selector
  String get sourceLanguageTitle => t('Source language (From)', 'Исходный язык (Откуда)');
  String get targetLanguageTitle => t('Target language (To)', 'Язык перевода (Куда)');
  String get searchLanguagesHint => t('Search 100+ languages...', 'Поиск из 100+ языков мира...');

  // Contexts
  String get contextsTitle => t('Context templates', 'Шаблоны контекста');
  String get contextsSubtitle => t('Double-tap a card to edit', 'Двойной клик на карточку для изменения');
  String get contextActivated => t('Context activated: ', 'Активирован контекст: ');
  String get newContextTemplate => t('New context template', 'Новый шаблон контекста');
  String get editContextTemplate => t('Edit template', 'Редактировать шаблон');
  String get templateNameLabel => t('TEMPLATE NAME', 'НАЗВАНИЕ ШАБЛОНА');
  String get templateNameHint => t('e.g. Writing to an American colleague', 'Например: Пишу американскому коллеге');
  String get templateDescLabel => t('SITUATION / INSTRUCTIONS FOR AI', 'ОПИСАНИЕ СИТУАЦИИ / ИНСТРУКЦИИ ДЛЯ ИИ');
  String get templateDescHint => t('Describe the situation in your own words:\n- Who you write to (boss, friend, English speaker)\n- The tone (polite, playful, dry)\n- Which terms to use', 'Напишите своими словами, в чем заключается ситуация:\n- Кому вы пишете (боссу, другу, англичанину)\n- В каком тоне (вежливый, шутливый, сухой)\n- Какие термины использовать');
  String get saveTemplate => t('Save template', 'Сохранить шаблон');

  // History
  String get historyTitle => t('Translation history', 'История переводов');
  String get historySearchHint => t('Search history...', 'Поиск по истории...');
  String get noResults => t('Nothing found', 'Ничего не найдено');
  String get historyEmpty => t('History is empty.\nTranslated texts will appear here.', 'История пуста.\nПереведённые тексты появятся здесь.');
  String get clearHistoryTitle => t('Clear history?', 'Очистить историю?');
  String get clearHistoryMessage => t('All saved translations will be permanently deleted from this device.', 'Все сохраненные переводы будут безвозвратно удалены с этого устройства.');
  String get clear => t('Clear', 'Удалить всё');
  String get cancel => t('Cancel', 'Отмена');

  // Profile
  String get profileTitle => t('Profile', 'Профиль');
  String get googleAccount => t('Google Account', 'Аккаунт Google');
  String get signedInGoogle => t('Signed in via Google OAuth', 'Авторизован через Google OAuth');
  String get signOut => t('Sign out', 'Выйти из аккаунта');
  String get themeSection => t('APPEARANCE THEME', 'ТЕМА ОФОРМЛЕНИЯ');
  String get light => t('Light', 'Светлая');
  String get dark => t('Dark', 'Тёмная');
  String get system => t('System', 'Системная');
  String get accentColor => t('Accent color', 'Цвет акцента');
  String get accessibilitySection => t('ACCESSIBILITY', 'ДОСТУПНОСТЬ');
  String get reduceTransparency => t('Reduce transparency', 'Уменьшить прозрачность');
  String get reduceTransparencyDesc => t('Disables blur to save battery and improve accessibility', 'Выключает блёр для экономии батареи и повышения доступности');
  String get adminSection => t('ADMINISTRATION', 'АДМИНИСТРИРОВАНИЕ');
  String get adminPanel => t('Admin panel', 'Панель администратора');
  String get adminPanelDesc => t('Security incidents and ban list', 'Инциденты безопасности и бан-лист');
  String get privacySection => t('PRIVACY', 'ПРИВАТНОСТЬ');
  String get deleteAccount => t('Delete account and all data', 'Удалить аккаунт и все данные');
  String get deleteDataTitle => t('Delete all data?', 'Удалить все данные?');
  String get deleteDataMessage => t('All translation history and context templates will be permanently deleted. This action cannot be undone.', 'Вся история переводов и шаблоны контекстов будут безвозвратно удалены. Это действие нельзя отменить.');
  String get delete => t('Delete', 'Удалить');
  String get dataDeleted => t('All data deleted', 'Все данные удалены');
  String get aboutSection => t('ABOUT', 'О ПРИЛОЖЕНИИ');
  String get version => t('Version', 'Версия');
  String get license => t('License', 'Лицензия');
  String get language => t('Language', 'Язык');

  // Admin
  String get adminBadge => t('ADMIN', 'АДМИН');
  String get security => t('Security', 'Безопасность');
  String get alerts => t('Alerts', 'Алерты');
  String get bans => t('Bans', 'Баны');
  String get incident => t('Incident', 'Инцидент');
  String get userField => t('User', 'Пользователь');
  String get deviceField => t('Device', 'Устройство');
  String get ipField => t('IP', 'IP');
  String get patternField => t('Pattern', 'Паттерн');
  String get timeField => t('Time', 'Время');
  String get levelField => t('Level', 'Уровень');
  String get ban => t('Ban', 'Бан');
  String get banDialogTitle => t('Block user', 'Блокировка');
  String get emailLabel => t('Email', 'Email');
  String get deviceIdLabel => t('Device ID', 'Device ID');
  String get reasonLabel => t('Reason:', 'Причина:');
  String get customReasonHint => t('Custom reason...', 'Своя причина...');
  String get blocked => t('Blocked: ', 'Заблокировано: ');
  String get noIncidents => t('All clear', 'Чисто');
  String get empty => t('Empty', 'Пусто');
  String get add => t('Add', 'Добавить');
  String get block => t('Block', 'Заблокировать');
  String get banPresetPrompt => t('Prompt bypass', 'Обход промпта');
  String get banPresetInjections => t('Command injections', 'Инъекции команд');
  String get banPresetAbuse => t('API abuse', 'Злоупотребление API');
  String get banPresetScraping => t('Data collection', 'Сбор данных');
}

extension AppStringsContext on BuildContext {
  AppStrings get l => AppStrings.of(this);
}
