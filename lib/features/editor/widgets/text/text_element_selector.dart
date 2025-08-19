import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/text_models.dart';
import '../../models/editor_state.dart';
import '../../providers/editor_provider.dart';
import '../../../projects/models/project_model.dart';

class TextElementSelector extends ConsumerWidget {
  const TextElementSelector({
    super.key,
    required this.project,
  });

  final ProjectModel project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProviderFamily(project));
    final editorNotifier = ref.read(editorProviderFamily(project).notifier);
    
    final currentScreenTextConfig = editorNotifier.getCurrentScreenTextConfig();
    final selectedType = editorState.textElementState.selectedType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Text Elements',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF495057),
          ),
        ),
        const SizedBox(height: 12),
        ...TextFieldType.values.map((type) {
          final hasElement = currentScreenTextConfig?.hasElement(type) ?? false;
          final isSelected = selectedType == type;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TextElementOption(
              type: type,
              hasElement: hasElement,
              isSelected: isSelected,
              onSelect: () => editorNotifier.selectTextElement(type),
              onRemove: hasElement 
                ? () => editorNotifier.removeTextElement(type)
                : null,
            ),
          );
        }),
      ],
    );
  }
}

class _TextElementOption extends StatelessWidget {
  const _TextElementOption({
    required this.type,
    required this.hasElement,
    required this.isSelected,
    required this.onSelect,
    this.onRemove,
  });

  final TextFieldType type;
  final bool hasElement;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected 
            ? const Color(0xFFE91E63)
            : const Color(0xFFE1E5E9),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Radio button indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected 
                      ? const Color(0xFFE91E63)
                      : const Color(0xFF6C757D),
                    width: 2,
                  ),
                  color: isSelected 
                    ? const Color(0xFFE91E63)
                    : Colors.transparent,
                ),
                child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    )
                  : null,
              ),
              const SizedBox(width: 12),
              
              // Element info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          type.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected 
                              ? const Color(0xFFE91E63)
                              : const Color(0xFF495057),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (hasElement)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF28A745),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C757D),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Create',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasElement 
                        ? 'Click to edit'
                        : 'Click to create',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Remove button
              if (onRemove != null)
                InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}