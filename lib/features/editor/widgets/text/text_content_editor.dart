import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/text_models.dart';
import '../../models/editor_state.dart';
import '../../providers/editor_provider.dart';
import '../../../projects/models/project_model.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateControllerFromState(EditorState editorState, EditorNotifier editorNotifier) {
    final selectedType = editorState.textElementState.selectedType;
    
    // Only update controller if selection has changed
    if (selectedType != _lastSelectedType) {
      final currentElement = editorNotifier.getCurrentSelectedTextElement();
      _controller.text = currentElement?.content ?? '';
      _lastSelectedType = selectedType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProviderFamily(widget.project));
    final editorNotifier = ref.read(editorProviderFamily(widget.project).notifier);
    
    final selectedType = editorState.textElementState.selectedType;
    final currentElement = editorNotifier.getCurrentSelectedTextElement();

    // Update controller text when selection changes
    _updateControllerFromState(editorState, editorNotifier);

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
            Text(
              '${selectedType.displayName} Content',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF495057),
              ),
            ),
            const SizedBox(width: 8),
           
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE1E5E9)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                maxLines: selectedType == TextFieldType.title ? 3 : 2,
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
                  editorNotifier.updateTextContent(selectedType, value);
                },
              ),
              
            ],
          ),
        ),
        const SizedBox(height: 12),
        
       
      ],
    );
  }
}