import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/translation_service.dart';
import '../../../../providers/app_providers.dart';
import '../../../projects/models/project_model.dart';
import '../../../projects/providers/project_provider.dart';
import '../../../shared/models/language_model.dart';
import '../../../shared/services/language_service.dart';
import '../../providers/editor_provider.dart';

class ReferenceLanguageSelector extends ConsumerWidget {
  const ReferenceLanguageSelector({
    super.key,
    required this.project,
  });

  final ProjectModel project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorProv = editorByProjectIdProvider(project.id);
    final editorNotifier = ref.read(editorProv.notifier);
    
    // Use project's effective reference language
    final selectedLanguage = project.effectiveReferenceLanguage;
    final availableLanguages = project.supportedLanguages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.translate,
              size: 16,
              color: const Color(0xFF495057),
            ),
            const SizedBox(width: 8),
            const Text(
              'Source Language',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF495057),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'The language that will be used as the source for translations',
              child: Icon(
                Icons.info_outline,
                size: 14,
                color: const Color(0xFF6C757D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE1E5E9)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedLanguage,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF6C757D),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF495057),
              ),
              items: availableLanguages.map((languageCode) {
                final languageModel = LanguageService.getLanguageByCode(languageCode);
                final displayName = languageModel?.name ?? 
                    TranslationService.getLanguageDisplayName(languageCode);
                
                return DropdownMenuItem<String>(
                  value: languageCode,
                  child: Row(
                    children: [
                      // Language flag or icon
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            languageCode.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE91E63),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF495057),
                              ),
                            ),
                            if (languageCode == selectedLanguage)
                              Text(
                                'Current source',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFFE91E63),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newLanguage) {
                if (newLanguage != null && newLanguage != selectedLanguage) {
                  _updateReferenceLanguage(
                    context, 
                    ref, 
                    project, 
                    editorNotifier,
                    newLanguage,
                  );
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Info text
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE1E5E9)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: const Color(0xFF6C757D),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Text in this language will be used as the source for all translations. Make sure your content is finalized before translating.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6C757D),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateReferenceLanguage(
    BuildContext context,
    WidgetRef ref,
    ProjectModel project,
    EditorNotifier editorNotifier,
    String newLanguage,
  ) {
    // Show confirmation dialog if there are existing translations
    final hasExistingTranslations = _checkForExistingTranslations(project);
    
    if (hasExistingTranslations) {
      showDialog(
        context: context,
        builder: (context) => _ReferenceLanguageChangeDialog(
          currentLanguage: project.effectiveReferenceLanguage,
          newLanguage: newLanguage,
          onConfirm: () {
            _performLanguageChange(ref, project, newLanguage);
            Navigator.of(context).pop();
          },
        ),
      );
    } else {
      _performLanguageChange(ref, project, newLanguage);
    }
  }

  bool _checkForExistingTranslations(ProjectModel project) {
    // Check if any text elements have translations in multiple languages
    for (final screenConfig in project.screenTextConfigs.values) {
      for (final element in screenConfig.allElements) {
        if (element.availableLanguages.length > 1) {
          return true;
        }
      }
    }
    return false;
  }

  void _performLanguageChange(WidgetRef ref, ProjectModel project, String newLanguage) async {
    try {
      // Update project reference language
      final projectService = ref.read(projectServiceProvider);
      final updatedProject = project.updateReferenceLanguage(newLanguage);
      await projectService.updateProject(updatedProject);
      
      // Invalidate projects stream to refresh data
      ref.invalidate(projectsStreamProvider);
      
      // Show success feedback
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Source language updated to ${TranslationService.getLanguageDisplayName(newLanguage)}',
              ),
            ],
          ),
          backgroundColor: const Color(0xFF28A745),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      // Show error feedback
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text('Failed to update source language: ${e.toString()}'),
            ],
          ),
          backgroundColor: const Color(0xFFDC3545),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}

class _ReferenceLanguageChangeDialog extends StatelessWidget {
  const _ReferenceLanguageChangeDialog({
    required this.currentLanguage,
    required this.newLanguage,
    required this.onConfirm,
  });

  final String currentLanguage;
  final String newLanguage;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final currentDisplayName = TranslationService.getLanguageDisplayName(currentLanguage);
    final newDisplayName = TranslationService.getLanguageDisplayName(newLanguage);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: const Color(0xFFF57C00),
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Change Source Language?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are changing the source language from $currentDisplayName to $newDisplayName.',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF495057),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFFE69C)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: const Color(0xFF856404),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Important:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF856404),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Existing translations will remain but may become inconsistent\n'
                  '• New translations will be based on the new source language\n'
                  '• Consider retranslating all content for consistency',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF856404),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF6C757D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF57C00),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text(
            'Change Language',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}