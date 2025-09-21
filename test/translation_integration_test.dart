import 'package:flutter_test/flutter_test.dart';
import 'package:screenshots/core/services/translation_service.dart';
import 'package:screenshots/features/editor/models/text_models.dart';
import 'package:screenshots/features/projects/models/project_model.dart';

void main() {
  group('Translation Integration Tests', () {
    test('TextElement supports multi-language translations', () {
      // Test the new multi-language TextElement structure
      final element = TextElement.withContent(
        id: 'test_element',
        type: TextFieldType.title,
        content: 'Hello World',
        languageCode: 'en',
      );

      // Test basic functionality
      expect(element.content, equals('Hello World'));
      expect(element.hasTranslation('en'), isTrue);
      expect(element.hasTranslation('es'), isFalse);
      expect(element.getTranslation('en'), equals('Hello World'));

      // Test adding translations
      final spanishElement = element.addTranslation('es', 'Hola Mundo');
      expect(spanishElement.hasTranslation('es'), isTrue);
      expect(spanishElement.getTranslation('es'), equals('Hola Mundo'));
      expect(spanishElement.availableLanguages, contains('en'));
      expect(spanishElement.availableLanguages, contains('es'));
      expect(spanishElement.availableLanguages.length, equals(2));
    });

    test('TextElement migration from legacy format', () {
      // Test migration from old single-content format
      final legacyJson = {
        'id': 'legacy_element',
        'type': 'title',
        'content': 'Legacy Content',
        'fontFamily': 'Inter',
        'fontSize': 24.0,
        'fontWeight': 5, // FontWeight.w600.index
        'textAlign': 1,
        'color': 0xFF000000,
        'isVisible': true,
      };

      final migratedElement = TextElement.fromJson(legacyJson);
      
      expect(migratedElement.content, equals('Legacy Content'));
      expect(migratedElement.hasTranslation('en'), isTrue);
      expect(migratedElement.getTranslation('en'), equals('Legacy Content'));
      expect(migratedElement.translations.length, equals(1));
    });

    test('TextElement serialization with new format', () {
      // Test new format serialization
      final element = TextElement(
        id: 'multi_lang_element',
        type: TextFieldType.subtitle,
        translations: {
          'en': 'Amazing Features',
          'es': 'Características Increíbles',
          'fr': 'Fonctionnalités Incroyables',
        },
      );

      final json = element.toJson();
      expect(json['translations'], isA<Map<String, String>>());
      expect(json['translations']['en'], equals('Amazing Features'));
      expect(json['translations']['es'], equals('Características Increíbles'));
      expect(json['translations']['fr'], equals('Fonctionnalités Incroyables'));

      // Test round-trip serialization
      final deserializedElement = TextElement.fromJson(json);
      expect(deserializedElement.translations, equals(element.translations));
      expect(deserializedElement.content, equals('Amazing Features')); // Should get 'en' as fallback
    });

    test('ProjectModel supports reference language', () {
      // Test ProjectModel with reference language
      final project = ProjectModel(
        id: 'test_project',
        userId: 'user123',
        appName: 'Test App',
        platforms: ['ios', 'android'],
        deviceIds: ['iphone-15-pro'],
        supportedLanguages: ['en', 'es', 'fr', 'de'],
        referenceLanguage: 'en',
        screenshots: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(project.effectiveReferenceLanguage, equals('en'));
      expect(project.isValidReferenceLanguage('en'), isTrue);
      expect(project.isValidReferenceLanguage('zh'), isFalse);
      expect(project.nonReferenceLanguages, equals(['es', 'fr', 'de']));
    });

    test('ProjectModel Firestore serialization includes reference language', () {
      final project = ProjectModel(
        id: 'test_project',
        userId: 'user123',
        appName: 'Test App',
        platforms: ['ios'],
        deviceIds: ['iphone-15-pro'],
        supportedLanguages: ['en', 'es'],
        referenceLanguage: 'en',
        screenshots: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final firestoreData = project.toFirestore();
      expect(firestoreData['referenceLanguage'], equals('en'));
      expect(firestoreData['supportedLanguages'], equals(['en', 'es']));
    });

    test('TranslationRequest and TranslationResponse models', () {
      // Test translation request model
      final request = TranslationRequest(
        text: 'Hello World',
        fromLanguage: 'en',
        toLanguage: 'es',
        context: 'App title',
        elementId: 'element123',
      );

      expect(request.text, equals('Hello World'));
      expect(request.fromLanguage, equals('en'));
      expect(request.toLanguage, equals('es'));

      // Test successful response
      final successResponse = TranslationResponse(
        translatedText: 'Hola Mundo',
        fromLanguage: 'en',
        toLanguage: 'es',
        elementId: 'element123',
      );

      expect(successResponse.success, isTrue);
      expect(successResponse.translatedText, equals('Hola Mundo'));
      expect(successResponse.error, isNull);

      // Test error response
      final errorResponse = TranslationResponse.error(
        'API error',
        fromLanguage: 'en',
        toLanguage: 'es',
        elementId: 'element123',
      );

      expect(errorResponse.success, isFalse);
      expect(errorResponse.error, equals('API error'));
      expect(errorResponse.translatedText, isEmpty);
    });

    test('Translation language support', () {
      // Test supported languages
      final supportedLanguages = TranslationService.getSupportedLanguages();
      expect(supportedLanguages, contains('en'));
      expect(supportedLanguages, contains('es'));
      expect(supportedLanguages, contains('fr'));
      expect(supportedLanguages, contains('de'));
      expect(supportedLanguages.length, greaterThan(20));

      // Test language validation
      expect(TranslationService.isLanguageSupported('en'), isTrue);
      expect(TranslationService.isLanguageSupported('es'), isTrue);
      expect(TranslationService.isLanguageSupported('xxx'), isFalse);

      // Test display names
      expect(TranslationService.getLanguageDisplayName('en'), equals('English'));
      expect(TranslationService.getLanguageDisplayName('es'), equals('Spanish'));
      expect(TranslationService.getLanguageDisplayName('fr'), equals('French'));
    });

    test('Batch translation response aggregation', () {
      final translations = [
        const TranslationResponse(
          translatedText: 'Hola',
          fromLanguage: 'en',
          toLanguage: 'es',
          elementId: '1',
        ),
        const TranslationResponse(
          translatedText: 'Mundo',
          fromLanguage: 'en',
          toLanguage: 'es',
          elementId: '2',
        ),
        TranslationResponse.error(
          'Translation failed',
          fromLanguage: 'en',
          toLanguage: 'es',
          elementId: '3',
        ),
      ];

      final batchResponse = BatchTranslationResponse.fromTranslations(translations);
      expect(batchResponse.successCount, equals(2));
      expect(batchResponse.errorCount, equals(1));
      expect(batchResponse.allSuccessful, isFalse);
      expect(batchResponse.translations.length, equals(3));
    });
  });

  group('Integration Scenarios', () {
    test('Complete workflow: Create element, add translations, serialize', () {
      // Create a new text element
      var element = TextElement.createDefault(TextFieldType.title);
      expect(element.content, equals('Title'));
      expect(element.hasTranslation('en'), isTrue);

      // Add Spanish translation
      element = element.addTranslation('es', 'Título');
      expect(element.getTranslation('es'), equals('Título'));

      // Add French translation
      element = element.addTranslation('fr', 'Titre');
      expect(element.getTranslation('fr'), equals('Titre'));

      // Serialize to JSON
      final json = element.toJson();
      expect(json['translations']['en'], equals('Title'));
      expect(json['translations']['es'], equals('Título'));
      expect(json['translations']['fr'], equals('Titre'));

      // Deserialize back
      final deserializedElement = TextElement.fromJson(json);
      expect(deserializedElement.translations, equals(element.translations));
      expect(deserializedElement.availableLanguages.length, equals(3));
    });

    test('Project with multi-language text elements', () {
      // Create text elements with translations
      final titleElement = TextElement.withContent(
        id: 'title1',
        type: TextFieldType.title,
        content: 'Amazing App',
      ).addTranslation('es', 'Aplicación Increíble');

      final subtitleElement = TextElement.withContent(
        id: 'subtitle1',
        type: TextFieldType.subtitle,
        content: 'Best features ever',
      ).addTranslation('es', 'Las mejores características');

      // Create screen config with these elements
      final screenConfig = ScreenTextConfig(
        elements: {
          TextFieldType.title: titleElement,
          TextFieldType.subtitle: subtitleElement,
        },
      );

      // Create project with reference language
      final project = ProjectModel(
        id: 'multilang_project',
        userId: 'user123',
        appName: 'Multi-Language App',
        platforms: ['ios'],
        deviceIds: ['iphone-15-pro'],
        supportedLanguages: ['en', 'es'],
        referenceLanguage: 'en',
        screenshots: {},
        screenTextConfigs: {'screen1': screenConfig},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Verify project structure
      expect(project.effectiveReferenceLanguage, equals('en'));
      expect(project.nonReferenceLanguages, equals(['es']));
      expect(project.hasTextConfigForScreen('screen1'), isTrue);
      
      final retrievedConfig = project.getScreenTextConfig('screen1')!;
      expect(retrievedConfig.hasElement(TextFieldType.title), isTrue);
      expect(retrievedConfig.hasElement(TextFieldType.subtitle), isTrue);
      
      final retrievedTitle = retrievedConfig.getElement(TextFieldType.title)!;
      expect(retrievedTitle.getTranslation('en'), equals('Amazing App'));
      expect(retrievedTitle.getTranslation('es'), equals('Aplicación Increíble'));
    });
  });
}