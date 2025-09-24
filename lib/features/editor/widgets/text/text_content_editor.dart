import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/rtl_service.dart';
import '../../../../core/services/translation_service.dart';
import '../../models/text_models.dart';
import '../../models/editor_state.dart';
import '../../providers/editor_provider.dart';
import '../../../projects/models/project_model.dart';
import '../translation/element_translation_button.dart';

class TextContentEditor extends ConsumerStatefulWidget {
  const TextContentEditor({
    super.key,
    required this.project,
  });

  final ProjectModel project;

  @override
  ConsumerState<TextContentEditor> createState() => _TextContentEditorState();
}

class _TextContentEditorState extends ConsumerState<TextContentEditor> {
  final TextEditingController _controller = TextEditingController();
  TextFieldType? _lastSelectedType;
  String? _lastEditingLanguage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateControllerFromState(EditorState editorState, EditorNotifier editorNotifier) {
    final selectedType = editorState.textElementState.selectedType;
    final currentEditingLanguage = editorState.selectedLanguage;

    // Update controller if selection changed OR editing language changed
    if (selectedType != _lastSelectedType || currentEditingLanguage != _lastEditingLanguage) {
      final currentElement = editorNotifier.getCurrentSelectedTextElement();
      if (currentElement != null) {
        // Get content in the current editing language
        _controller.text = currentElement.getTranslation(currentEditingLanguage);
      } else {
        _controller.text = '';
      }
      _lastSelectedType = selectedType;
      _lastEditingLanguage = currentEditingLanguage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorProv = editorByProjectIdProvider(widget.project.id);
    final editorNotifier = ref.read(editorProv.notifier);
    // Watch both selected type and current editing language
    final selectedType = ref.watch(editorProv.select((s) => s.textElementState.selectedType));
    final currentEditingLanguage = ref.watch(editorProv.select((s) => s.selectedLanguage));
    final currentElement = editorNotifier.getCurrentSelectedTextElement();

    // Update controller text when selection or language changes
    _updateControllerFromState(ref.read(editorProv), editorNotifier);

    if (selectedType == null || currentElement == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE1E5E9)),
        ),
        child: const Center(
          child: Text(
            'Select a text element to edit its content',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6C757D),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${selectedType.displayName} Content',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF495057),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Language indicator badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: currentEditingLanguage == widget.project.effectiveReferenceLanguage
                              ? const Color(0xFF007BFF).withOpacity(0.1)
                              : const Color(0xFFE91E63).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: currentEditingLanguage == widget.project.effectiveReferenceLanguage
                                ? const Color(0xFF007BFF).withOpacity(0.3)
                                : const Color(0xFFE91E63).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          currentEditingLanguage.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: currentEditingLanguage == widget.project.effectiveReferenceLanguage
                                ? const Color(0xFF007BFF)
                                : const Color(0xFFE91E63),
                          ),
                        ),
                      ),
                    ],
                  ),
                 
                ],
              ),
            ),
            ElementTranslationButton(
              project: widget.project,
              element: currentElement,
              elementType: selectedType,
            ),
          ],
        ),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE1E5E9)),
          ),
          child: Column(
            children: [
              Directionality(
                textDirection: RTLService.getTextDirection(currentEditingLanguage),
                child: TextField(
                  controller: _controller,
                  maxLines: 2,//selectedType == TextFieldType.title ? 2 : 1,
                  textAlign: RTLService.getStartAlign(currentEditingLanguage),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    hintText: 'Enter your ${selectedType.displayName.toLowerCase()}...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF6C757D),
                      fontSize: 14,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF495057),
                  ),
                  onChanged: (value) {
                    // Update content for the current editing language
                    editorNotifier.updateTextContentForLanguage(selectedType, currentEditingLanguage, value);
                  },
                ),
              ),
              
            ],
          ),
        ),
        const SizedBox(height: 12),
        
       
      ],
    );
  }
}
