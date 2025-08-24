import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../projects/models/project_model.dart';
import '../../models/text_models.dart';
import '../../providers/editor_provider.dart';
import '../background/color_picker_dialog.dart';

class UnifiedTextEditor extends ConsumerStatefulWidget {
  const UnifiedTextEditor({
    super.key,
    required this.project,
  });

  final ProjectModel project;

  @override
  ConsumerState<UnifiedTextEditor> createState() => _UnifiedTextEditorState();
}

class _UnifiedTextEditorState extends ConsumerState<UnifiedTextEditor> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  final GlobalKey _colorPickerButtonKey = GlobalKey();
  TextSelection? _currentSelection;
  // Always in rich text mode now - no need for mode switching

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();

    // Listen to text changes, cursor position, and selection changes
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    _initializeText();
  }

  void _initializeText() {
    final editorNotifier =
        ref.read(editorProviderFamily(widget.project).notifier);
    final currentElement = editorNotifier.getCurrentSelectedTextElement();

    if (currentElement != null) {
      // Always use rich text mode - convert simple text to rich text if needed
      if (currentElement.isRichText && currentElement.segments != null) {
        // Convert segments back to plain text for editing
        _textController.text =
            currentElement.segments!.map((segment) => segment.text).join();
      } else {
        // Convert simple text to rich text
        _textController.text = currentElement.content;
        // Will be converted to rich text when user starts formatting
      }
    }
  }

  void _onTextChanged() {
    // Update selection immediately when text changes
    _updateSelection();
  }

  void _onFocusChanged() {
    // Focus change handling can be added later if needed
  }

  void _updateSelection() {
    final newSelection = _textController.selection;
    if (newSelection != _currentSelection) {
      setState(() {
        _currentSelection = newSelection;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProviderFamily(widget.project));
    final editorNotifier =
        ref.read(editorProviderFamily(widget.project).notifier);
    final selectedType = editorState.textElementState.selectedType;
    final currentElement = editorNotifier.getCurrentSelectedTextElement();

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
        // Header with element type
        Text(
          '${selectedType.displayName} Content',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF495057),
          ),
        ),
        const SizedBox(height: 12),

        // Integrated formatting toolbar
        _buildFormattingToolbar(currentElement, editorNotifier, selectedType),

        const SizedBox(height: 12),

        // Font controls section
        _buildFontControls(currentElement, editorNotifier, selectedType),

        const SizedBox(height: 8),

        // Advanced text input with selection support
        _buildAdvancedTextField(selectedType, editorNotifier),
      ],
    );
  }

  Widget _buildAdvancedTextField(
      TextFieldType selectedType, EditorNotifier editorNotifier) {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      maxLines: selectedType == TextFieldType.title ? 3 : 2,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE1E5E9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE91E63)),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintText: 'Enter your ${selectedType.displayName.toLowerCase()}...',
        hintStyle: const TextStyle(
          color: Color(0xFF6C757D),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF495057),
      ),
      onChanged: (value) {
        // Update the text content
        editorNotifier.updateTextContent(selectedType, value);
        _updateSelection();
      },
    );
  }

  Widget _buildFormattingToolbar(
    TextElement currentElement,
    EditorNotifier editorNotifier,
    TextFieldType selectedType,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: Row(
        children: [
          // Basic formatting buttons
          _ToolbarButton(
            icon: Icons.format_bold,
            onPressed: () =>
                _applyFormatting(selectedType, editorNotifier, 'bold'),
            tooltip: 'Bold',
          ),
          _ToolbarButton(
            icon: Icons.format_italic,
            onPressed: () =>
                _applyFormatting(selectedType, editorNotifier, 'italic'),
            tooltip: 'Italic',
          ),
          _ToolbarButton(
            icon: Icons.format_underline,
            onPressed: () =>
                _applyFormatting(selectedType, editorNotifier, 'underline'),
            tooltip: 'Underline',
          ),

          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 20,
            color: const Color(0xFFE1E5E9),
          ),
          const SizedBox(width: 8),

          // Color picker
          _ColorPickerButton(
            currentColor: currentElement.color,
            buttonKey: _colorPickerButtonKey,
            onColorChanged: (color) {
              _applyColorToSelection(selectedType, editorNotifier, color);
            },
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFontControls(TextElement currentElement,
      EditorNotifier editorNotifier, TextFieldType selectedType) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: Row(
        children: [
          // Font family dropdown - takes more space
          Expanded(
            flex: 4,
            child: _FontFamilyDropdown(
              currentFont: currentElement.fontFamily,
              onFontChanged: (font) {
                // If element is rich text, apply to segments, otherwise update simple text
                if (currentElement.isRichText) {
                  editorNotifier.applyRichTextFormatting(
                    selectedType,
                    (segment) => segment.copyWith(fontFamily: font),
                  );
                } else {
                  editorNotifier.updateTextFormatting(
                    type: selectedType,
                    fontFamily: font,
                  );
                }
              },
            ),
          ),
          const SizedBox(width: 8), // Reduced spacing
          // Font size dropdown - takes less space
          Expanded(
            flex: 2,
            child: _FontSizeButton(
              currentSize: currentElement.fontSize,
              onSizeChanged: (size) {
                // Apply font size to rich text
                if (!currentElement.isRichText) {
                  editorNotifier.convertToRichText(selectedType);
                }
                editorNotifier.applyRichTextFormatting(
                  selectedType,
                  (segment) => segment.copyWith(fontSize: size),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _applyFormatting(TextFieldType selectedType,
      EditorNotifier editorNotifier, String format) {
    // Get the current element
    final currentElement = editorNotifier.getCurrentSelectedTextElement();

    if (currentElement == null) return;

    // Check if there's a valid text selection
    if (_currentSelection != null &&
        _currentSelection!.start != _currentSelection!.end &&
        _currentSelection!.start >= 0 &&
        _currentSelection!.end <= _textController.text.length) {
      // Apply formatting to selected text only
      _applyFormattingToSelection(selectedType, editorNotifier, format);
    } else {
      // No selection or invalid selection - apply to entire text
      _applyFormattingToAll(selectedType, editorNotifier, format);
    }
  }

  void _applyFormattingToSelection(TextFieldType selectedType,
      EditorNotifier editorNotifier, String format) {
    final fullText = _textController.text;
    final selection = _currentSelection!;

    print('DEBUG: Applying $format to selection: $selection');
    print('DEBUG: Full text: "$fullText"');
    print(
        'DEBUG: Selection text: "${fullText.substring(selection.start, selection.end)}"');

    // Get current element and ensure it's in rich text mode
    final currentElement = editorNotifier.getCurrentSelectedTextElement()!;
    if (!currentElement.isRichText) {
      editorNotifier.convertToRichText(selectedType);
    }

    // Get the updated element after potential conversion
    final updatedElement = editorNotifier.getCurrentSelectedTextElement()!;
    final existingSegments = updatedElement.segments ?? [];

    print('DEBUG: Current element isRichText: ${currentElement.isRichText}');
    print('DEBUG: Updated element isRichText: ${updatedElement.isRichText}');
    print('DEBUG: Existing segments count: ${existingSegments.length}');

    for (int i = 0; i < existingSegments.length; i++) {
      print(
          'DEBUG: Segment $i: "${existingSegments[i].text}" (length: ${existingSegments[i].text.length})');
    }

    // If no segments exist, create them from scratch
    if (existingSegments.isEmpty) {
      print('DEBUG: No segments exist, creating new ones');
      _createNewSegmentsWithFormatting(
          selectedType, editorNotifier, format, fullText, selection);
      return;
    }

    // Find all segments that the selection overlaps with
    final overlappingSegments = <int>[];
    int cumulativeLength = 0;

    print('DEBUG: Finding all overlapping segments...');
    for (int i = 0; i < existingSegments.length; i++) {
      final segment = existingSegments[i];
      final segmentStart = cumulativeLength;
      final segmentEnd = cumulativeLength + segment.text.length;

      print('DEBUG: Checking segment $i: start=$segmentStart, end=$segmentEnd');
      print('DEBUG: Selection: start=${selection.start}, end=${selection.end}');

      // Check if selection overlaps with this segment
      if (selection.start < segmentEnd && selection.end > segmentStart) {
        overlappingSegments.add(i);
        print('DEBUG: Segment $i overlaps with selection');
      }

      cumulativeLength += segment.text.length;
    }

    print('DEBUG: Overlapping segments: $overlappingSegments');

    // Handle the formatting based on overlapping segments
    if (overlappingSegments.isNotEmpty) {
      print('DEBUG: Processing overlapping segments');
      _applyFormattingToMultipleSegments(selectedType, editorNotifier, format,
          existingSegments, overlappingSegments, fullText, selection);
    } else {
      print('DEBUG: No overlapping segments found, creating new ones');
      // No segments found, create new segments
      _createNewSegmentsWithFormatting(
          selectedType, editorNotifier, format, fullText, selection);
    }
  }

  void _createNewSegmentsWithFormatting(
      TextFieldType selectedType,
      EditorNotifier editorNotifier,
      String format,
      String fullText,
      TextSelection selection) {
    final currentElement = editorNotifier.getCurrentSelectedTextElement()!;
    final beforeText = fullText.substring(0, selection.start);
    final selectedText = fullText.substring(selection.start, selection.end);
    final afterText = fullText.substring(selection.end);

    final newSegments = <TextSegment>[];

    // Add before text
    if (beforeText.isNotEmpty) {
      newSegments.add(TextSegment(
        text: beforeText,
        fontFamily: currentElement.fontFamily,
        fontSize: currentElement.fontSize,
        fontWeight: currentElement.fontWeight,
        color: currentElement.color,
      ));
    }

    // Add selected text with formatting
    if (selectedText.isNotEmpty) {
      var fontWeight = currentElement.fontWeight;
      var isItalic = false;
      var isUnderline = false;

      // Apply the requested formatting
      switch (format) {
        case 'bold':
          fontWeight = FontWeight.bold;
          break;
        case 'italic':
          isItalic = true;
          break;
        case 'underline':
          isUnderline = true;
          break;
      }

      newSegments.add(TextSegment(
        text: selectedText,
        fontFamily: currentElement.fontFamily,
        fontSize: currentElement.fontSize,
        fontWeight: fontWeight,
        color: currentElement.color,
        isItalic: isItalic,
        isUnderline: isUnderline,
      ));
    }

    // Add after text
    if (afterText.isNotEmpty) {
      newSegments.add(TextSegment(
        text: afterText,
        fontFamily: currentElement.fontFamily,
        fontSize: currentElement.fontSize,
        fontWeight: currentElement.fontWeight,
        color: currentElement.color,
      ));
    }

    // Update the element
    final updatedElement = currentElement.copyWith(
      segments: newSegments,
      content: fullText,
    );

    editorNotifier.updateTextElement(updatedElement);
  }

  void _applyFormattingToMultipleSegments(
      TextFieldType selectedType,
      EditorNotifier editorNotifier,
      String format,
      List<TextSegment> existingSegments,
      List<int> overlappingSegmentIndices,
      String fullText,
      TextSelection selection) {
    print(
        'DEBUG: Applying formatting to ${overlappingSegmentIndices.length} segments');

    final newSegments = <TextSegment>[];
    int currentTextPosition = 0;

    for (int i = 0; i < existingSegments.length; i++) {
      final segment = existingSegments[i];
      final segmentStart = currentTextPosition;
      final segmentEnd = currentTextPosition + segment.text.length;

      print(
          'DEBUG: Processing segment $i: "$segment.text" (positions $segmentStart-$segmentEnd)');

      if (overlappingSegmentIndices.contains(i)) {
        // This segment overlaps with the selection - split it
        print('DEBUG: Segment $i overlaps - splitting');

        final overlapStart =
            selection.start > segmentStart ? selection.start : segmentStart;
        final overlapEnd =
            selection.end < segmentEnd ? selection.end : segmentEnd;

        print('DEBUG: Overlap region: $overlapStart-$overlapEnd');

        // Calculate relative positions within this segment
        final relativeOverlapStart = overlapStart - segmentStart;
        final relativeOverlapEnd = overlapEnd - segmentStart;

        print(
            'DEBUG: Relative overlap: $relativeOverlapStart-$relativeOverlapEnd');

        // Split the segment into parts
        final beforeOverlap = relativeOverlapStart > 0
            ? segment.text.substring(0, relativeOverlapStart)
            : '';

        final overlapText = segment.text.substring(
            relativeOverlapStart,
            relativeOverlapEnd > segment.text.length
                ? segment.text.length
                : relativeOverlapEnd);

        final afterOverlap = relativeOverlapEnd < segment.text.length
            ? segment.text.substring(relativeOverlapEnd)
            : '';

        print(
            'DEBUG: Split results - Before: "$beforeOverlap", Overlap: "$overlapText", After: "$afterOverlap"');

        // Add before overlap segment (if any)
        if (beforeOverlap.isNotEmpty) {
          newSegments.add(segment.copyWith(text: beforeOverlap));
        }

        // Add overlap segment with formatting applied
        if (overlapText.isNotEmpty) {
          var newFontWeight = segment.fontWeight;
          var newIsItalic = segment.isItalic;
          var newIsUnderline = segment.isUnderline;

          // Apply the requested formatting
          switch (format) {
            case 'bold':
              newFontWeight = newFontWeight == FontWeight.bold
                  ? FontWeight.normal
                  : FontWeight.bold;
              break;
            case 'italic':
              newIsItalic = !newIsItalic;
              break;
            case 'underline':
              newIsUnderline = !newIsUnderline;
              break;
          }

          newSegments.add(segment.copyWith(
            text: overlapText,
            fontWeight: newFontWeight,
            isItalic: newIsItalic,
            isUnderline: newIsUnderline,
          ));
        }

        // Add after overlap segment (if any)
        if (afterOverlap.isNotEmpty) {
          newSegments.add(segment.copyWith(text: afterOverlap));
        }
      } else {
        // This segment doesn't overlap - keep it as is
        print('DEBUG: Segment $i does not overlap - keeping as is');
        newSegments.add(segment);
      }

      currentTextPosition += segment.text.length;
    }

    print('DEBUG: Final segments after multi-segment processing:');
    for (int i = 0; i < newSegments.length; i++) {
      print('DEBUG: Segment $i: "${newSegments[i].text}"');
    }

    // Update the element with the new segments
    final updatedElement =
        editorNotifier.getCurrentSelectedTextElement()!.copyWith(
              segments: newSegments,
              content: fullText,
            );

    editorNotifier.updateTextElement(updatedElement);
  }

  void _createNewSegmentsWithColor(
      TextFieldType selectedType,
      EditorNotifier editorNotifier,
      Color color,
      String fullText,
      TextSelection selection) {
    final currentElement = editorNotifier.getCurrentSelectedTextElement()!;
    final beforeText = fullText.substring(0, selection.start);
    final selectedText = fullText.substring(selection.start, selection.end);
    final afterText = fullText.substring(selection.end);

    final newSegments = <TextSegment>[];

    // Add before text
    if (beforeText.isNotEmpty) {
      newSegments.add(TextSegment(
        text: beforeText,
        fontFamily: currentElement.fontFamily,
        fontSize: currentElement.fontSize,
        fontWeight: currentElement.fontWeight,
        color: currentElement.color,
      ));
    }

    // Add selected text with new color
    if (selectedText.isNotEmpty) {
      newSegments.add(TextSegment(
        text: selectedText,
        fontFamily: currentElement.fontFamily,
        fontSize: currentElement.fontSize,
        fontWeight: currentElement.fontWeight,
        color: color, // Apply the selected color
        isItalic: false,
        isUnderline: false,
      ));
    }

    // Add after text
    if (afterText.isNotEmpty) {
      newSegments.add(TextSegment(
        text: afterText,
        fontFamily: currentElement.fontFamily,
        fontSize: currentElement.fontSize,
        fontWeight: currentElement.fontWeight,
        color: currentElement.color,
      ));
    }

    // Update the element
    final updatedElement = currentElement.copyWith(
      segments: newSegments,
      content: fullText,
    );

    editorNotifier.updateTextElement(updatedElement);
  }

  void _applyFormattingToAll(TextFieldType selectedType,
      EditorNotifier editorNotifier, String format) {
    // Always convert to rich text first if not already
    if (!editorNotifier.getCurrentSelectedTextElement()!.isRichText) {
      editorNotifier.convertToRichText(selectedType);
    }

    // Apply formatting to the entire text
    switch (format) {
      case 'bold':
        editorNotifier.applyRichTextFormatting(
          selectedType,
          (segment) => segment.copyWith(
            fontWeight: segment.fontWeight == FontWeight.bold
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        );
        break;
      case 'italic':
        editorNotifier.applyRichTextFormatting(
          selectedType,
          (segment) => segment.copyWith(isItalic: !segment.isItalic),
        );
        break;
      case 'underline':
        editorNotifier.applyRichTextFormatting(
          selectedType,
          (segment) => segment.copyWith(isUnderline: !segment.isUnderline),
        );
        break;
    }
  }

  void _applyColorToSelection(
      TextFieldType selectedType, EditorNotifier editorNotifier, Color color) {
    // Get the current element
    final currentElement = editorNotifier.getCurrentSelectedTextElement();

    if (currentElement == null) return;

    // Check if there's a valid text selection
    if (_currentSelection != null &&
        _currentSelection!.start != _currentSelection!.end &&
        _currentSelection!.start >= 0 &&
        _currentSelection!.end <= _textController.text.length) {
      // Apply color to selected text only
      _applyColorToSelectionOnly(selectedType, editorNotifier, color);
    } else {
      // No selection or invalid selection - apply to entire text
      _applyColorToAll(selectedType, editorNotifier, color);
    }
  }

  void _applyColorToSelectionOnly(
      TextFieldType selectedType, EditorNotifier editorNotifier, Color color) {
    final fullText = _textController.text;
    final selection = _currentSelection!;

    // Get current element and ensure it's in rich text mode
    final currentElement = editorNotifier.getCurrentSelectedTextElement()!;
    if (!currentElement.isRichText) {
      editorNotifier.convertToRichText(selectedType);
    }

    // Get the updated element after potential conversion
    final updatedElement = editorNotifier.getCurrentSelectedTextElement()!;
    final existingSegments = updatedElement.segments ?? [];

    // If no segments exist, create them from scratch
    if (existingSegments.isEmpty) {
      _createNewSegmentsWithColor(
          selectedType, editorNotifier, color, fullText, selection);
      return;
    }

    // Find the segment that contains the selection
    int targetSegmentIndex = -1;
    int cumulativeLength = 0;

    for (int i = 0; i < existingSegments.length; i++) {
      final segment = existingSegments[i];
      final segmentStart = cumulativeLength;
      final segmentEnd = cumulativeLength + segment.text.length;

      // Check if selection overlaps with this segment
      if (selection.start < segmentEnd && selection.end > segmentStart) {
        targetSegmentIndex = i;
        break;
      }

      cumulativeLength += segment.text.length;
    }

    // If we found a segment, update its color
    if (targetSegmentIndex >= 0) {
      final targetSegment = existingSegments[targetSegmentIndex];
      final newSegments = List<TextSegment>.from(existingSegments);

      // Update the segment with new color
      newSegments[targetSegmentIndex] = targetSegment.copyWith(color: color);

      // Update the element
      final finalElement = updatedElement.copyWith(
        segments: newSegments,
        content: fullText,
      );

      editorNotifier.updateTextElement(finalElement);
    } else {
      // No segment found, create new segments
      _createNewSegmentsWithColor(
          selectedType, editorNotifier, color, fullText, selection);
    }
  }

  void _applyColorToAll(
      TextFieldType selectedType, EditorNotifier editorNotifier, Color color) {
    // Always convert to rich text first if not already
    if (!editorNotifier.getCurrentSelectedTextElement()!.isRichText) {
      editorNotifier.convertToRichText(selectedType);
    }

    // Apply color to the entire text
    editorNotifier.applyRichTextFormatting(
      selectedType,
      (segment) => segment.copyWith(color: color),
    );
  }
}

class _FontFamilyDropdown extends StatelessWidget {
  const _FontFamilyDropdown({
    required this.currentFont,
    required this.onFontChanged,
  });

  final String currentFont;
  final ValueChanged<String> onFontChanged;

  @override
  Widget build(BuildContext context) {
    // Using a conservative list of well-known Google Fonts that are guaranteed to work
    final fonts = [
      'Inter',
      'Roboto',
      'Open Sans',
      'Lato',
      'Montserrat',
      'Poppins',
      'Nunito',
      'Playfair Display',
      'Oswald',
      'Merriweather',
      'Ubuntu',
      'Raleway',
      'Barlow',
      'Rubik',
      'Work Sans',
      'Fira Sans',
      'Mulish',
      'Outfit',
      'Cairo',
      'Lexend',
      'Manrope',
      'Karla',
      'Libre Franklin',
      'Cabin',
      'Oxygen',
      'Lora',
      'Crimson Text',
      'Libre Baskerville',
      'PT Serif',
      'Merriweather Sans',
      'JetBrains Mono',
      'Fira Code',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: DropdownButton<String>(
        value: currentFont,
        onChanged: (value) {
          if (value != null) {
            onFontChanged(value);
          }
        },
        isExpanded: true,
        underline: const SizedBox(),
        items: fonts.map((font) {
          return DropdownMenuItem(
            value: font,
            child: Builder(
              builder: (context) {
                try {
                  return Text(
                    font,
                    style: GoogleFonts.getFont(
                      font,
                      fontSize: 12,
                      color: currentFont == font
                          ? const Color(0xFFE91E63)
                          : const Color(0xFF6C757D),
                    ),
                  );
                } catch (e) {
                  // Fallback to default font if Google Font fails to load
                  return Text(
                    font,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Roboto', // Safe fallback
                      color: currentFont == font
                          ? const Color(0xFFE91E63)
                          : const Color(0xFF6C757D),
                    ),
                  );
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ColorPickerButton extends StatelessWidget {
  const _ColorPickerButton({
    required this.currentColor,
    required this.onColorChanged,
    required this.buttonKey,
  });

  final Color currentColor;
  final ValueChanged<Color> onColorChanged;
  final GlobalKey buttonKey;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Text Color',
      child: InkWell(
        key: buttonKey,
        onTap: () {
          ColorPickerPopup.show(
            context: context,
            buttonKey: buttonKey,
            initialColor: currentColor,
            title: 'Text Color',
            onColorChanged: onColorChanged,
          );
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE1E5E9)),
          ),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: const Color(0xFFE1E5E9)),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: Color(0xFF6C757D),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF6C757D),
          ),
        ),
      ),
    );
  }
}

class _FontSizeButton extends StatelessWidget {
  const _FontSizeButton({
    required this.currentSize,
    required this.onSizeChanged,
  });

  final double currentSize;
  final ValueChanged<double> onSizeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: Row(
        children: [
          Text(
            '${currentSize.toInt()}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6C757D),
            ),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<double>(
            icon: const Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Color(0xFF6C757D),
            ),
            onSelected: onSizeChanged,
            itemBuilder: (context) => [
              12.0,
              14.0,
              16.0,
              18.0,
              20.0,
              24.0,
              28.0,
              32.0,
              36.0,
              40.0
            ].map((size) {
              return PopupMenuItem(
                value: size,
                child: Text(
                  '${size.toInt()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: currentSize == size
                        ? const Color(0xFFE91E63)
                        : const Color(0xFF6C757D),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
