import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/models/project_model.dart';
import '../../models/editor_state.dart';
import '../../models/text_models.dart';
import '../../providers/editor_provider.dart';
import '../background/color_picker_dialog.dart';

class TextFormattingPanel extends ConsumerWidget {
  const TextFormattingPanel({
    super.key,
    required this.project,
  });

  final ProjectModel project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProviderFamily(project));
    final editorNotifier = ref.read(editorProviderFamily(project).notifier);

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
            'Select a text element to edit its formatting',
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
        Text(
          '${selectedType.displayName} Formatting',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF495057),
          ),
        ),
        const SizedBox(height: 16),

        // Font Family Section
        _FormattingSection(
          title: 'Font Family',
          child: _CustomDropdown(
            value: currentElement.fontFamily,
            items: const [
              // System Fonts (Always Available)
              'Arial',
              'Helvetica Neue',
              'Calibri',
              'Georgia',
              'Times New Roman',
              'Garamond',

              // Popular Google Fonts - Sans Serif
              'Inter',
              'Roboto',
              'Open Sans',
              'Lato',
              'Montserrat',
              'Poppins',
              'Nunito',
              'Source Sans Pro',
              'Ubuntu',
              'Karla',
              'Quicksand',
              'Comfortaa',
              'Mukti',

              // Display & Brand Fonts
              'Oswald',
              'Bebas Neue',
              'Playfair Display',
              'Cinzel',
              'Abril Fatface',
              'Dancing Script',
              'Pacifico',
              'Amatic SC',
              'Great Vibes',
              'Satisfy',

              // Professional & Serif Fonts
              'Merriweather',
              'Libre Baskerville',
              'Crimson Text',
              'Lora',
              'Vollkorn',
              'Source Serif Pro',
              'PT Serif',
              'Noto Serif',

              // Modern & Geometric Fonts
              'Futura PT',
              'Gothic A1',
              'Rajdhani',
              'Orbitron',
              'Audiowide',
              'Syncopate',
              'Monoton',

              // Rounded & Friendly Fonts
              'Rounded Mplus 1c',
              'M PLUS Rounded 1c',
              'Noto Sans JP',
              'Fredoka One',
              'Chewy',
              'Baloo 2',
              'Happy Monkey',
              'Comic Neue',

              // Clean & Minimal Fonts
              'DM Sans',
              'Manrope',
              'Epilogue',
              'Jost',
              'Red Hat Display',
              'Space Grotesk',
              'Syne',
              'Chivo',

              // Retro & Vintage Fonts
              'Press Start 2P',
              'VT323',
              'Special Elite',
              'Courier Prime',
              'Cutive Mono',
              'Nova Mono',
              'Fira Code',
              'JetBrains Mono',

              // Handwriting & Script Fonts
              'Indie Flower',
              'Patrick Hand',
              'Caveat',
              'Shadows Into Light',
              'Sacramento',
              'Marck Script',
              'Parisienne',
              'Tangerine',
            ],
            onChanged: (value) {
              editorNotifier.updateTextFormatting(
                type: selectedType,
                fontFamily: value,
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Font Size Section
        _FormattingSection(
          title: 'Font Size',
          child: _CustomDropdown(
            value: '${currentElement.fontSize.toInt()}',
            items: const [
              '12',
              '14',
              '16',
              '18',
              '20',
              '24',
              '28',
              '32',
              '36',
              '40'
            ],
            onChanged: (value) {
              editorNotifier.updateTextFormatting(
                type: selectedType,
                fontSize: double.parse(value),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Font Weight Section
        _FormattingSection(
          title: 'Font Weight',
          child: Row(
            children: EditorFontWeight.values.map((weight) {
              final isSelected = currentElement.fontWeight == weight.fontWeight;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _WeightButton(
                  weight: weight,
                  isSelected: isSelected,
                  onPressed: () {
                    editorNotifier.updateTextFormatting(
                      type: selectedType,
                      fontWeight: weight.fontWeight,
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Vertical Position Section
        _FormattingSection(
          title: 'Vertical Alignment',
          child: Row(
            children: VerticalPosition.values.map((position) {
              // Get the current screen text config to check grouping
              final currentScreenTextConfig =
                  editorNotifier.getCurrentScreenTextConfig();
              final isGrouped =
                  currentScreenTextConfig?.hasBothElementsVisible == true &&
                      currentScreenTextConfig?.textGrouping ==
                          TextGrouping.together;

              // Use primary element for positioning display if grouped
              final positioningElement = isGrouped
                  ? currentScreenTextConfig?.primaryElement ?? currentElement
                  : currentElement;

              final isSelected = (positioningElement.verticalPosition ??
                      _getDefaultVerticalPosition(positioningElement.type)) ==
                  position;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _PositionButton(
                  displayName: _getVerticalPositionDisplayName(position),
                  isSelected: isSelected,
                  onPressed: () {
                    if (isGrouped) {
                      // When grouped, always update the primary element for positioning
                      final primaryElement =
                          currentScreenTextConfig?.primaryElement;
                      if (primaryElement != null) {
                        final updatedElement = primaryElement.copyWith(
                          verticalPosition: position,
                        );
                        editorNotifier.updateTextElement(updatedElement);
                      }
                    } else {
                      // When not grouped, update the current element
                      final updatedElement = currentElement.copyWith(
                        verticalPosition: position,
                      );
                      editorNotifier.updateTextElement(updatedElement);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Text Alignment Section
        _FormattingSection(
          title: 'Horizontal Alignment',
          child: Row(
            children: [
              ...EditorTextAlign.values.map((align) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _IconButton(
                      icon: align.icon,
                      isSelected: currentElement.textAlign == align.textAlign,
                      onPressed: () {
                        editorNotifier.updateTextFormatting(
                          type: selectedType,
                          textAlign: align.textAlign,
                        );
                      },
                    ),
                  )),
              const SizedBox(width: 16),

              // Color picker
              _ColorPickerSection(
                currentColor: currentElement.color,
                onColorChanged: (color) {
                  editorNotifier.updateTextFormatting(
                    type: selectedType,
                    color: color,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to get display name for vertical position
  String _getVerticalPositionDisplayName(VerticalPosition position) {
    switch (position) {
      case VerticalPosition.top:
        return 'Top';
      case VerticalPosition.middle:
        return 'Middle';
      case VerticalPosition.bottom:
        return 'Bottom';
    }
  }

  // Helper method to get default vertical position for text type
  VerticalPosition _getDefaultVerticalPosition(TextFieldType type) {
    switch (type) {
      case TextFieldType.title:
        return VerticalPosition.top;
      case TextFieldType.subtitle:
        return VerticalPosition.bottom;
    }
  }
}

class _FormattingSection extends StatelessWidget {
  const _FormattingSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6C757D),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _CustomDropdown extends StatelessWidget {
  const _CustomDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ))
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}

class _WeightButton extends StatelessWidget {
  const _WeightButton({
    required this.weight,
    required this.isSelected,
    required this.onPressed,
  });

  final EditorFontWeight weight;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFE91E63) : const Color(0xFFE1E5E9),
          ),
        ),
        child: Text(
          weight.displayName
              .substring(0, 1), // First letter only (L, N, M, S, B)
          style: TextStyle(
            fontSize: 12,
            fontWeight: weight.fontWeight,
            color: isSelected ? Colors.white : const Color(0xFF6C757D),
          ),
        ),
      ),
    );
  }
}

class _PositionButton extends StatelessWidget {
  const _PositionButton({
    required this.displayName,
    required this.isSelected,
    required this.onPressed,
  });

  final String displayName;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFE91E63) : const Color(0xFFE1E5E9),
          ),
        ),
        child: Text(
          displayName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6C757D),
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE91E63) : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : const Color(0xFF6C757D),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _ColorPickerSection extends StatefulWidget {
  const _ColorPickerSection({
    required this.currentColor,
    required this.onColorChanged,
  });

  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  @override
  State<_ColorPickerSection> createState() => _ColorPickerSectionState();
}

class _ColorPickerSectionState extends State<_ColorPickerSection> {
  final GlobalKey _buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6C757D),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          key: _buttonKey,
          onTap: () {
            ColorPickerPopup.show(
              context: context,
              buttonKey: _buttonKey,
              initialColor: widget.currentColor,
              title: 'Text Color',
              onColorChanged: widget.onColorChanged,
            );
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 40,
            height: 32,
            decoration: BoxDecoration(
              color: widget.currentColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE1E5E9)),
            ),
            child: widget.currentColor == Colors.transparent
                ? const Icon(
                    Icons.block,
                    color: Color(0xFF6C757D),
                    size: 16,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
