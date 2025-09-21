import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/translation_service.dart';
import '../../../projects/models/project_model.dart';
import '../../../shared/providers/translation_provider.dart';
import '../../models/editor_state.dart';
import '../../providers/editor_provider.dart';
import 'translation_modal.dart';

class TranslationControlsPanel extends ConsumerWidget {
  const TranslationControlsPanel({
    super.key,
    required this.project,
  });

  final ProjectModel project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorProv = editorByProjectIdProvider(project.id);
    final editorState = ref.watch(editorProv);
    final editorNotifier = ref.read(editorProv.notifier);

    final translationState = ref.watch(translationStateProvider(project.id));
    final translationNotifier = ref.read(translationNotifierProvider(project.id).notifier);

    // Check if we have a reference language and any text elements
    final hasReferenceLanguage = project.referenceLanguage != null;
    final totalTextElements = _countTotalTextElements(editorState);
    final targetLanguages = project.nonReferenceLanguages;
    final hasTargetLanguages = targetLanguages.isNotEmpty;
    
    // Check if translation is currently in progress
    final isTranslating = translationState.hasActiveTranslations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.translate,
              size: 16,
              color: const Color(0xFF495057),
            ),
            const SizedBox(width: 8),
            const Text(
              'Translate All Content',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF495057),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Main translate button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: hasReferenceLanguage && hasTargetLanguages && totalTextElements > 0 && !isTranslating
                ? () => _openTranslationModal(context, ref, project)
                : null,
            icon: isTranslating
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    Icons.auto_awesome,
                    size: 18,
                  ),
            label: Text(
              isTranslating ? 'Translating...' : 'Translate All',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasReferenceLanguage && hasTargetLanguages && totalTextElements > 0 && !isTranslating
                  ? const Color(0xFF007BFF)
                  : const Color(0xFF6C757D),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Status and info section
        _buildStatusSection(
          hasReferenceLanguage: hasReferenceLanguage,
          hasTargetLanguages: hasTargetLanguages,
          totalTextElements: totalTextElements,
          targetLanguages: targetLanguages,
          isTranslating: isTranslating,
          translationState: translationState,
        ),
      ],
    );
  }

  Widget _buildStatusSection({
    required bool hasReferenceLanguage,
    required bool hasTargetLanguages,
    required int totalTextElements,
    required List<String> targetLanguages,
    required bool isTranslating,
    required TranslationState translationState,
  }) {
    // If everything is ready and not translating, show ready state
    if (hasReferenceLanguage && hasTargetLanguages && totalTextElements > 0 && !isTranslating) {
      return _buildReadyState(totalTextElements, targetLanguages);
    }

    // If translating, show progress
    if (isTranslating) {
      return _buildProgressState(translationState);
    }

    // Show requirements that need to be met
    return _buildRequirementsState(
      hasReferenceLanguage: hasReferenceLanguage,
      hasTargetLanguages: hasTargetLanguages,
      totalTextElements: totalTextElements,
    );
  }

  Widget _buildReadyState(int totalTextElements, List<String> targetLanguages) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4EDDA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFC3E6CB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: const Color(0xFF155724),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ready to translate',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF155724),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• $totalTextElements text element${totalTextElements != 1 ? 's' : ''} across all screens\n'
            '• ${targetLanguages.length} target language${targetLanguages.length != 1 ? 's' : ''}: ${targetLanguages.map((code) => TranslationService.getLanguageDisplayName(code)).join(', ')}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF155724),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressState(TranslationState translationState) {
    final progress = translationState.progress;
    final progressPercentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF1976D2)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Translating... $progressPercentage%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFBBDEFB),
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF1976D2)),
          ),
          const SizedBox(height: 8),
          Text(
            '${translationState.completedElements} of ${translationState.totalElements} elements translated',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1976D2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsState({
    required bool hasReferenceLanguage,
    required bool hasTargetLanguages,
    required int totalTextElements,
  }) {
    final requirements = <String>[];
    
    if (!hasReferenceLanguage) {
      requirements.add('Select a source language above');
    }
    if (!hasTargetLanguages) {
      requirements.add('Add target languages to your project');
    }
    if (totalTextElements == 0) {
      requirements.add('Add text elements to your screens');
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: const Color(0xFF6C757D),
              ),
              const SizedBox(width: 8),
              const Text(
                'Requirements for translation:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C757D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...requirements.map((requirement) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '• $requirement',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6C757D),
                height: 1.3,
              ),
            ),
          )),
        ],
      ),
    );
  }

  int _countTotalTextElements(EditorState editorState) {
    int total = 0;
    for (final screen in editorState.screens) {
      total += screen.textConfig.visibleElementCount.toInt();
    }
    return total;
  }

  void _openTranslationModal(BuildContext context, WidgetRef ref, ProjectModel project) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during translation
      builder: (context) => TranslationModal(project: project),
    );
  }
}