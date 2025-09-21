import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/translation_service.dart';
import '../../../projects/models/project_model.dart';
import '../../../shared/providers/translation_provider.dart';
import '../../models/editor_state.dart';
import '../../models/text_models.dart';
import '../../providers/editor_provider.dart';

class TranslationModal extends ConsumerStatefulWidget {
  const TranslationModal({
    super.key,
    required this.project,
  });

  final ProjectModel project;

  @override
  ConsumerState<TranslationModal> createState() => _TranslationModalState();
}

class _TranslationModalState extends ConsumerState<TranslationModal> {
  Set<String> selectedLanguages = {};
  bool isTranslating = false;
  
  @override
  void initState() {
    super.initState();
    // By default, select all target languages
    selectedLanguages = widget.project.nonReferenceLanguages.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final editorProv = editorByProjectIdProvider(widget.project.id);
    final editorState = ref.watch(editorProv);
    final translationState = ref.watch(translationStateProvider(widget.project.id));

    final referenceLanguage = widget.project.effectiveReferenceLanguage;
    final targetLanguages = widget.project.nonReferenceLanguages;
    final totalElements = _countTotalTextElements(editorState);
    final estimatedTranslations = selectedLanguages.length * totalElements;

    // Check if translation is in progress
    isTranslating = translationState.hasActiveTranslations;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007BFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF007BFF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Translate All Content',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF495057),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Source: ${TranslationService.getLanguageDisplayName(referenceLanguage)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6C757D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isTranslating)
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        foregroundColor: const Color(0xFF6C757D),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Translation summary
                    _buildSummarySection(totalElements, estimatedTranslations),

                    const SizedBox(height: 24),

                    // Language selection
                    _buildLanguageSelection(targetLanguages),

                    const SizedBox(height: 24),

                    // Progress section (shown during translation)
                    if (isTranslating) ...[
                      _buildProgressSection(translationState),
                      const SizedBox(height: 24),
                    ],

                    // Action buttons
                    _buildActionButtons(context, estimatedTranslations),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(int totalElements, int estimatedTranslations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: const Color(0xFF007BFF),
              ),
              const SizedBox(width: 8),
              const Text(
                'Translation Summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF495057),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  icon: Icons.text_fields,
                  label: 'Text Elements',
                  value: '$totalElements',
                  description: 'Across all screens',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.translate,
                  label: 'Translations',
                  value: '$estimatedTranslations',
                  description: 'Will be created',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelection(List<String> targetLanguages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Target Languages',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF495057),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${selectedLanguages.length} selected)',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6C757D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Select all/none buttons
        Row(
          children: [
            TextButton.icon(
              onPressed: isTranslating ? null : () {
                setState(() {
                  selectedLanguages = targetLanguages.toSet();
                });
              },
              icon: const Icon(Icons.select_all, size: 16),
              label: const Text('Select All'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF007BFF),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: isTranslating ? null : () {
                setState(() {
                  selectedLanguages.clear();
                });
              },
              icon: const Icon(Icons.deselect, size: 16),
              label: const Text('Select None'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6C757D),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),

        // Language checkboxes
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE1E5E9)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: targetLanguages.map((languageCode) {
              final isSelected = selectedLanguages.contains(languageCode);
              final displayName = TranslationService.getLanguageDisplayName(languageCode);

              return CheckboxListTile(
                value: isSelected,
                onChanged: isTranslating ? null : (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedLanguages.add(languageCode);
                    } else {
                      selectedLanguages.remove(languageCode);
                    }
                  });
                },
                title: Row(
                  children: [
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
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                activeColor: const Color(0xFF007BFF),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(TranslationState translationState) {
    final progress = translationState.progress;
    final progressPercentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF1976D2)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Translation in Progress... $progressPercentage%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    Text(
                      '${translationState.completedElements} of ${translationState.totalElements} elements completed',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFBBDEFB),
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF1976D2)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, int estimatedTranslations) {
    final canTranslate = selectedLanguages.isNotEmpty && !isTranslating;

    return Row(
      children: [
        if (!isTranslating)
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6C757D),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        if (!isTranslating) const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canTranslate ? () => _startTranslation() : null,
            icon: isTranslating
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.auto_awesome, size: 18),
            label: Text(
              isTranslating ? 'Translating...' : 'Start Translation',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: canTranslate ? const Color(0xFF007BFF) : const Color(0xFF6C757D),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  int _countTotalTextElements(EditorState editorState) {
    int total = 0;
    for (final screen in editorState.screens) {
      total += screen.textConfig.visibleElementCount.toInt();
    }
    return total;
  }

  void _startTranslation() async {
    final editorProv = editorByProjectIdProvider(widget.project.id);
    final editorState = ref.read(editorProv);
    final translationNotifier = ref.read(translationNotifierProvider(widget.project.id).notifier);

    // Collect all text elements from all screens
    final allElements = <TextElement>[];
    for (final screen in editorState.screens) {
      allElements.addAll(screen.textConfig.visibleElements);
    }

    // Initialize translation state
    translationNotifier.initializeFromProject(widget.project);

    // Start translation for each selected language
    for (final targetLanguage in selectedLanguages) {
      await translationNotifier.translateBatch(
        elements: allElements,
        targetLanguage: targetLanguage,
        context: 'App store screenshot content',
      );
    }

    // Close modal after completion
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: const Color(0xFF007BFF),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF495057),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF495057),
          ),
        ),
        Text(
          description,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6C757D),
          ),
        ),
      ],
    );
  }
}