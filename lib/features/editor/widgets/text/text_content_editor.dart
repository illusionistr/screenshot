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
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Live Preview',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE1E5E9)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedType == TextFieldType.title 
                        ? Icons.title 
                        : Icons.subtitles,
                      size: 16,
                      color: const Color(0xFFE91E63),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_controller.text.length} characters',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                    const Spacer(),
                    if (selectedType == TextFieldType.title)
                      const Text(
                        'Displayed at top',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C757D),
                        ),
                      )
                    else
                      const Text(
                        'Displayed at bottom',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Quick actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _controller.clear();
                  editorNotifier.updateTextContent(selectedType, '');
                },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6C757D),
                  side: const BorderSide(color: Color(0xFFE1E5E9)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  final defaultText = selectedType.displayName;
                  _controller.text = defaultText;
                  editorNotifier.updateTextContent(selectedType, defaultText);
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6C757D),
                  side: const BorderSide(color: Color(0xFFE1E5E9)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}