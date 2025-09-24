import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/translation_service.dart';
import '../../../projects/models/project_model.dart';
import '../../../shared/widgets/scrollable_tab_container.dart';
import '../../providers/editor_provider.dart';
import '../../models/text_models.dart';
import '../translation/reference_language_selector.dart';
import '../translation/translation_controls_panel.dart';
import '../translation/translation_progress_indicator.dart';
import 'text_content_editor.dart';
import 'text_element_selector.dart';
import 'text_formatting_panel.dart';

class TextTabContent extends ConsumerWidget {
  const TextTabContent({
    super.key,
    required this.project,
  });

  final ProjectModel project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorProv = editorByProjectIdProvider(project.id);
    final selectedType = ref.watch(
      editorProv.select((s) => s.textElementState.selectedType),
    );
    final currentLanguage = ref.watch(
      editorProv.select((s) => s.selectedLanguage),
    );
    final editorNotifier = ref.read(editorProv.notifier);

    final hasSelection = selectedType != null;

    return ScrollableTabContainer.unified(
      children: [
        // Translation Controls Section
        ReferenceLanguageSelector(project: project),

        const SizedBox(height: 10),

        TranslationControlsPanel(project: project),

        const SizedBox(height: 16),

        // Translation Progress Indicator
        TranslationProgressIndicator(project: project),

        const SizedBox(height: 16),

        // Divider
        Container(
          height: 1,
          color: const Color(0xFFE1E5E9),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),

        const SizedBox(height: 16),

        // Text Element Selector
        TextElementSelector(project: project),

        if (hasSelection) ...[
          const SizedBox(height: 16),

          // Content Editor
          TextContentEditor(project: project),

          const SizedBox(height: 16),

          // Formatting Panel
          TextFormattingPanel(project: project),

          const SizedBox(height: 16),

          // Apply to All Button
          _ApplyToAllButton(
            project: project,
            selectedType: selectedType,
            currentLanguage: currentLanguage,
            editorNotifier: editorNotifier,
          ),
        ] else ...[
          const SizedBox(height: 16),

          // Help text when no selection
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE1E5E9)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.text_fields,
                  size: 48,
                  color: Color(0xFF6C757D),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Add Text Overlays',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF495057),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select Title or Subtitle above to add text overlays to your screenshots. You can customize the content, font, size, and color for each element.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C757D),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Quick tips
                _FeatureTip(
                  icon: Icons.live_tv,
                  title: 'Real-time Preview',
                  description: 'See changes instantly on your screens',
                ),
                const SizedBox(height: 8),
                _FeatureTip(
                  icon: Icons.copy_all,
                  title: 'Apply to All',
                  description: 'Copy formatting across all screens',
                ),
                const SizedBox(height: 8),
                _FeatureTip(
                  icon: Icons.layers,
                  title: 'Per-screen Content',
                  description: 'Each screen has independent text content',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ApplyToAllButton extends StatelessWidget {
  const _ApplyToAllButton({
    required this.project,
    required this.selectedType,
    required this.currentLanguage,
    required this.editorNotifier,
  });

  final ProjectModel project;
  final TextFieldType? selectedType;
  final String currentLanguage;
  final EditorNotifier editorNotifier;

  @override
  Widget build(BuildContext context) {
    final currentSelectedType = selectedType;
    final currentEditingLanguage = currentLanguage;
    final isEditingReferenceLanguage =
        currentEditingLanguage == project.effectiveReferenceLanguage;

    final languageDisplayName =
        TranslationService.getLanguageDisplayName(currentEditingLanguage);
    final buttonText = isEditingReferenceLanguage
        ? editorNotifier.getApplyToAllButtonText()
        : 'Apply to All ($languageDisplayName)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (isEditingReferenceLanguage) {
                editorNotifier.applySelectedElementFormattingToAllScreens();
              } else {
                editorNotifier
                    .applySelectedElementFormattingToAllScreensForCurrentLanguage();
              }

              final message = isEditingReferenceLanguage
                  ? 'Applied ${currentSelectedType?.displayName.toLowerCase()} formatting to all screens'
                  : 'Applied ${currentSelectedType?.displayName.toLowerCase()} formatting and $languageDisplayName content to all screens';

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: const Color(0xFF28A745),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.copy_all, size: 18),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureTip extends StatelessWidget {
  const _FeatureTip({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFFE91E63),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6C757D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
