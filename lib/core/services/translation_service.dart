import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:screenshots/features/editor/constants/apikey.dart';

/// Request model for translation operations
class TranslationRequest {
  final String text;
  final String fromLanguage;
  final String toLanguage;
  final String? context;
  final String? elementId;

  const TranslationRequest({
    required this.text,
    required this.fromLanguage,
    required this.toLanguage,
    this.context,
    this.elementId,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'fromLanguage': fromLanguage,
      'toLanguage': toLanguage,
      'context': context,
      'elementId': elementId,
    };
  }
}

/// Response model for translation operations
class TranslationResponse {
  final String translatedText;
  final String fromLanguage;
  final String toLanguage;
  final String? elementId;
  final bool success;
  final String? error;

  const TranslationResponse({
    required this.translatedText,
    required this.fromLanguage,
    required this.toLanguage,
    this.elementId,
    this.success = true,
    this.error,
  });

  factory TranslationResponse.error(
    String error, {
    String? fromLanguage,
    String? toLanguage,
    String? elementId,
  }) {
    return TranslationResponse(
      translatedText: '',
      fromLanguage: fromLanguage ?? '',
      toLanguage: toLanguage ?? '',
      elementId: elementId,
      success: false,
      error: error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'translatedText': translatedText,
      'fromLanguage': fromLanguage,
      'toLanguage': toLanguage,
      'elementId': elementId,
      'success': success,
      'error': error,
    };
  }
}

/// Batch translation response
class BatchTranslationResponse {
  final List<TranslationResponse> translations;
  final int successCount;
  final int errorCount;
  final bool allSuccessful;

  const BatchTranslationResponse({
    required this.translations,
    required this.successCount,
    required this.errorCount,
    required this.allSuccessful,
  });

  factory BatchTranslationResponse.fromTranslations(List<TranslationResponse> translations) {
    final successCount = translations.where((t) => t.success).length;
    final errorCount = translations.length - successCount;
    final allSuccessful = errorCount == 0;

    return BatchTranslationResponse(
      translations: translations,
      successCount: successCount,
      errorCount: errorCount,
      allSuccessful: allSuccessful,
    );
  }
}

