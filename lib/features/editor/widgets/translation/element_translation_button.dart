import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/translation_service.dart';
import '../../../projects/models/project_model.dart';
import '../../../shared/providers/translation_provider.dart';
import '../../models/text_models.dart';
import '../../providers/editor_provider.dart';
import 'target_language_dropdown.dart';

class ElementTranslationButton extends ConsumerWidget {
  const ElementTranslationButton({
    super.key,
    required this.project,
    required this.element,
    required this.elementType,
  });

  final ProjectModel project;
  final TextElement element;
  final TextFieldType elementType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(translationStateProvider(project.id));
    final translationNotifier = ref.read(translationNotifierProvider(project.id).notifier);

    // Check if this element is currently being translated
    final elementState = translationState.elementStates[element.id];
    final isTranslating = elementState?.status == TranslationStatus.inProgress;
    
    // Check requirements
    final hasReferenceLanguage = project.referenceLanguage != null;
    final targetLanguages = project.nonReferenceLanguages;
    final hasTargetLanguages = targetLanguages.isNotEmpty;
    final hasContent = element.content.trim().isNotEmpty;
    
    // Check if element has any translations
    final hasTranslations = element.availableLanguages.length > 1;

    // Button should be enabled if we have reference language, target languages, and content
    final isEnabled = hasReferenceLanguage && hasTargetLanguages && hasContent && !isTranslating;

    return PopupMenuButton<String>(
      enabled: isEnabled,
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isEnabled 
              ? const Color(0xFF007BFF).withOpacity(0.1)
              : const Color(0xFF6C757D).withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: isTranslating
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF007BFF),
                  ),
                ),
              )
            : Icon(
                Icons.translate,
                size: 14,
                color: isEnabled 
                    ? const Color(0xFF007BFF)
                    : const Color(0xFF6C757D),
              ),
      ),
      tooltip: isEnabled 
          ? 'Translate this ${elementType.displayName.toLowerCase()}'
          : _getTooltipText(hasReferenceLanguage, hasTargetLanguages, hasContent),
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      itemBuilder: (context) {
        if (!isEnabled) return [];

        return [
          // Header item (non-clickable)
          PopupMenuItem<String>(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Translate ${elementType.displayName}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF495057),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"${element.content.length > 30 ? '${element.content.substring(0, 30)}...' : element.content}"',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6C757D),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Divider(height: 16),
              ],
            ),
          ),

          // Individual language options
          ...targetLanguages.map((languageCode) {
            final hasTranslationForLang = element.hasTranslation(languageCode);
            final displayName = TranslationService.getLanguageDisplayName(languageCode);
            
            return PopupMenuItem<String>(
              value: languageCode,
              child: Row(
                children: [
                  // Language indicator
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: hasTranslationForLang
                          ? const Color(0xFF28A745).withOpacity(0.1)
                          : const Color(0xFF6C757D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Center(
                      child: Text(
                        languageCode.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: hasTranslationForLang
                              ? const Color(0xFF28A745)
                              : const Color(0xFF6C757D),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF495057),
                          ),
                        ),
                        Text(
                          hasTranslationForLang ? 'Update translation' : 'Create translation',
                          style: TextStyle(
                            fontSize: 11,
                            color: hasTranslationForLang
                                ? const Color(0xFF28A745)
                                : const Color(0xFF6C757D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasTranslationForLang)
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: const Color(0xFF28A745),
                    ),
                ],
              ),
            );
          }),

          // Divider before "Translate All" option
          const PopupMenuDivider(),

          // Translate to all languages option
          PopupMenuItem<String>(
            value: 'all',
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007BFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 12,
                    color: Color(0xFF007BFF),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Translate to All Languages',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF007BFF),
                        ),
                      ),
                      Text(
                        'Create translations for all target languages',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF007BFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ];
      },
      onSelected: (languageCode) {
        if (languageCode == 'all') {
          _translateToAllLanguages(ref, project, element);
          print('Translating to all languages');
        } else {
          _translateToLanguage(ref, project, element, languageCode);
          print('Translating to $languageCode');
        }
      },
    );
  }

  String _getTooltipText(bool hasReferenceLanguage, bool hasTargetLanguages, bool hasContent) {
    if (!hasReferenceLanguage) {
      return 'Select a source language first';
    }
    if (!hasTargetLanguages) {
      return 'Add target languages to your project';
    }
    if (!hasContent) {
      return 'Add content to this element first';
    }
    return 'Translation not available';
  }

  void _translateToLanguage(WidgetRef ref, ProjectModel project, TextElement element, String targetLanguage) {
    final translationNotifier = ref.read(translationNotifierProvider(project.id).notifier);
    final referenceLanguage = project.effectiveReferenceLanguage;
    final referenceText = element.getTranslation(referenceLanguage);

    translationNotifier.translateElement(
      elementId: element.id,
      text: referenceText,
      targetLanguage: targetLanguage,
      context: 'App store screenshot ${element.type.displayName.toLowerCase()}',
    );

    // Show feedback
    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(
        content: Text(
          'Translating ${element.type.displayName.toLowerCase()} to ${TranslationService.getLanguageDisplayName(targetLanguage)}...',
        ),
        backgroundColor: const Color(0xFF007BFF),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _translateToAllLanguages(WidgetRef ref, ProjectModel project, TextElement element) {
    final translationNotifier = ref.read(translationNotifierProvider(project.id).notifier);
    final targetLanguages = project.nonReferenceLanguages;

    // Translate to each target language
    for (final targetLanguage in targetLanguages) {
      final referenceLanguage = project.effectiveReferenceLanguage;
      final referenceText = element.getTranslation(referenceLanguage);

      translationNotifier.translateElement(
        elementId: element.id,
        text: referenceText,
        targetLanguage: targetLanguage,
        context: 'App store screenshot ${element.type.displayName.toLowerCase()}',
      );
    }

    // Show feedback
    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(
        content: Text(
          'Translating ${element.type.displayName.toLowerCase()} to ${targetLanguages.length} language${targetLanguages.length != 1 ? 's' : ''}...',
        ),
        backgroundColor: const Color(0xFF007BFF),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}