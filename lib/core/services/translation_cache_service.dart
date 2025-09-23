import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cached translation entry
class CachedTranslation {
  final String translatedText;
  final DateTime cachedAt;
  final String fromLanguage;
  final String toLanguage;

  const CachedTranslation({
    required this.translatedText,
    required this.cachedAt,
    required this.fromLanguage,
    required this.toLanguage,
  });

  Map<String, dynamic> toJson() {
    return {
      'translatedText': translatedText,
      'cachedAt': cachedAt.millisecondsSinceEpoch,
      'fromLanguage': fromLanguage,
      'toLanguage': toLanguage,
    };
  }

  factory CachedTranslation.fromJson(Map<String, dynamic> json) {
    return CachedTranslation(
      translatedText: json['translatedText'] as String,
      cachedAt: DateTime.fromMillisecondsSinceEpoch(json['cachedAt'] as int),
      fromLanguage: json['fromLanguage'] as String,
      toLanguage: json['toLanguage'] as String,
    );
  }

  /// Check if the cached translation is still valid
  bool isValid({Duration maxAge = const Duration(days: 30)}) {
    return DateTime.now().difference(cachedAt) <= maxAge;
  }
}

/// Service for caching translations to improve performance
class TranslationCacheService {
  static const String _cacheKeyPrefix = 'translation_cache_';
  static const String _cacheMetaKey = 'translation_cache_meta';
  static const int _maxCacheEntries = 1000;
  static const Duration _defaultCacheAge = Duration(days: 30);

  final Map<String, CachedTranslation> _memoryCache = {};
  SharedPreferences? _prefs;

  /// Initialize the cache service
  Future<void> initialize() async {
    print('[TranslationCacheService] Initializing cache service...');
    try {
      _prefs = await SharedPreferences.getInstance();
      print('[TranslationCacheService] SharedPreferences initialized');
      
      await _loadCacheFromDisk();
      print('[TranslationCacheService] Cache loaded from disk: ${_memoryCache.length} entries');
      
      await _cleanExpiredEntries();
      print('[TranslationCacheService] Expired entries cleaned, final count: ${_memoryCache.length}');
      
      print('[TranslationCacheService] Cache service initialization completed');
    } catch (e) {
      print('[TranslationCacheService] Cache initialization failed: $e');
      // Continue without cache functionality
    }
  }

  /// Generate cache key for a translation
  String _generateCacheKey(String text, String fromLanguage, String toLanguage) {
    final normalizedText = text.trim().toLowerCase();
    return '${normalizedText}_${fromLanguage}_$toLanguage'.hashCode.toString();
  }

  /// Get cached translation if available and valid
  CachedTranslation? getCachedTranslation({
    required String text,
    required String fromLanguage,
    required String toLanguage,
    Duration? maxAge,
  }) {
    final key = _generateCacheKey(text, fromLanguage, toLanguage);
    final cached = _memoryCache[key];
    
    if (cached != null && cached.isValid(maxAge: maxAge ?? _defaultCacheAge)) {
      return cached;
    }
    
    // Remove invalid cache entry
    if (cached != null) {
      _memoryCache.remove(key);
      _removeFromDisk(key);
    }
    
    return null;
  }

