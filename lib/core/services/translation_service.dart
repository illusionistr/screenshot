import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:screenshots/features/editor/constants/apikey.dart';
import 'translation_cache_service.dart';

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

/// Error types for translation operations
enum TranslationErrorType {
  networkError,
  rateLimitError,
  authenticationError,
  invalidInput,
  serverError,
  timeoutError,
  textTooLong,
  quotaExceeded,
  unsupportedLanguage,
  unknown,
}

/// Enhanced error information for translations
class TranslationError {
  final TranslationErrorType type;
  final String message;
  final String? details;
  final bool isRetryable;
  final Duration? suggestedRetryDelay;

  const TranslationError({
    required this.type,
    required this.message,
    this.details,
    this.isRetryable = false,
    this.suggestedRetryDelay,
  });

  @override
  String toString() => 'TranslationError(${type.name}): $message';
}

/// Service for handling translations using Google's Gemini 1.5 Flash API
class TranslationService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';
  static const int _maxRetries = 5; // Increased retries
  static const int _retryDelayMs = 1000;
  static const int _maxCharactersPerRequest = 5000; // Text chunking limit
  static const Duration _requestTimeout = Duration(seconds: 30);
  
  final http.Client _httpClient;
  final TranslationCacheService _cacheService;
  late final String _apiKey;

  TranslationService({
    http.Client? httpClient,
    TranslationCacheService? cacheService,
  }) : 
    _httpClient = httpClient ?? http.Client(),
    _cacheService = cacheService ?? TranslationCacheService() {
    _apiKey = _getApiKey();
  }

  /// Initialize the translation service
  Future<void> initialize() async {
    print('[TranslationService] Initializing translation service...');
    try {
      await _cacheService.initialize();
      print('[TranslationService] Cache service initialized successfully');
      
      // Test API key availability
      final apiKey = _getApiKey();
      print('[TranslationService] API key available: ${apiKey.isNotEmpty}');
      
      print('[TranslationService] Translation service initialization completed');
    } catch (e) {
      print('[TranslationService] Translation service initialization failed: $e');
      rethrow;
    }
  }

  String _getApiKey() {
    //final apiKey = Platform.environment['GEMINI_API_KEY'];
    final apiKey = apiKeytemp;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY environment variable is not set. Please set it to use translation features.');
    }
    return apiKey;
  }

  /// Translates a single text from one language to another with enhanced error handling
  Future<TranslationResponse> translateText({
    required String text,
    required String fromLanguage,
    required String toLanguage,
    String? context,
    String? elementId,
    bool useCache = true,
  }) async {
    print('[TranslationService] translateText called');
    print('[TranslationService] Text: "$text"');
    print('[TranslationService] From: $fromLanguage');
    print('[TranslationService] To: $toLanguage');
    print('[TranslationService] Context: $context');
    print('[TranslationService] Element ID: $elementId');
    print('[TranslationService] Use cache: $useCache');
    // Input validation
    print('[TranslationService] Validating input...');
    final validationError = _validateTranslationInput(text, fromLanguage, toLanguage);
    if (validationError != null) {
      print('[TranslationService] Validation failed: ${validationError.message}');
      return TranslationResponse.error(
        validationError.message,
        fromLanguage: fromLanguage,
        toLanguage: toLanguage,
        elementId: elementId,
      );
    }
    print('[TranslationService] Input validation passed');

    // Check cache first (if enabled and no context provided)
    if (useCache && context == null) {
      print('[TranslationService] Checking cache...');
      final cached = _cacheService.getCachedTranslation(
        text: text,
        fromLanguage: fromLanguage,
        toLanguage: toLanguage,
      );
      
      if (cached != null) {
        print('[TranslationService] Cache hit! Returning cached translation: "${cached.translatedText}"');
        return TranslationResponse(
          translatedText: cached.translatedText,
          fromLanguage: fromLanguage,
          toLanguage: toLanguage,
          elementId: elementId,
        );
      }
      print('[TranslationService] Cache miss, proceeding with API call');
    } else {
      print('[TranslationService] Skipping cache (useCache: $useCache, context: $context)');
    }

    try {
      // Handle long text by chunking
      if (text.length > _maxCharactersPerRequest) {
        print('[TranslationService] Text too long (${text.length} chars), using chunking');
        return await _translateLongText(
          text: text,
          fromLanguage: fromLanguage,
          toLanguage: toLanguage,
          context: context,
          elementId: elementId,
          useCache: useCache,
        );
      }
      
      print('[TranslationService] Text length OK (${text.length} chars), proceeding with single request');

      print('[TranslationService] Building translation prompt...');
      final prompt = _buildSingleTranslationPrompt(
        text: text,
        fromLanguage: fromLanguage,
        toLanguage: toLanguage,
        context: context,
      );
      
      print('[TranslationService] Prompt length: ${prompt.length} chars');
      print('[TranslationService] Making API call...');
      final response = await _makeApiCallWithRetry(prompt);
      print('[TranslationService] API call completed');
      if (response.success) {
        print('[TranslationService] Translation successful: "${response.translatedText}"');
        // Cache the result (if caching enabled and no context)
        if (useCache && context == null) {
          print('[TranslationService] Caching translation result...');
          await _cacheService.cacheTranslation(
            originalText: text,
            translatedText: response.translatedText,
            fromLanguage: fromLanguage,
            toLanguage: toLanguage,
          );
          print('[TranslationService] Translation cached');
        }

        print('[TranslationService] Returning successful translation response');
        return TranslationResponse(
          translatedText: response.translatedText,
          fromLanguage: fromLanguage,
          toLanguage: toLanguage,
          elementId: elementId,
        );
      } else {
        print('[TranslationService] Translation failed: ${response.error}');
        return TranslationResponse.error(
          response.error ?? 'Unknown translation error',
          fromLanguage: fromLanguage,
          toLanguage: toLanguage,
          elementId: elementId,
        );
      }
    } catch (e) {
      print('[TranslationService] Exception caught: $e');
      print('[TranslationService] Exception type: ${e.runtimeType}');
      final error = _classifyError(e);
      print('[TranslationService] Classified error: ${error.type.name} - ${error.message}');
      return TranslationResponse.error(
        '${error.type.name}: ${error.message}',
        fromLanguage: fromLanguage,
        toLanguage: toLanguage,
        elementId: elementId,
      );
    }
  }

  /// Translates multiple texts in a single batch operation
  Future<BatchTranslationResponse> translateBatch(List<TranslationRequest> requests) async {
    print('[TranslationService] translateBatch called with ${requests.length} requests');

    if (requests.isEmpty) {
      print('[TranslationService] No requests to process, returning empty response');
      return const BatchTranslationResponse(
        translations: [],
        successCount: 0,
        errorCount: 0,
        allSuccessful: true,
      );
    }

    // Log request details
    for (int i = 0; i < requests.length; i++) {
      final req = requests[i];
      print('[TranslationService] Request #${i + 1}: "${req.text}" (${req.fromLanguage} -> ${req.toLanguage})');
    }

    // Group requests by language pair for efficiency
    final groupedRequests = _groupRequestsByLanguagePair(requests);
    print('[TranslationService] Grouped into ${groupedRequests.length} language pair groups');
    final allTranslations = <TranslationResponse>[];

    int groupIndex = 0;
    for (final group in groupedRequests) {
      groupIndex++;
      print('[TranslationService] Processing group $groupIndex/${groupedRequests.length} with ${group.length} requests');

      try {
        final prompt = _buildBatchTranslationPrompt(group);
        print('[TranslationService] Making API call for group $groupIndex...');
        final response = await _makeApiCall(prompt);

        if (response.success) {
          print('[TranslationService] API call successful for group $groupIndex');
          print('[TranslationService] Response text: "${response.translatedText.substring(0, response.translatedText.length > 100 ? 100 : response.translatedText.length)}..."');
          final batchResults = _parseBatchResponse(response.translatedText, group);
          print('[TranslationService] Parsed ${batchResults.length} translations from group $groupIndex');
          allTranslations.addAll(batchResults);
        } else {
          print('[TranslationService] API call failed for group $groupIndex: ${response.error}');
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
      } catch (e, stackTrace) {
        print('[TranslationService] Exception in group $groupIndex: $e');
        print('[TranslationService] Stack trace: $stackTrace');
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

    print('[TranslationService] Batch translation complete - Total translations: ${allTranslations.length}');
    final batchResponse = BatchTranslationResponse.fromTranslations(allTranslations);
    print('[TranslationService] Batch response - Success: ${batchResponse.successCount}, Errors: ${batchResponse.errorCount}');
    return batchResponse;
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

  /// Validates translation input parameters
  TranslationError? _validateTranslationInput(String text, String fromLanguage, String toLanguage) {
    if (text.trim().isEmpty) {
      return const TranslationError(
        type: TranslationErrorType.invalidInput,
        message: 'Empty text provided for translation',
      );
    }

    if (!isLanguageSupported(fromLanguage)) {
      return TranslationError(
        type: TranslationErrorType.unsupportedLanguage,
        message: 'Unsupported source language: $fromLanguage',
      );
    }

    if (!isLanguageSupported(toLanguage)) {
      return TranslationError(
        type: TranslationErrorType.unsupportedLanguage,
        message: 'Unsupported target language: $toLanguage',
      );
    }

    return null;
  }

  /// Handles translation of long text by chunking
  Future<TranslationResponse> _translateLongText({
    required String text,
    required String fromLanguage,
    required String toLanguage,
    String? context,
    String? elementId,
    bool useCache = true,
  }) async {
    final chunks = _chunkText(text, _maxCharactersPerRequest);
    final translatedChunks = <String>[];

    for (int i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];
      final chunkContext = context != null 
          ? '$context (Part ${i + 1} of ${chunks.length})'
          : 'Part ${i + 1} of ${chunks.length}';
      
      final response = await translateText(
        text: chunk,
        fromLanguage: fromLanguage,
        toLanguage: toLanguage,
        context: chunkContext,
        elementId: '$elementId-chunk-$i',
        useCache: useCache,
      );

      if (!response.success) {
        return TranslationResponse.error(
          'Failed to translate chunk ${i + 1}: ${response.error}',
          fromLanguage: fromLanguage,
          toLanguage: toLanguage,
          elementId: elementId,
        );
      }

      translatedChunks.add(response.translatedText);
    }

    return TranslationResponse(
      translatedText: translatedChunks.join(' '),
      fromLanguage: fromLanguage,
      toLanguage: toLanguage,
      elementId: elementId,
    );
  }

  /// Chunks text into smaller pieces while preserving word boundaries
  List<String> _chunkText(String text, int maxChars) {
    if (text.length <= maxChars) {
      return [text];
    }

    final chunks = <String>[];
    final words = text.split(' ');
    var currentChunk = '';

    for (final word in words) {
      final potentialChunk = currentChunk.isEmpty ? word : '$currentChunk $word';
      
      if (potentialChunk.length <= maxChars) {
        currentChunk = potentialChunk;
      } else {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk);
          currentChunk = word;
        } else {
          // Single word is too long, force split
          chunks.add(word.substring(0, maxChars));
          currentChunk = word.substring(maxChars);
        }
      }
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk);
    }

    return chunks;
  }

  /// Classifies errors for better handling
  TranslationError _classifyError(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    if (error is SocketException || errorMessage.contains('network') || errorMessage.contains('connection')) {
      return TranslationError(
        type: TranslationErrorType.networkError,
        message: 'Network connection failed',
        details: error.toString(),
        isRetryable: true,
        suggestedRetryDelay: const Duration(seconds: 5),
      );
    }

    if (errorMessage.contains('timeout')) {
      return TranslationError(
        type: TranslationErrorType.timeoutError,
        message: 'Request timed out',
        details: error.toString(),
        isRetryable: true,
        suggestedRetryDelay: const Duration(seconds: 10),
      );
    }

    if (errorMessage.contains('rate limit') || errorMessage.contains('429')) {
      return TranslationError(
        type: TranslationErrorType.rateLimitError,
        message: 'Rate limit exceeded',
        details: error.toString(),
        isRetryable: true,
        suggestedRetryDelay: const Duration(minutes: 1),
      );
    }

    if (errorMessage.contains('401') || errorMessage.contains('unauthorized') || errorMessage.contains('api key')) {
      return TranslationError(
        type: TranslationErrorType.authenticationError,
        message: 'Authentication failed - check API key',
        details: error.toString(),
        isRetryable: false,
      );
    }

    if (errorMessage.contains('quota') || errorMessage.contains('exceeded')) {
      return TranslationError(
        type: TranslationErrorType.quotaExceeded,
        message: 'API quota exceeded',
        details: error.toString(),
        isRetryable: false,
      );
    }

    if (errorMessage.contains('500') || errorMessage.contains('502') || errorMessage.contains('503')) {
      return TranslationError(
        type: TranslationErrorType.serverError,
        message: 'Server error - try again later',
        details: error.toString(),
        isRetryable: true,
        suggestedRetryDelay: const Duration(seconds: 30),
      );
    }

    return TranslationError(
      type: TranslationErrorType.unknown,
      message: 'Unknown error occurred',
      details: error.toString(),
      isRetryable: true,
    );
  }

  /// Makes API call with enhanced retry logic
  Future<TranslationResponse> _makeApiCallWithRetry(String prompt) async {
    print('[TranslationService] _makeApiCallWithRetry called');
    print('[TranslationService] Max retries: $_maxRetries');
    TranslationError? lastError;
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      print('[TranslationService] Attempt $attempt/$_maxRetries');
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

        final url = '$_baseUrl?key=$_apiKey';
        print('[TranslationService] Making POST request to: ${url.replaceAll(RegExp(r'key=.*'), 'key=***')}');
        print('[TranslationService] Request body size: ${json.encode(requestBody).length} bytes');

        final response = await _httpClient.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        ).timeout(_requestTimeout);

        print('[TranslationService] Response status code: ${response.statusCode}');
        if (response.statusCode != 200) {
          print('[TranslationService] Error response body: ${response.body}');
        }

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final translatedText = _extractTranslationFromResponse(responseData);
          
          return TranslationResponse(
            translatedText: translatedText,
            fromLanguage: '',
            toLanguage: '',
          );
        } else {
          final error = _classifyHttpError(response.statusCode, response.body);
          lastError = error;
          
          if (!error.isRetryable || attempt >= _maxRetries) {
            return TranslationResponse.error(error.message);
          }
          
          // Use suggested retry delay or exponential backoff
          final delay = error.suggestedRetryDelay ?? Duration(milliseconds: _retryDelayMs * (1 << (attempt - 1)));
          await Future.delayed(delay);
          continue;
        }
      } on SocketException catch (e) {
        lastError = TranslationError(
          type: TranslationErrorType.networkError,
          message: 'Network connection failed',
          details: e.toString(),
          isRetryable: true,
        );
        
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(milliseconds: _retryDelayMs * (1 << (attempt - 1))));
          continue;
        }
      } catch (e) {
        lastError = _classifyError(e);
        
        if (!lastError!.isRetryable || attempt >= _maxRetries) {
          return TranslationResponse.error(lastError!.message);
        }
        
        final delay = lastError!.suggestedRetryDelay ?? Duration(milliseconds: _retryDelayMs * (1 << (attempt - 1)));
        await Future.delayed(delay);
        continue;
      }
    }

    return TranslationResponse.error(
      lastError?.message ?? 'Translation failed after $_maxRetries attempts'
    );
  }

  /// Classifies HTTP errors for better handling
  TranslationError _classifyHttpError(int statusCode, String body) {
    switch (statusCode) {
      case 400:
        return TranslationError(
          type: TranslationErrorType.invalidInput,
          message: 'Invalid request format',
          details: body,
          isRetryable: false,
        );
      case 401:
        return TranslationError(
          type: TranslationErrorType.authenticationError,
          message: 'Authentication failed - check API key',
          details: body,
          isRetryable: false,
        );
      case 403:
        return TranslationError(
          type: TranslationErrorType.quotaExceeded,
          message: 'API quota exceeded or permission denied',
          details: body,
          isRetryable: false,
        );
      case 429:
        return TranslationError(
          type: TranslationErrorType.rateLimitError,
          message: 'Rate limit exceeded',
          details: body,
          isRetryable: true,
          suggestedRetryDelay: const Duration(minutes: 1),
        );
      case 500:
      case 502:
      case 503:
        return TranslationError(
          type: TranslationErrorType.serverError,
          message: 'Server error - please try again later',
          details: body,
          isRetryable: true,
          suggestedRetryDelay: const Duration(seconds: 30),
        );
      case 504:
        return TranslationError(
          type: TranslationErrorType.timeoutError,
          message: 'Server timeout',
          details: body,
          isRetryable: true,
          suggestedRetryDelay: const Duration(seconds: 10),
        );
      default:
        return TranslationError(
          type: TranslationErrorType.unknown,
          message: 'Unexpected error: HTTP $statusCode',
          details: body,
          isRetryable: statusCode >= 500,
        );
    }
  }

  /// Legacy method for backwards compatibility
  Future<TranslationResponse> _makeApiCall(String prompt) async {
    return _makeApiCallWithRetry(prompt);
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

  /// Get cache statistics for performance monitoring
  Map<String, dynamic> getCacheStats() {
    return _cacheService.getCacheStats();
  }

  /// Clear translation cache
  Future<void> clearCache() async {
    await _cacheService.clearCache();
  }

  /// Warm up cache with common translations
  Future<void> warmUpCache({
    required List<String> commonTexts,
    required String fromLanguage,
    required List<String> targetLanguages,
  }) async {
    final futures = <Future<void>>[];
    
    for (final text in commonTexts) {
      for (final targetLang in targetLanguages) {
        if (targetLang != fromLanguage) {
          futures.add(
            translateText(
              text: text,
              fromLanguage: fromLanguage,
              toLanguage: targetLang,
              useCache: true,
            ).then((_) {}),
          );
        }
      }
    }

    // Execute translations with limited concurrency to avoid rate limits
    const batchSize = 5;
    for (int i = 0; i < futures.length; i += batchSize) {
      final batch = futures.skip(i).take(batchSize);
      await Future.wait(batch);
      // Small delay between batches to respect rate limits
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Pre-translate content for better performance
  Future<void> preTranslateContent({
    required Map<String, String> content, // elementId -> text
    required String fromLanguage,
    required List<String> targetLanguages,
  }) async {
    final requests = <TranslationRequest>[];
    
    for (final entry in content.entries) {
      for (final targetLang in targetLanguages) {
        if (targetLang != fromLanguage) {
          requests.add(TranslationRequest(
            text: entry.value,
            fromLanguage: fromLanguage,
            toLanguage: targetLang,
            elementId: entry.key,
          ));
        }
      }
    }

    if (requests.isNotEmpty) {
      await translateBatch(requests);
    }
  }

  /// Check if text is already cached for all target languages
  bool isContentCached({
    required String text,
    required String fromLanguage,
    required List<String> targetLanguages,
  }) {
    for (final targetLang in targetLanguages) {
      if (targetLang != fromLanguage) {
        if (!_cacheService.isTranslationCached(
          text: text,
          fromLanguage: fromLanguage,
          toLanguage: targetLang,
        )) {
          return false;
        }
      }
    }
    return true;
  }

  /// Estimate translation time based on text length and cache status
  Duration estimateTranslationTime({
    required String text,
    required String fromLanguage,
    required List<String> targetLanguages,
  }) {
    const baseTimePerLanguage = Duration(seconds: 2);
    const cachedTime = Duration(milliseconds: 50);
    
    var totalTime = Duration.zero;
    
    for (final targetLang in targetLanguages) {
      if (targetLang != fromLanguage) {
        if (_cacheService.isTranslationCached(
          text: text,
          fromLanguage: fromLanguage,
          toLanguage: targetLang,
        )) {
          totalTime += cachedTime;
        } else {
          // Estimate based on text length
          final chunks = _chunkText(text, _maxCharactersPerRequest);
          totalTime += baseTimePerLanguage * chunks.length;
        }
      }
    }
    
    return totalTime;
  }

  /// Disposes resources
  void dispose() {
    _httpClient.close();
    _cacheService.dispose();
  }
}