import 'package:flutter/material.dart';

class LanguageItem {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final String? regionalVariant;
  final String? nameEn;
  final bool isCustomFlag;

  const LanguageItem({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    this.regionalVariant,
    this.nameEn,
    this.isCustomFlag = false,
  });

  String displayName(bool isRu) => isRu ? name : (nameEn ?? name);
}

/// Returns the flag widget for a language item.
/// For Russian, returns a custom "РУ" waving flag.
/// For others, returns the emoji flag as text.
Widget languageFlagWidget(LanguageItem item, {double size = 20}) {
  if (item.code == 'ru') {
    return _RuFlagSmall(size: size);
  }
  return Text(item.flag, style: TextStyle(fontSize: size));
}

class _RuFlagSmall extends StatelessWidget {
  final double size;
  const _RuFlagSmall({required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/flag_ru.png',
      width: size * 1.6,
      height: size * 1.1,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Text(
        'РУ',
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF2D2D2D),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class WorldLanguages {
  static const LanguageItem autoDetect = LanguageItem(
    code: 'Auto',
    name: 'Автоопределение',
    nativeName: 'Auto Detect',
    flag: '✨',
    nameEn: 'Auto Detect',
  );

  static const List<LanguageItem> list = [
    autoDetect,
    LanguageItem(code: 'ru', name: 'Русский', nativeName: 'Русский', flag: '🇷🇺', isCustomFlag: true),
    LanguageItem(code: 'en-US', name: 'English (US)', nativeName: 'American English', flag: '🇺🇸', regionalVariant: 'US'),
    LanguageItem(code: 'en-UK', name: 'English (UK)', nativeName: 'British English', flag: '🇬🇧', regionalVariant: 'UK'),
    LanguageItem(code: 'en-AU', name: 'English (Australia)', nativeName: 'Australian English', flag: '🇦🇺', regionalVariant: 'AU'),
    LanguageItem(code: 'en-CA', name: 'English (Canada)', nativeName: 'Canadian English', flag: '🇨🇦', regionalVariant: 'CA'),
    LanguageItem(code: 'en-IN', name: 'English (India)', nativeName: 'Indian English', flag: '🇮🇳', regionalVariant: 'IN'),
    LanguageItem(code: 'en-PH', name: 'English (Philippines)', nativeName: 'Philippine English', flag: '🇵🇭', regionalVariant: 'PH'),
    LanguageItem(code: 'es', name: 'Испанский', nativeName: 'Español', flag: '🇪🇸'),
    LanguageItem(code: 'es-MX', name: 'Español (México)', nativeName: 'Español mexicano', flag: '🇲🇽', regionalVariant: 'MX'),
    LanguageItem(code: 'es-AR', name: 'Español (Argentina)', nativeName: 'Español argentino', flag: '🇦🇷', regionalVariant: 'AR'),
    LanguageItem(code: 'es-PR', name: 'Español (Puerto Rico)', nativeName: 'Español puertorriqueño', flag: '🇵🇷', regionalVariant: 'PR'),
    LanguageItem(code: 'es-CO', name: 'Español (Colombia)', nativeName: 'Español colombiano', flag: '🇨🇴', regionalVariant: 'CO'),
    LanguageItem(code: 'es-CL', name: 'Español (Chile)', nativeName: 'Español chileno', flag: '🇨🇱', regionalVariant: 'CL'),
    LanguageItem(code: 'es-CU', name: 'Español (Cuba)', nativeName: 'Español cubano', flag: '🇨🇺', regionalVariant: 'CU'),
    LanguageItem(code: 'es-DO', name: 'Español (República Dominicana)', nativeName: 'Español dominicano', flag: '🇩🇴', regionalVariant: 'DO'),
    LanguageItem(code: 'fr', name: 'Французский', nativeName: 'Français', flag: '🇫🇷'),
    LanguageItem(code: 'fr-CA', name: 'Français (Canada)', nativeName: 'Français canadien', flag: '🇨🇦', regionalVariant: 'CA'),
    LanguageItem(code: 'fr-BE', name: 'Français (Belgique)', nativeName: 'Français belge', flag: '🇧🇪', regionalVariant: 'BE'),
    LanguageItem(code: 'fr-CH', name: 'Français (Suisse)', nativeName: 'Français suisse', flag: '🇨🇭', regionalVariant: 'CH'),
    LanguageItem(code: 'de', name: 'Немецкий', nativeName: 'Deutsch', flag: '🇩🇪'),
    LanguageItem(code: 'de-AT', name: 'Deutsch (Österreich)', nativeName: 'Österreichisches Deutsch', flag: '🇦🇹', regionalVariant: 'AT'),
    LanguageItem(code: 'de-CH', name: 'Deutsch (Schweiz)', nativeName: 'Schweizerdeutsch', flag: '🇨🇭', regionalVariant: 'CH'),
    LanguageItem(code: 'it', name: 'Итальянский', nativeName: 'Italiano', flag: '🇮🇹'),
    LanguageItem(code: 'pt-PT', name: 'Португальский (Португалия)', nativeName: 'Português', flag: '🇵🇹'),
    LanguageItem(code: 'pt-BR', name: 'Португальский (Бразилия)', nativeName: 'Português do Brasil', flag: '🇧🇷'),
    LanguageItem(code: 'pt-AO', name: 'Português (Africa)', nativeName: 'Português africano', flag: '🇦🇴', regionalVariant: 'AO'),
    LanguageItem(code: 'zh-CN', name: 'Китайский (Упрощенный)', nativeName: '简体中文', flag: '🇨🇳'),
    LanguageItem(code: 'zh-TW', name: 'Китайский (Традиционный)', nativeName: '繁體中文', flag: '🇹🇼'),
    LanguageItem(code: 'zh-HK', name: '中文 (香港)', nativeName: '繁體中文（香港）', flag: '🇭🇰', regionalVariant: 'HK'),
    LanguageItem(code: 'ja', name: 'Японский', nativeName: '日本語', flag: '🇯🇵'),
    LanguageItem(code: 'ko', name: 'Корейский', nativeName: '한국어', flag: '🇰🇷'),
    LanguageItem(code: 'ar', name: 'Арабский', nativeName: 'العربية', flag: '🇸🇦'),
    LanguageItem(code: 'ar-EG', name: 'العربية (مصر)', nativeName: 'العربية المصرية', flag: '🇪🇬', regionalVariant: 'EG'),
    LanguageItem(code: 'ar-AE', name: 'العربية (الإمارات)', nativeName: 'العربية الإماراتية', flag: '🇦🇪', regionalVariant: 'AE'),
    LanguageItem(code: 'tr', name: 'Турецкий', nativeName: 'Türkçe', flag: '🇹🇷'),
    LanguageItem(code: 'nl', name: 'Нидерландский', nativeName: 'Nederlands', flag: '🇳🇱'),
    LanguageItem(code: 'pl', name: 'Польский', nativeName: 'Polski', flag: '🇵🇱'),
    LanguageItem(code: 'uk', name: 'Украинский', nativeName: 'Українська', flag: '🇺🇦'),
    LanguageItem(code: 'hi', name: 'Хинди', nativeName: 'हिन्दी', flag: '🇮🇳'),
    LanguageItem(code: 'hi-Latn', name: 'Hindi (Latin)', nativeName: 'Hinglish', flag: '🇮🇳', regionalVariant: 'Latn'),
    LanguageItem(code: 'he', name: 'Иврит', nativeName: 'עברית', flag: '🇮🇱'),
    LanguageItem(code: 'sv', name: 'Шведский', nativeName: 'Svenska', flag: '🇸🇪'),
    LanguageItem(code: 'no', name: 'Норвежский', nativeName: 'Norsk', flag: '🇳🇴'),
    LanguageItem(code: 'da', name: 'Датский', nativeName: 'Dansk', flag: '🇩🇰'),
    LanguageItem(code: 'fi', name: 'Финский', nativeName: 'Suomi', flag: '🇫🇮'),
    LanguageItem(code: 'el', name: 'Греческий', nativeName: 'Ελληνικά', flag: '🇬🇷'),
    LanguageItem(code: 'cs', name: 'Чешский', nativeName: 'Čeština', flag: '🇨🇿'),
    LanguageItem(code: 'hu', name: 'Венгерский', nativeName: 'Magyar', flag: '🇭🇺'),
    LanguageItem(code: 'ro', name: 'Румынский', nativeName: 'Română', flag: '🇷🇴'),
    LanguageItem(code: 'bg', name: 'Болгарский', nativeName: 'Български', flag: '🇧🇬'),
    LanguageItem(code: 'sk', name: 'Словацкий', nativeName: 'Slovenčina', flag: '🇸🇰'),
    LanguageItem(code: 'hr', name: 'Хорватский', nativeName: 'Hrvatski', flag: '🇭🇷'),
    LanguageItem(code: 'sr', name: 'Сербский', nativeName: 'Српски', flag: '🇷🇸'),
    LanguageItem(code: 'sl', name: 'Словенский', nativeName: 'Slovenščina', flag: '🇸🇮'),
    LanguageItem(code: 'ca', name: 'Каталанский', nativeName: 'Català', flag: '🇪🇸'),
    LanguageItem(code: 'eu', name: 'Баскский', nativeName: 'Euskara', flag: '🇪🇸'),
    LanguageItem(code: 'gl', name: 'Галисийский', nativeName: 'Galego', flag: '🇪🇸'),
    LanguageItem(code: 'ga', name: 'Ирландский', nativeName: 'Gaeilge', flag: '🇮🇪'),
    LanguageItem(code: 'cy', name: 'Валлийский', nativeName: 'Cymraeg', flag: '🇬🇧'),
    LanguageItem(code: 'fa', name: 'Персидский (Фарси)', nativeName: 'فارسی', flag: '🇮🇷'),
    LanguageItem(code: 'ur', name: 'Урду', nativeName: 'اردو', flag: '🇵🇰'),
    LanguageItem(code: 'bn', name: 'Бенгальский', nativeName: 'বাংলা', flag: '🇧🇩'),
    LanguageItem(code: 'pa', name: 'Пенджаби', nativeName: 'ਪੰਜਾਬੀ', flag: '🇮🇳'),
    LanguageItem(code: 'gu', name: 'Гуджарати', nativeName: 'ગુજરાતી', flag: '🇮🇳'),
    LanguageItem(code: 'ta', name: 'Тамильский', nativeName: 'தமிழ்', flag: '🇮🇳'),
    LanguageItem(code: 'te', name: 'Телугу', nativeName: 'తెలుగు', flag: '🇮🇳'),
    LanguageItem(code: 'kn', name: 'Каннада', nativeName: 'ಕನ್ನಡ', flag: '🇮🇳'),
    LanguageItem(code: 'ml', name: 'Малаялам', nativeName: 'മലയാളം', flag: '🇮🇳'),
    LanguageItem(code: 'mr', name: 'Маратхи', nativeName: 'मराठी', flag: '🇮🇳'),
    LanguageItem(code: 'th', name: 'Тайский', nativeName: 'ไทย', flag: '🇹🇭'),
    LanguageItem(code: 'vi', name: 'Вьетнамский', nativeName: 'Tiếng Việt', flag: '🇻🇳'),
    LanguageItem(code: 'id', name: 'Индонезийский', nativeName: 'Bahasa Indonesia', flag: '🇮🇩'),
    LanguageItem(code: 'ms', name: 'Малайский', nativeName: 'Bahasa Melayu', flag: '🇲🇾'),
    LanguageItem(code: 'fil', name: 'Филиппинский (Тагалог)', nativeName: 'Filipino', flag: '🇵🇭'),
    LanguageItem(code: 'sw', name: 'Суахили', nativeName: 'Kiswahili', flag: '🇰🇪'),
    LanguageItem(code: 'am', name: 'Амхарский', nativeName: 'አማርኛ', flag: '🇪🇹'),
    LanguageItem(code: 'af', name: 'Африкаанс', nativeName: 'Afrikaans', flag: '🇿🇦'),
    LanguageItem(code: 'is', name: 'Исландский', nativeName: 'Íslenska', flag: '🇮🇸'),
    LanguageItem(code: 'et', name: 'Эстонский', nativeName: 'Eesti', flag: '🇪🇪'),
    LanguageItem(code: 'lv', name: 'Латышский', nativeName: 'Latviešu', flag: '🇱🇻'),
    LanguageItem(code: 'lt', name: 'Литовский', nativeName: 'Lietuvių', flag: '🇱🇹'),
    LanguageItem(code: 'be', name: 'Белорусский', nativeName: 'Беларуская', flag: '🇧🇾'),
    LanguageItem(code: 'kk', name: 'Казахский', nativeName: 'Қазақ тілі', flag: '🇰🇿'),
    LanguageItem(code: 'uz', name: 'Узбекский', nativeName: 'O‘zbek', flag: '🇺🇿'),
    LanguageItem(code: 'ky', name: 'Киргизский', nativeName: 'Кыргызча', flag: '🇰🇬'),
    LanguageItem(code: 'tg', name: 'Таджикский', nativeName: 'Тоҷикӣ', flag: '🇹🇯'),
    LanguageItem(code: 'tk', name: 'Туркменский', nativeName: 'Türkmen', flag: '🇹🇲'),
    LanguageItem(code: 'ka', name: 'Грузинский', nativeName: 'ქართული', flag: '🇬🇪'),
    LanguageItem(code: 'hy', name: 'Армянский', nativeName: 'Հայերեն', flag: '🇦🇲'),
    LanguageItem(code: 'az', name: 'Азербайджанский', nativeName: 'Azərbaycan', flag: '🇦🇿'),
    LanguageItem(code: 'mn', name: 'Монгольский', nativeName: 'Монгол', flag: '🇲🇳'),
    LanguageItem(code: 'bo', name: 'Тибетский', nativeName: 'བོད་སྐད', flag: '🇨🇳'),
    LanguageItem(code: 'ne', name: 'Непальский', nativeName: 'नेपाली', flag: '🇳🇵'),
    LanguageItem(code: 'si', name: 'Сингальский', nativeName: 'සිංහල', flag: '🇱🇰'),
    LanguageItem(code: 'my', name: 'Бирманский', nativeName: 'မြန်မာစာ', flag: '🇲🇲'),
    LanguageItem(code: 'km', name: 'Кхмерский', nativeName: 'ភាសាខ្មែរ', flag: '🇰🇭'),
    LanguageItem(code: 'lo', name: 'Лаосский', nativeName: 'ພາສາລາວ', flag: '🇱🇦'),
    LanguageItem(code: 'mi', name: 'Маори', nativeName: 'Te Reo Māori', flag: '🇳🇿'),
    LanguageItem(code: 'haw', name: 'Гавайский', nativeName: 'ʻŌlelo Hawaiʻi', flag: '🇺🇸'),
    LanguageItem(code: 'eo', name: 'Эсперанто', nativeName: 'Esperanto', flag: '🌐'),
    LanguageItem(code: 'la', name: 'Латынь', nativeName: 'Latina', flag: '🏛'),
    LanguageItem(code: 'yi', name: 'Идиш', nativeName: 'ייִדיש', flag: '🕎'),
    LanguageItem(code: 'ps', name: 'Пушту', nativeName: 'پښتو', flag: '🇦🇫'),
    LanguageItem(code: 'ku', name: 'Курдский', nativeName: 'Kurdî', flag: '☀️'),
    LanguageItem(code: 'so', name: 'Сомалийский', nativeName: 'Soomaali', flag: '🇸🇴'),
    LanguageItem(code: 'zu', name: 'Зулу', nativeName: 'isiZulu', flag: '🇿🇦'),
    LanguageItem(code: 'xh', name: 'Коса', nativeName: 'isiXhosa', flag: '🇿🇦'),
    LanguageItem(code: 'yo', name: 'Йоруба', nativeName: 'Yorùbá', flag: '🇳🇬'),
    LanguageItem(code: 'ig', name: 'Игбо', nativeName: 'Asụsụ Igbo', flag: '🇳🇬'),
    LanguageItem(code: 'ha', name: 'Хауса', nativeName: 'Hausa', flag: '🇳🇬'),
    LanguageItem(code: 'mg', name: 'Малагасийский', nativeName: 'Malagasy', flag: '🇲🇬'),
    LanguageItem(code: 'jv', name: 'Яванский', nativeName: 'Basa Jawa', flag: '🇮🇩'),
    LanguageItem(code: 'su', name: 'Сунданский', nativeName: 'Basa Sunda', flag: '🇮🇩'),
    LanguageItem(code: 'ceb', name: 'Себуанский', nativeName: 'Cebuano', flag: '🇵🇭'),
    LanguageItem(code: 'sq', name: 'Албанский', nativeName: 'Shqip', flag: '🇦🇱'),
    LanguageItem(code: 'mk', name: 'Македонский', nativeName: 'Македонски', flag: '🇲🇰'),
    LanguageItem(code: 'bs', name: 'Боснийский', nativeName: 'Bosanski', flag: '🇧🇦'),
    LanguageItem(code: 'mt', name: 'Мальтийский', nativeName: 'Malti', flag: '🇲🇹'),
    LanguageItem(code: 'lb', name: 'Люксембургский', nativeName: 'Lëtzebuergesch', flag: '🇱🇺'),
  ];
}
