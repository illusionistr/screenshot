import '../models/language_model.dart';

class LanguagesData {
  LanguagesData._();

  static const List<LanguageModel> allLanguages = [
    // Primary markets
    LanguageModel(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      isRTL: false,
    ),
    LanguageModel(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      isRTL: false,
    ),
    LanguageModel(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      isRTL: false,
    ),
    LanguageModel(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      isRTL: false,
    ),
    LanguageModel(
      code: 'it',
      name: 'Italian',
      nativeName: 'Italiano',
      isRTL: false,
    ),
    LanguageModel(
      code: 'pt',
      name: 'Portuguese',
      nativeName: 'Português',
      isRTL: false,
    ),
    LanguageModel(
      code: 'pt-BR',
      name: 'Portuguese (Brazil)',
      nativeName: 'Português (Brasil)',
      isRTL: false,
    ),

    // Asian markets
    LanguageModel(
      code: 'zh-Hans',
      name: 'Chinese (Simplified)',
      nativeName: '简体中文',
      isRTL: false,
    ),
    LanguageModel(
      code: 'zh-Hant',
      name: 'Chinese (Traditional)',
      nativeName: '繁體中文',
      isRTL: false,
    ),
    LanguageModel(
      code: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
      isRTL: false,
    ),
    LanguageModel(
      code: 'ko',
      name: 'Korean',
      nativeName: '한국어',
      isRTL: false,
    ),
    LanguageModel(
      code: 'th',
      name: 'Thai',
      nativeName: 'ไทย',
      isRTL: false,
    ),
    LanguageModel(
      code: 'vi',
      name: 'Vietnamese',
      nativeName: 'Tiếng Việt',
      isRTL: false,
    ),
    LanguageModel(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      isRTL: false,
    ),
    LanguageModel(
      code: 'id',
      name: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
      isRTL: false,
    ),

    // Middle East and North Africa
    LanguageModel(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      isRTL: true,
    ),
    LanguageModel(
      code: 'he',
      name: 'Hebrew',
      nativeName: 'עברית',
      isRTL: true,
    ),
    LanguageModel(
      code: 'tr',
      name: 'Turkish',
      nativeName: 'Türkçe',
      isRTL: false,
    ),
    LanguageModel(
      code: 'fa',
      name: 'Persian',
      nativeName: 'فارسی',
      isRTL: true,
    ),

    // European markets
    LanguageModel(
      code: 'ru',
      name: 'Russian',
      nativeName: 'Русский',
      isRTL: false,
    ),
    LanguageModel(
      code: 'uk',
      name: 'Ukrainian',
      nativeName: 'Українська',
      isRTL: false,
    ),
    LanguageModel(
      code: 'pl',
      name: 'Polish',
      nativeName: 'Polski',
      isRTL: false,
    ),
    LanguageModel(
      code: 'nl',
      name: 'Dutch',
      nativeName: 'Nederlands',
      isRTL: false,
    ),
    LanguageModel(
      code: 'sv',
      name: 'Swedish',
      nativeName: 'Svenska',
      isRTL: false,
    ),
    LanguageModel(
      code: 'no',
      name: 'Norwegian',
      nativeName: 'Norsk',
      isRTL: false,
    ),
    LanguageModel(
      code: 'da',
      name: 'Danish',
      nativeName: 'Dansk',
      isRTL: false,
    ),
    LanguageModel(
      code: 'fi',
      name: 'Finnish',
      nativeName: 'Suomi',
      isRTL: false,
    ),
    LanguageModel(
      code: 'cs',
      name: 'Czech',
      nativeName: 'Čeština',
      isRTL: false,
    ),
    LanguageModel(
      code: 'sk',
      name: 'Slovak',
      nativeName: 'Slovenčina',
      isRTL: false,
    ),
    LanguageModel(
      code: 'hu',
      name: 'Hungarian',
      nativeName: 'Magyar',
      isRTL: false,
    ),
    LanguageModel(
      code: 'ro',
      name: 'Romanian',
      nativeName: 'Română',
      isRTL: false,
    ),
    LanguageModel(
      code: 'hr',
      name: 'Croatian',
      nativeName: 'Hrvatski',
      isRTL: false,
    ),
    LanguageModel(
      code: 'bg',
      name: 'Bulgarian',
      nativeName: 'Български',
      isRTL: false,
    ),
    LanguageModel(
      code: 'el',
      name: 'Greek',
      nativeName: 'Ελληνικά',
      isRTL: false,
    ),

    // Other markets
    LanguageModel(
      code: 'ms',
      name: 'Malay',
      nativeName: 'Bahasa Melayu',
      isRTL: false,
    ),
    LanguageModel(
      code: 'tl',
      name: 'Filipino',
      nativeName: 'Filipino',
      isRTL: false,
    ),
    LanguageModel(
      code: 'sw',
      name: 'Swahili',
      nativeName: 'Kiswahili',
      isRTL: false,
    ),
  ];

  static LanguageModel? getLanguageByCode(String code) {
    try {
      return allLanguages.firstWhere((language) => language.code == code);
    } catch (e) {
      return null;
    }
  }

  static List<LanguageModel> getLanguagesByRegion(String region) {
    switch (region.toLowerCase()) {
      case 'europe':
        return allLanguages.where((lang) => [
          'en', 'fr', 'de', 'it', 'es', 'pt', 'ru', 'uk', 'pl', 'nl', 'sv', 'no', 'da', 'fi', 'cs', 'sk', 'hu', 'ro', 'hr', 'bg', 'el'
        ].contains(lang.code)).toList();
      case 'asia':
        return allLanguages.where((lang) => [
          'zh-Hans', 'zh-Hant', 'ja', 'ko', 'th', 'vi', 'hi', 'id', 'ms', 'tl'
        ].contains(lang.code)).toList();
      case 'middle-east':
        return allLanguages.where((lang) => [
          'ar', 'he', 'tr', 'fa'
        ].contains(lang.code)).toList();
      case 'americas':
        return allLanguages.where((lang) => [
          'en', 'es', 'pt', 'pt-BR', 'fr'
        ].contains(lang.code)).toList();
      default:
        return allLanguages;
    }
  }

  static List<LanguageModel> getTopMarkets() {
    return allLanguages.where((lang) => [
      'en', 'es', 'fr', 'de', 'it', 'pt', 'zh-Hans', 'zh-Hant', 'ja', 'ko', 'ar', 'ru'
    ].contains(lang.code)).toList();
  }

  static List<LanguageModel> getRTLLanguages() {
    return allLanguages.where((language) => language.isRTL).toList();
  }

  static List<LanguageModel> getLTRLanguages() {
    return allLanguages.where((language) => !language.isRTL).toList();
  }

  static List<String> getAllLanguageCodes() {
    return allLanguages.map((language) => language.code).toList();
  }

  static LanguageModel get defaultLanguage => allLanguages.first; // English

  static bool isValidLanguageCode(String code) {
    return allLanguages.any((language) => language.code == code);
  }
}