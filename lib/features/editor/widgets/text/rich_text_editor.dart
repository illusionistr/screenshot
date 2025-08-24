import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/models/project_model.dart';
import '../../models/text_models.dart';
import '../../providers/editor_provider.dart';

class RichTextEditor extends ConsumerStatefulWidget {
  const RichTextEditor({
    super.key,
    required this.project,
    required this.element,
  });

  final ProjectModel project;
  final TextElement element;

  @override
  ConsumerState<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends ConsumerState<RichTextEditor> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();

    // Initialize with current segments or simple text
    _initializeText();
  }

  void _initializeText() {
    if (widget.element.isRichText && widget.element.segments != null) {
      // Convert segments to plain text for editing
      final text = widget.element.segments!.map((s) => s.text).join();
      _textController.text = text;
    } else {
      // Use simple content
      _textController.text = widget.element.content;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rich Text Toolbar
        _RichTextToolbar(
          onBoldPressed: _applyBold,
          onItalicPressed: _applyItalic,
          onUnderlinePressed: _applyUnderline,
          onColorPressed: _showColorPicker,
          onFontPressed: _showFontPicker,
        ),

        const SizedBox(height: 8),

        // Text Editor
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE1E5E9)),
          ),
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            maxLines: widget.element.type == TextFieldType.title ? 3 : 2,
            style: const TextStyle(
              fontSize: 16,
              height: 1.2,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter your text here...',
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Rich Text Preview
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE1E5E9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Preview:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6C757D),
                ),
              ),
              const SizedBox(height: 8),
              _buildRichTextPreview(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRichTextPreview() {
    if (widget.element.isRichText && widget.element.segments != null) {
      return Text.rich(
        TextSpan(
          children: widget.element.segments!.map((segment) {
            return TextSpan(
              text: segment.text,
              style: TextStyle(
                fontFamily: segment.fontFamily,
                fontSize: segment.fontSize,
                fontWeight: segment.fontWeight,
                color: segment.color,
                fontStyle:
                    segment.isItalic ? FontStyle.italic : FontStyle.normal,
                decoration:
                    segment.isUnderline ? TextDecoration.underline : null,
                height: 1.2,
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return Text(
        widget.element.content,
        style: TextStyle(
          fontFamily: widget.element.fontFamily,
          fontSize: widget.element.fontSize,
          fontWeight: widget.element.fontWeight,
          color: widget.element.color,
          height: 1.2,
        ),
      );
    }
  }

  void _applyBold() {
    _applyFormattingToSelection(
      (segment) => segment.copyWith(
        fontWeight: segment.fontWeight == FontWeight.bold
            ? FontWeight.normal
            : FontWeight.bold,
      ),
    );
  }

  void _applyItalic() {
    _applyFormattingToSelection(
      (segment) => segment.copyWith(
        isItalic: !segment.isItalic,
      ),
    );
  }

  void _applyUnderline() {
    _applyFormattingToSelection(
      (segment) => segment.copyWith(
        isUnderline: !segment.isUnderline,
      ),
    );
  }

  void _showColorPicker() {
    // Show color picker dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
                Colors.pink,
                Colors.teal,
                Colors.indigo,
                Colors.brown,
                Colors.grey,
                Colors.black,
              ].map((color) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _applyColor(color);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _applyColor(Color color) {
    _applyFormattingToSelection(
      (segment) => segment.copyWith(color: color),
    );
  }

  void _showFontPicker() {
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
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Font'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: ListView.builder(
            itemCount: fonts.length,
            itemBuilder: (context, index) {
              final font = fonts[index];
              return ListTile(
                title: Text(
                  font,
                  style: TextStyle(fontFamily: font),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _applyFont(font);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _applyFont(String fontFamily) {
    _applyFormattingToSelection(
      (segment) => segment.copyWith(fontFamily: fontFamily),
    );
  }

  void _applyFormattingToSelection(
      TextSegment Function(TextSegment) formatter) {
    final editorNotifier =
        ref.read(editorProviderFamily(widget.project).notifier);

    // If not in rich text mode, convert to rich text first
    if (!widget.element.isRichText) {
      final segments = [
        TextSegment(
          text: widget.element.content,
          fontFamily: widget.element.fontFamily,
          fontSize: widget.element.fontSize,
          fontWeight: widget.element.fontWeight,
          color: widget.element.color,
        )
      ];

      final updatedElement = widget.element.copyWith(
        isRichText: true,
        segments: segments,
      );

      editorNotifier.updateTextElement(updatedElement);
      return;
    }

    // For now, apply formatting to the entire text
    // In a more advanced implementation, this would apply to selected text only
    if (widget.element.segments != null) {
      final updatedSegments = widget.element.segments!.map(formatter).toList();

      final updatedElement = widget.element.copyWith(
        segments: updatedSegments,
      );

      editorNotifier.updateTextElement(updatedElement);
    }
  }
}

class _RichTextToolbar extends StatelessWidget {
  const _RichTextToolbar({
    required this.onBoldPressed,
    required this.onItalicPressed,
    required this.onUnderlinePressed,
    required this.onColorPressed,
    required this.onFontPressed,
  });

  final VoidCallback onBoldPressed;
  final VoidCallback onItalicPressed;
  final VoidCallback onUnderlinePressed;
  final VoidCallback onColorPressed;
  final VoidCallback onFontPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: Row(
        children: [
          _ToolbarButton(
            icon: Icons.format_bold,
            onPressed: onBoldPressed,
            tooltip: 'Bold',
          ),
          _ToolbarButton(
            icon: Icons.format_italic,
            onPressed: onItalicPressed,
            tooltip: 'Italic',
          ),
          _ToolbarButton(
            icon: Icons.format_underline,
            onPressed: onUnderlinePressed,
            tooltip: 'Underline',
          ),
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 20,
            color: const Color(0xFFE1E5E9),
          ),
          const SizedBox(width: 8),
          _ToolbarButton(
            icon: Icons.palette,
            onPressed: onColorPressed,
            tooltip: 'Text Color',
          ),
          _ToolbarButton(
            icon: Icons.font_download,
            onPressed: onFontPressed,
            tooltip: 'Font Family',
          ),
        ],
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