  /// Cache a translation
  Future<void> cacheTranslation({
    required String originalText,
    required String translatedText,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    final key = _generateCacheKey(originalText, fromLanguage, toLanguage);
    final cached = CachedTranslation(
      translatedText: translatedText,
      cachedAt: DateTime.now(),
      fromLanguage: fromLanguage,
      toLanguage: toLanguage,
    );

    // Store in memory cache
    _memoryCache[key] = cached;

    // Store on disk
    await _saveToDisk(key, cached);

    // Cleanup if cache is too large
    if (_memoryCache.length > _maxCacheEntries) {
      await _cleanupOldEntries();
    }
  }

  /// Batch cache multiple translations
  Future<void> batchCacheTranslations(Map<String, CachedTranslation> translations) async {
    for (final entry in translations.entries) {
      _memoryCache[entry.key] = entry.value;
      await _saveToDisk(entry.key, entry.value);
    }

    if (_memoryCache.length > _maxCacheEntries) {
      await _cleanupOldEntries();
    }
  }

  /// Check if translation is cached
  bool isTranslationCached({
    required String text,
    required String fromLanguage,
    required String toLanguage,
  }) {
    final cached = getCachedTranslation(
      text: text,
      fromLanguage: fromLanguage,
      toLanguage: toLanguage,
    );
    return cached != null;
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    var validEntries = 0;
    var expiredEntries = 0;

    for (final cached in _memoryCache.values) {
      if (cached.isValid()) {
        validEntries++;
      } else {
        expiredEntries++;
      }
    }

    return {
      'totalEntries': _memoryCache.length,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'cacheHitRate': _getCacheHitRate(),
      'lastCleanup': _getLastCleanup(),
    };
  }

  /// Clear all cached translations
  Future<void> clearCache() async {
    _memoryCache.clear();
    
    if (_prefs != null) {
      final keys = _prefs!.getKeys().where((key) => key.startsWith(_cacheKeyPrefix)).toList();
      for (final key in keys) {
        await _prefs!.remove(key);
      }
      await _prefs!.remove(_cacheMetaKey);
    }
  }

  /// Clear expired cache entries
  Future<void> clearExpiredEntries() async {
    await _cleanExpiredEntries();
  }

  /// Load cache from persistent storage
  Future<void> _loadCacheFromDisk() async {
    if (_prefs == null) return;

    final keys = _prefs!.getKeys().where((key) => key.startsWith(_cacheKeyPrefix)).toList();
    
    for (final fullKey in keys) {
      try {
        final jsonString = _prefs!.getString(fullKey);
        if (jsonString != null) {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final cached = CachedTranslation.fromJson(json);
          final cacheKey = fullKey.substring(_cacheKeyPrefix.length);
          _memoryCache[cacheKey] = cached;
        }
      } catch (e) {
        // Remove corrupted cache entry
        await _prefs!.remove(fullKey);
      }
    }
  }

  /// Save cache entry to disk
  Future<void> _saveToDisk(String key, CachedTranslation cached) async {
    if (_prefs == null) return;

    try {
      final jsonString = jsonEncode(cached.toJson());
      await _prefs!.setString('$_cacheKeyPrefix$key', jsonString);
    } catch (e) {
      // Ignore save errors - cache will work in memory only
    }
  }

  /// Remove cache entry from disk
  Future<void> _removeFromDisk(String key) async {
    if (_prefs == null) return;
    await _prefs!.remove('$_cacheKeyPrefix$key');
  }

  /// Clean expired entries from cache
  Future<void> _cleanExpiredEntries() async {
    final expiredKeys = <String>[];
    
    for (final entry in _memoryCache.entries) {
      if (!entry.value.isValid()) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      await _removeFromDisk(key);
    }
  }

  /// Clean up old entries when cache is too large
  Future<void> _cleanupOldEntries() async {
    if (_memoryCache.length <= _maxCacheEntries) return;

    // Sort by cache date and remove oldest entries
    final sortedEntries = _memoryCache.entries.toList()
      ..sort((a, b) => a.value.cachedAt.compareTo(b.value.cachedAt));

    final entriesToRemove = sortedEntries.take(_memoryCache.length - _maxCacheEntries);
    
    for (final entry in entriesToRemove) {
      _memoryCache.remove(entry.key);
      await _removeFromDisk(entry.key);
    }
  }

  /// Get cache hit rate (placeholder - would need actual tracking)
  double _getCacheHitRate() {
    // This would need to be tracked with actual hit/miss counters
    return 0.0;
  }

  /// Get last cleanup time (placeholder)
  DateTime? _getLastCleanup() {
    // This would need to be stored and tracked
    return null;
  }

  /// Dispose resources
  void dispose() {
    _memoryCache.clear();
  }
}