/// Service for handling translations using Google's Gemini 1.5 Flash API
class TranslationService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';
  static const int _maxRetries = 3;
  static const int _retryDelayMs = 1000;
  
  final http.Client _httpClient;
  late final String _apiKey;

  TranslationService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client() {
    _apiKey = _getApiKey();
  }

  String _getApiKey() {
    //final apiKey = Platform.environment['GEMINI_API_KEY'];
    final apiKey = apiKeytemp;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY environment variable is not set. Please set it to use translation features.');
    }
    return apiKey;
  }

  /// Translates a single text from one language to another
  Future<TranslationResponse> translateText({
    required String text,
    required String fromLanguage,
    required String toLanguage,
    String? context,
    String? elementId,
  }) async {
    if (text.trim().isEmpty) {
      return TranslationResponse.error(
        'Empty text provided for translation',
        fromLanguage: fromLanguage,
        toLanguage: toLanguage,
        elementId: elementId,
      );
    }

    try {
      final prompt = _buildSingleTranslationPrompt(
        text: text,
        fromLanguage: fromLanguage,
        toLanguage: toLanguage,
        context: context,
      );

      final response = await _makeApiCall(prompt);
      if (response.success) {
        return TranslationResponse(
          translatedText: response.translatedText,
          fromLanguage: fromLanguage,
          toLanguage: toLanguage,
          elementId: elementId,
        );
      } else {
        return TranslationResponse.error(
          response.error ?? 'Unknown translation error',
          fromLanguage: fromLanguage,
          toLanguage: toLanguage,
          elementId: elementId,
        );
      }
    } catch (e) {
      return TranslationResponse.error(
        'Translation failed: $e',
        fromLanguage: fromLanguage,
        toLanguage: toLanguage,
        elementId: elementId,
      );
    }
  }

  /// Translates multiple texts in a single batch operation
  Future<BatchTranslationResponse> translateBatch(List<TranslationRequest> requests) async {
    if (requests.isEmpty) {
      return const BatchTranslationResponse(
        translations: [],
        successCount: 0,
        errorCount: 0,
        allSuccessful: true,
      );
    }

    // Group requests by language pair for efficiency
    final groupedRequests = _groupRequestsByLanguagePair(requests);
    final allTranslations = <TranslationResponse>[];

    for (final group in groupedRequests) {
      try {
        final prompt = _buildBatchTranslationPrompt(group);
        final response = await _makeApiCall(prompt);

        if (response.success) {
          final batchResults = _parseBatchResponse(response.translatedText, group);
          allTranslations.addAll(batchResults);
        } else {
          // Add error responses for all requests in this group
          for (final request in group) {
            allTranslations.add(TranslationResponse.error(
              response.error ?? 'Batch translation failed',
              fromLanguage: request.fromLanguage,
              toLanguage: request.toLanguage,
              elementId: request.elementId,
            ));
          }
        }
      } catch (e) {
        // Add error responses for all requests in this group
        for (final request in group) {
          allTranslations.add(TranslationResponse.error(
            'Batch translation failed: $e',
            fromLanguage: request.fromLanguage,
            toLanguage: request.toLanguage,
            elementId: request.elementId,
          ));
        }
      }
    }

    return BatchTranslationResponse.fromTranslations(allTranslations);
  }

  /// Groups translation requests by language pair for batch efficiency
  List<List<TranslationRequest>> _groupRequestsByLanguagePair(List<TranslationRequest> requests) {
    final Map<String, List<TranslationRequest>> groups = {};
    
    for (final request in requests) {
      final key = '${request.fromLanguage}->${request.toLanguage}';
      groups.putIfAbsent(key, () => []).add(request);
    }
    
    return groups.values.toList();
  }

  /// Builds a context-aware prompt for single text translation
  String _buildSingleTranslationPrompt({
    required String text,
    required String fromLanguage,
    required String toLanguage,
    String? context,
  }) {
    final contextualInfo = context != null ? '\nContext: $context' : '';
    
    return '''
You are a professional translator specializing in app store screenshots and mobile app content. 
Please translate the following text from $fromLanguage to $toLanguage.

Important guidelines:
- Maintain the tone and style appropriate for mobile app descriptions
- Keep translations concise and impactful for screenshot overlays
- Preserve any technical terms or brand names appropriately
- Ensure the translation fits naturally in a mobile app context$contextualInfo

Text to translate: "$text"

Provide only the translated text without any additional explanation or formatting.
''';
  }

  /// Builds a context-aware prompt for batch translation
  String _buildBatchTranslationPrompt(List<TranslationRequest> requests) {
    if (requests.isEmpty) return '';
    
    final fromLang = requests.first.fromLanguage;
    final toLang = requests.first.toLanguage;
    
    final textList = requests.asMap().entries
        .map((entry) => '${entry.key + 1}. "${entry.value.text}"')
        .join('\n');

    return '''
You are a professional translator specializing in app store screenshots and mobile app content.
Please translate the following texts from $fromLang to $toLang.

Important guidelines:
- Maintain the tone and style appropriate for mobile app descriptions
- Keep translations concise and impactful for screenshot overlays
- Preserve any technical terms or brand names appropriately
- Ensure translations fit naturally in a mobile app context
- Maintain consistency across all translations

Texts to translate:
$textList

Please provide the translations in the same numbered format, one per line:
1. [translation 1]
2. [translation 2]
...

Provide only the numbered translations without additional explanation.
''';
  }

  /// Makes the actual API call to Gemini
  Future<TranslationResponse> _makeApiCall(String prompt) async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final requestBody = {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1, // Low temperature for consistent translations
            'topK': 1,
            'topP': 0.8,
            'maxOutputTokens': 2048,
          }
        };

        final response = await _httpClient.post(
          Uri.parse('$_baseUrl?key=$_apiKey'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final translatedText = _extractTranslationFromResponse(responseData);
          
          return TranslationResponse(
            translatedText: translatedText,
            fromLanguage: '',
            toLanguage: '',
          );
        } else if (response.statusCode == 429 && attempt < _maxRetries) {
          // Rate limited, retry with exponential backoff
          await Future.delayed(Duration(milliseconds: _retryDelayMs * attempt));
          continue;
        } else {
          final errorBody = response.body;
          return TranslationResponse.error(
            'API request failed: ${response.statusCode} - $errorBody'
          );
        }
      } on SocketException {
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(milliseconds: _retryDelayMs * attempt));
          continue;
        }
        return TranslationResponse.error('Network error: Please check your internet connection');
      } catch (e) {
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(milliseconds: _retryDelayMs * attempt));
          continue;
        }
        return TranslationResponse.error('Translation failed: $e');
      }
    }

    return TranslationResponse.error('Translation failed after $_maxRetries attempts');
  }

  /// Extracts the translated text from Gemini's response
  String _extractTranslationFromResponse(Map<String, dynamic> responseData) {
    try {
      final candidates = responseData['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No translation candidates in response');
      }

      final content = candidates.first['content'] as Map<String, dynamic>?;
      if (content == null) {
        throw Exception('No content in response');
      }

      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('No parts in response content');
      }

      final text = parts.first['text'] as String?;
      if (text == null || text.trim().isEmpty) {
        throw Exception('Empty translation text in response');
      }

      return text.trim();
    } catch (e) {
      throw Exception('Failed to parse translation response: $e');
    }
  }

  /// Parses batch translation response into individual translations
  List<TranslationResponse> _parseBatchResponse(String batchResponse, List<TranslationRequest> requests) {
    final lines = batchResponse.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final translations = <TranslationResponse>[];

    for (int i = 0; i < requests.length; i++) {
      final request = requests[i];
      String translatedText = '';

      // Try to find the corresponding numbered line
      if (i < lines.length) {
        final line = lines[i].trim();
        // Remove number prefix (e.g., "1. " or "2. ")
        final numberPattern = RegExp(r'^\d+\.\s*');
        translatedText = line.replaceFirst(numberPattern, '').trim();
      }

      if (translatedText.isEmpty) {
        translations.add(TranslationResponse.error(
          'Failed to parse translation ${i + 1}',
          fromLanguage: request.fromLanguage,
          toLanguage: request.toLanguage,
          elementId: request.elementId,
        ));
      } else {
        translations.add(TranslationResponse(
          translatedText: translatedText,
          fromLanguage: request.fromLanguage,
          toLanguage: request.toLanguage,
          elementId: request.elementId,
        ));
      }
    }

    return translations;
  }

  /// Gets list of supported language codes
  static List<String> getSupportedLanguages() {
    return [
      'en', // English
      'es', // Spanish
      'fr', // French
      'de', // German
      'it', // Italian
      'pt', // Portuguese
      'ru', // Russian
      'ja', // Japanese
      'ko', // Korean
      'zh', // Chinese (Simplified)
      'ar', // Arabic
      'hi', // Hindi
      'nl', // Dutch
      'sv', // Swedish
      'da', // Danish
      'no', // Norwegian
      'fi', // Finnish
      'pl', // Polish
      'tr', // Turkish
      'th', // Thai
      'vi', // Vietnamese
      'id', // Indonesian
      'ms', // Malay
      'he', // Hebrew
      'cs', // Czech
      'sk', // Slovak
      'hu', // Hungarian
      'ro', // Romanian
      'bg', // Bulgarian
      'hr', // Croatian
      'sl', // Slovenian
      'et', // Estonian
      'lv', // Latvian
      'lt', // Lithuanian
      'uk', // Ukrainian
      'be', // Belarusian
      'mk', // Macedonian
      'sq', // Albanian
      'mt', // Maltese
      'is', // Icelandic
      'ga', // Irish
      'cy', // Welsh
      'eu', // Basque
      'ca', // Catalan
      'gl', // Galician
    ];
  }

  /// Gets display name for language code
  static String getLanguageDisplayName(String languageCode) {
    const languageNames = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'ja': 'Japanese',
      'ko': 'Korean',
      'zh': 'Chinese',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'nl': 'Dutch',
      'sv': 'Swedish',
      'da': 'Danish',
      'no': 'Norwegian',
      'fi': 'Finnish',
      'pl': 'Polish',
      'tr': 'Turkish',
      'th': 'Thai',
      'vi': 'Vietnamese',
      'id': 'Indonesian',
      'ms': 'Malay',
      'he': 'Hebrew',
      'cs': 'Czech',
      'sk': 'Slovak',
      'hu': 'Hungarian',
      'ro': 'Romanian',
      'bg': 'Bulgarian',
      'hr': 'Croatian',
      'sl': 'Slovenian',
      'et': 'Estonian',
      'lv': 'Latvian',
      'lt': 'Lithuanian',
      'uk': 'Ukrainian',
      'be': 'Belarusian',
      'mk': 'Macedonian',
      'sq': 'Albanian',
      'mt': 'Maltese',
      'is': 'Icelandic',
      'ga': 'Irish',
      'cy': 'Welsh',
      'eu': 'Basque',
      'ca': 'Catalan',
      'gl': 'Galician',
    };

    return languageNames[languageCode] ?? languageCode.toUpperCase();
  }

  /// Validates if a language code is supported
  static bool isLanguageSupported(String languageCode) {
    return getSupportedLanguages().contains(languageCode);
  }

  /// Disposes resources
  void dispose() {
    _httpClient.close();
  }
}