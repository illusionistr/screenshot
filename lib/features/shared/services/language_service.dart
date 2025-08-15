import '../models/language_model.dart';
import '../data/languages_data.dart';

class LanguageService {
  LanguageService._();

  static LanguageModel? getLanguageByCode(String code) {
    return LanguagesData.getLanguageByCode(code);
  }

  static List<LanguageModel> getAllLanguages() {
    return LanguagesData.allLanguages;
  }

  static List<LanguageModel> getLanguagesByRegion(String region) {
    return LanguagesData.getLanguagesByRegion(region);
  }

  static List<LanguageModel> getTopMarkets() {
    return LanguagesData.getTopMarkets();
  }

  static List<LanguageModel> getRTLLanguages() {
    return LanguagesData.getRTLLanguages();
  }

  static List<LanguageModel> getLTRLanguages() {
    return LanguagesData.getLTRLanguages();
  }

  static LanguageModel getDefaultLanguage() {
    return LanguagesData.defaultLanguage;
  }

  static bool isValidLanguageCode(String code) {
    return LanguagesData.isValidLanguageCode(code);
  }

  static List<LanguageModel> searchLanguages(String query) {
    if (query.isEmpty) return getAllLanguages();
    
    final lowerQuery = query.toLowerCase();
    return getAllLanguages().where((language) {
      return language.name.toLowerCase().contains(lowerQuery) ||
             language.nativeName.toLowerCase().contains(lowerQuery) ||
             language.code.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static List<LanguageModel> filterLanguages({
    bool? isRTL,
    String? region,
  }) {
    var languages = getAllLanguages();

    if (isRTL != null) {
      languages = languages.where((language) => language.isRTL == isRTL).toList();
    }

    if (region != null) {
      languages = getLanguagesByRegion(region);
    }

    return languages;
  }

  static Map<String, List<LanguageModel>> groupLanguagesByRegion() {
    return {
      'Americas': getLanguagesByRegion('americas'),
      'Europe': getLanguagesByRegion('europe'),
      'Asia': getLanguagesByRegion('asia'),
      'Middle East': getLanguagesByRegion('middle-east'),
    };
  }

  static bool validateLanguageSelection(List<String> languageCodes) {
    return languageCodes.every((code) => isValidLanguageCode(code));
  }

  static List<String> getInvalidLanguageCodes(List<String> languageCodes) {
    return languageCodes.where((code) => !isValidLanguageCode(code)).toList();
  }

  static List<LanguageModel> getRecommendedLanguages() {
    return [
      getDefaultLanguage(), // English
      ...getTopMarkets().where((lang) => lang.code != 'en').take(5),
    ];
  }

  static String formatLanguageDisplay(LanguageModel language, {bool showNative = true}) {
    if (showNative && language.name != language.nativeName) {
      return '${language.name} (${language.nativeName})';
    }
    return language.name;
  }

  static List<LanguageModel> sortLanguages(List<LanguageModel> languages, {
    String sortBy = 'name', // 'name', 'nativeName', 'code'
    bool ascending = true,
  }) {
    final sorted = List<LanguageModel>.from(languages);
    
    sorted.sort((a, b) {
      late String aValue;
      late String bValue;
      
      switch (sortBy) {
        case 'nativeName':
          aValue = a.nativeName;
          bValue = b.nativeName;
          break;
        case 'code':
          aValue = a.code;
          bValue = b.code;
          break;
        case 'name':
        default:
          aValue = a.name;
          bValue = b.name;
          break;
      }
      
      return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
    
    return sorted;
  }

  static bool hasRTLLanguage(List<String> languageCodes) {
    return languageCodes.any((code) {
      final language = getLanguageByCode(code);
      return language?.isRTL ?? false;
    });
  }

  static List<String> extractRTLLanguageCodes(List<String> languageCodes) {
    return languageCodes.where((code) {
      final language = getLanguageByCode(code);
      return language?.isRTL ?? false;
    }).toList();
  }

  static List<String> extractLTRLanguageCodes(List<String> languageCodes) {
    return languageCodes.where((code) {
      final language = getLanguageByCode(code);
      return language?.isRTL == false;
    }).toList();
  }
}