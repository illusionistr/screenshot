import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/translation_service.dart';
import '../../../providers/app_providers.dart';
import '../../editor/models/text_models.dart';
import '../../editor/providers/editor_provider.dart';
import '../../projects/models/project_model.dart';

part 'translation_provider.g.dart';

/// Status of translation operations
enum TranslationStatus {
  idle,
  pending,
  inProgress,
  completed,
  failed,
}

/// State for individual element translation
class ElementTranslationState {
  final String elementId;
  final TranslationStatus status;
  final String? error;
  final Map<String, String> translations; // language code -> translated text
  final DateTime? lastUpdated;

  const ElementTranslationState({
    required this.elementId,
    this.status = TranslationStatus.idle,
    this.error,
    this.translations = const {},
    this.lastUpdated,
  });

  ElementTranslationState copyWith({
    TranslationStatus? status,
    String? error,
    Map<String, String>? translations,
    DateTime? lastUpdated,
  }) {
    return ElementTranslationState(
      elementId: elementId,
      status: status ?? this.status,
      error: error,
      translations: translations ?? this.translations,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool hasTranslation(String languageCode) {
    return translations.containsKey(languageCode);
  }

  String? getTranslation(String languageCode) {
    return translations[languageCode];
  }
}

/// Overall translation state for a project
class TranslationState {
  final String projectId;
  final String? selectedReferenceLanguage;
  final Map<String, ElementTranslationState> elementStates;
  final bool isBatchTranslating;
  final List<String> pendingLanguages;
  final TranslationStatus batchStatus;
  final String? batchError;
  final int totalElements;
  final int completedElements;

  const TranslationState({
    required this.projectId,
    this.selectedReferenceLanguage,
    this.elementStates = const {},
    this.isBatchTranslating = false,
    this.pendingLanguages = const [],
    this.batchStatus = TranslationStatus.idle,
    this.batchError,
    this.totalElements = 0,
    this.completedElements = 0,
  });

  TranslationState copyWith({
    String? selectedReferenceLanguage,
    Map<String, ElementTranslationState>? elementStates,
    bool? isBatchTranslating,
    List<String>? pendingLanguages,
    TranslationStatus? batchStatus,
    String? batchError,
    int? totalElements,
    int? completedElements,
  }) {
    return TranslationState(
      projectId: projectId,
      selectedReferenceLanguage: selectedReferenceLanguage ?? this.selectedReferenceLanguage,
      elementStates: elementStates ?? this.elementStates,
      isBatchTranslating: isBatchTranslating ?? this.isBatchTranslating,
      pendingLanguages: pendingLanguages ?? this.pendingLanguages,
      batchStatus: batchStatus ?? this.batchStatus,
      batchError: batchError,
      totalElements: totalElements ?? this.totalElements,
      completedElements: completedElements ?? this.completedElements,
    );
  }

  double get progress {
    if (totalElements == 0) return 0.0;
    return completedElements / totalElements;
  }

  bool get hasActiveTranslations {
    return isBatchTranslating || 
           elementStates.values.any((state) => state.status == TranslationStatus.inProgress);
  }

  List<String> get availableTargetLanguages {
    return pendingLanguages.where((lang) => lang != selectedReferenceLanguage).toList();
  }
}

/// Provider for translation state management
@riverpod
class TranslationNotifier extends _$TranslationNotifier {
  @override
  TranslationState build(String projectId) {
    return TranslationState(projectId: projectId);
  }

  TranslationService get _translationService => ref.read(translationServiceProvider);

  /// Sets the reference language for the project
  void setReferenceLanguage(String languageCode) {
    state = state.copyWith(selectedReferenceLanguage: languageCode);
  }

  /// Initializes translation state from project data
  void initializeFromProject(ProjectModel project) {
    final referenceLanguage = project.effectiveReferenceLanguage;
    final pendingLanguages = project.supportedLanguages;
    
    // Initialize element states from existing text configurations
    final elementStates = <String, ElementTranslationState>{};
    
    for (final screenConfig in project.screenTextConfigs.values) {
      for (final element in screenConfig.allElements) {
        elementStates[element.id] = ElementTranslationState(
          elementId: element.id,
          translations: Map<String, String>.from(element.translations),
          status: TranslationStatus.idle,
          lastUpdated: DateTime.now(),
        );
      }
    }

    state = state.copyWith(
      selectedReferenceLanguage: referenceLanguage,
      pendingLanguages: pendingLanguages,
      elementStates: elementStates,
      totalElements: elementStates.length,
      completedElements: _countCompletedElements(elementStates, pendingLanguages),
    );
  }

  /// Translates a single text element to a target language
  Future<void> translateElement({
    required String elementId,
    required String text,
    required String targetLanguage,
    String? context,
  }) async {
    print('[TranslationNotifier] translateElement called');
    print('[TranslationNotifier] Element ID: $elementId');
    print('[TranslationNotifier] Text: "$text"');
    print('[TranslationNotifier] Target language: $targetLanguage');
    print('[TranslationNotifier] Context: $context');
    
    final referenceLanguage = state.selectedReferenceLanguage;
    print('[TranslationNotifier] Reference language: $referenceLanguage');
    
    if (referenceLanguage == null) {
      print('[TranslationNotifier] ERROR: No reference language set');
      throw Exception('No reference language set');
    }

    // Update element state to in-progress
    final currentElement = state.elementStates[elementId] ?? 
        ElementTranslationState(elementId: elementId);
    
    print('[TranslationNotifier] Current element state: ${currentElement.status}');
    print('[TranslationNotifier] Updating element state to in-progress');
    
    final updatedElements = Map<String, ElementTranslationState>.from(state.elementStates);
    updatedElements[elementId] = currentElement.copyWith(
      status: TranslationStatus.inProgress,
      error: null,
    );

    state = state.copyWith(elementStates: updatedElements);
    print('[TranslationNotifier] State updated - element $elementId is now in progress');

    try {
      print('[TranslationNotifier] Calling _translationService.translateText...');
      final response = await _translationService.translateText(
        text: text,
        fromLanguage: referenceLanguage,
        toLanguage: targetLanguage,
        context: context,
        elementId: elementId,
      );
      
      print('[TranslationNotifier] Translation service response received');
      print('[TranslationNotifier] Response success: ${response.success}');
      print('[TranslationNotifier] Response text: "${response.translatedText}"');
      print('[TranslationNotifier] Response error: ${response.error}');

      if (response.success) {
        print('[TranslationNotifier] Translation successful: "${response.translatedText}"');
        // Update with successful translation
        final updatedTranslations = Map<String, String>.from(currentElement.translations);
        updatedTranslations[targetLanguage] = response.translatedText;
        
        print('[TranslationNotifier] Updated translations for element $elementId: $updatedTranslations');

        final updatedElementsSuccess = Map<String, ElementTranslationState>.from(state.elementStates);
        updatedElementsSuccess[elementId] = currentElement.copyWith(
          status: TranslationStatus.completed,
          translations: updatedTranslations,
          lastUpdated: DateTime.now(),
        );

        state = state.copyWith(
          elementStates: updatedElementsSuccess,
          completedElements: _countCompletedElements(updatedElementsSuccess, state.pendingLanguages),
        );
        
        print('[TranslationNotifier] Element $elementId marked as completed');
        print('[TranslationNotifier] Total completed elements: ${state.completedElements}');
        
        // CRITICAL: Apply the translation to the editor state
        print('[TranslationNotifier] Applying translation to editor state...');
        try {
          final editorNotifier = ref.read(editorByProjectIdProvider(state.projectId).notifier);
          editorNotifier.applyTranslation(
            elementId: elementId,
            language: targetLanguage,
            translatedText: response.translatedText,
          );
          print('[TranslationNotifier] Translation applied to editor successfully');
        } catch (e) {
          print('[TranslationNotifier] ERROR applying translation to editor: $e');
        }
      } else {
        print('[TranslationNotifier] Translation failed: ${response.error}');
        // Update with error
        final updatedElementsError = Map<String, ElementTranslationState>.from(state.elementStates);
        updatedElementsError[elementId] = currentElement.copyWith(
          status: TranslationStatus.failed,
          error: response.error,
          lastUpdated: DateTime.now(),
        );

        state = state.copyWith(elementStates: updatedElementsError);
        print('[TranslationNotifier] Element $elementId marked as failed');
      }
    } catch (e) {
      print('[TranslationNotifier] Translation failed with exception: $e'); 
      print('[TranslationNotifier] Exception type: ${e.runtimeType}');
      // Update with exception error
      final updatedElementsException = Map<String, ElementTranslationState>.from(state.elementStates);
      updatedElementsException[elementId] = currentElement.copyWith(
        status: TranslationStatus.failed,
        error: e.toString(),
        lastUpdated: DateTime.now(),
      );

      state = state.copyWith(elementStates: updatedElementsException);
      print('[TranslationNotifier] Element $elementId marked as failed due to exception');
    }
  }

  /// Translates all elements to a target language in batch
  Future<void> translateBatch({
    required List<TextElement> elements,
    required String targetLanguage,
    String? context,
  }) async {
    final referenceLanguage = state.selectedReferenceLanguage;
    if (referenceLanguage == null) {
      throw Exception('No reference language set');
    }

    print('[TranslationNotifier] translateBatch called for language: $targetLanguage');
    print('[TranslationNotifier] Reference language: $referenceLanguage');
    print('[TranslationNotifier] Total elements to translate: ${elements.length}');

    // Start batch translation
    state = state.copyWith(
      isBatchTranslating: true,
      batchStatus: TranslationStatus.inProgress,
      batchError: null,
      totalElements: elements.length,
    );

    try {
      // Create translation requests with validation
      final requests = <TranslationRequest>[];
      final skippedElements = <String>[];

      for (final element in elements) {
        // Try multiple fallback strategies to get the source text
        String referenceText = element.getTranslation(referenceLanguage);

        // Fallback 1: Try using content getter (which has its own fallback logic)
        if (referenceText.trim().isEmpty) {
          referenceText = element.content;
          print('[TranslationNotifier] Element ${element.id}: Using content fallback');
        }

        // Fallback 2: Try any available translation
        if (referenceText.trim().isEmpty && element.translations.isNotEmpty) {
          referenceText = element.translations.values.first;
          print('[TranslationNotifier] Element ${element.id}: Using first available translation');
        }

        // Validate we have actual text to translate
        if (referenceText.trim().isEmpty) {
          print('[TranslationNotifier] WARNING: Skipping element ${element.id} - no translatable text found');
          print('[TranslationNotifier] Element translations map: ${element.translations}');
          skippedElements.add(element.id);
          continue;
        }

        print('[TranslationNotifier] Element ${element.id}: Text to translate: "$referenceText"');
        requests.add(TranslationRequest(
          text: referenceText,
          fromLanguage: referenceLanguage,
          toLanguage: targetLanguage,
          context: context,
          elementId: element.id,
        ));
      }

      print('[TranslationNotifier] Created ${requests.length} translation requests');
      print('[TranslationNotifier] Skipped ${skippedElements.length} elements: $skippedElements');

      // Execute batch translation
      print('[TranslationNotifier] Calling translation service with ${requests.length} requests...');
      final batchResponse = await _translationService.translateBatch(requests);

      print('[TranslationNotifier] Batch response received');
      print('[TranslationNotifier] Success count: ${batchResponse.successCount}');
      print('[TranslationNotifier] Error count: ${batchResponse.errorCount}');
      print('[TranslationNotifier] All successful: ${batchResponse.allSuccessful}');

      // Process results
      final updatedElements = Map<String, ElementTranslationState>.from(state.elementStates);

      int processedCount = 0;
      int successCount = 0;
      int failureCount = 0;

      for (final translation in batchResponse.translations) {
        final elementId = translation.elementId;
        processedCount++;

        if (elementId == null) {
          print('[TranslationNotifier] WARNING: Translation #$processedCount has no element ID');
          continue;
        }

        print('[TranslationNotifier] Processing translation for element: $elementId');

        final currentElement = updatedElements[elementId] ??
            ElementTranslationState(elementId: elementId);

        if (translation.success) {
          print('[TranslationNotifier] Translation SUCCESS for $elementId: "${translation.translatedText}"');
          successCount++;

          final updatedTranslations = Map<String, String>.from(currentElement.translations);
          updatedTranslations[targetLanguage] = translation.translatedText;

          updatedElements[elementId] = currentElement.copyWith(
            status: TranslationStatus.completed,
            translations: updatedTranslations,
            lastUpdated: DateTime.now(),
          );

          // Apply translation to editor state
          print('[TranslationNotifier] Applying batch translation to editor for element: $elementId');
          try {
            final editorNotifier = ref.read(editorByProjectIdProvider(state.projectId).notifier);
            editorNotifier.applyTranslation(
              elementId: elementId,
              language: targetLanguage,
              translatedText: translation.translatedText,
            );
            print('[TranslationNotifier] Batch translation applied to editor successfully for element: $elementId');
          } catch (e) {
            print('[TranslationNotifier] ERROR applying batch translation to editor for element $elementId: $e');
          }
        } else {
          print('[TranslationNotifier] Translation FAILED for $elementId: ${translation.error}');
          failureCount++;

          updatedElements[elementId] = currentElement.copyWith(
            status: TranslationStatus.failed,
            error: translation.error,
            lastUpdated: DateTime.now(),
          );
        }
      }

      print('[TranslationNotifier] Batch processing complete - Processed: $processedCount, Success: $successCount, Failed: $failureCount');

      // Update state with batch results
      state = state.copyWith(
        isBatchTranslating: false,
        batchStatus: batchResponse.allSuccessful ? TranslationStatus.completed : TranslationStatus.failed,
        batchError: batchResponse.allSuccessful ? null : 'Some translations failed',
        elementStates: updatedElements,
        completedElements: _countCompletedElements(updatedElements, state.pendingLanguages),
      );

    } catch (e, stackTrace) {
      print('[TranslationNotifier] ERROR during batch translation: $e');
      print('[TranslationNotifier] Stack trace: $stackTrace');
      state = state.copyWith(
        isBatchTranslating: false,
        batchStatus: TranslationStatus.failed,
        batchError: e.toString(),
      );
    }
  }

  /// Translates all elements to all target languages
  Future<void> translateAllLanguages(List<TextElement> elements) async {
    final targetLanguages = state.availableTargetLanguages;
    
    for (final language in targetLanguages) {
      if (state.batchStatus == TranslationStatus.failed) {
        break; // Stop if there's an error
      }
      
      await translateBatch(
        elements: elements,
        targetLanguage: language,
        context: 'App store screenshot text',
      );
    }
  }

  /// Clears translation error for an element
  void clearElementError(String elementId) {
    final currentElement = state.elementStates[elementId];
    if (currentElement == null) return;

    final updatedElements = Map<String, ElementTranslationState>.from(state.elementStates);
    updatedElements[elementId] = currentElement.copyWith(
      status: TranslationStatus.idle,
      error: null,
    );

    state = state.copyWith(elementStates: updatedElements);
  }

  /// Clears batch translation error
  void clearBatchError() {
    state = state.copyWith(
      batchStatus: TranslationStatus.idle,
      batchError: null,
    );
  }

  /// Resets all translation states
  void reset() {
    state = TranslationState(projectId: state.projectId);
  }

  /// Helper method to count completed elements
  int _countCompletedElements(
    Map<String, ElementTranslationState> elementStates,
    List<String> pendingLanguages,
  ) {
    int completed = 0;
    final targetLanguages = pendingLanguages.where((lang) => lang != state.selectedReferenceLanguage).toList();
    
    for (final elementState in elementStates.values) {
      bool elementCompleted = true;
      for (final language in targetLanguages) {
        if (!elementState.hasTranslation(language)) {
          elementCompleted = false;
          break;
        }
      }
      if (elementCompleted) completed++;
    }
    
    return completed;
  }
}

/// Helper providers for easy access
@riverpod
TranslationState translationState(Ref ref, String projectId) {
  return ref.watch(translationNotifierProvider(projectId));
}

@riverpod
bool hasActiveTranslations(Ref ref, String projectId) {
  return ref.watch(translationNotifierProvider(projectId).select((state) => state.hasActiveTranslations));
}

@riverpod
double translationProgress(Ref ref, String projectId) {
  return ref.watch(translationNotifierProvider(projectId).select((state) => state.progress));
}

@riverpod
List<String> availableTargetLanguages(Ref ref, String projectId) {
  return ref.watch(translationNotifierProvider(projectId).select((state) => state.availableTargetLanguages));
}