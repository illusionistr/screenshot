import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/models/project_model.dart';
import '../../models/editor_state.dart';
import '../../models/text_models.dart';
import '../../providers/editor_provider.dart';
import '../../utils/text_renderer.dart';
import '../background/color_picker_dialog.dart';
import '../../models/positioning_models.dart';

class TextFormattingPanel extends ConsumerWidget {
  const TextFormattingPanel({
    super.key,
    required this.project,
  });

  final ProjectModel project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorProv = editorByProjectIdProvider(project.id);
    final editorState = ref.watch(editorProv);
    final editorNotifier = ref.read(editorProv.notifier);

    final selectedType = editorState.textElementState.selectedType;
    final currentElement = editorNotifier.getCurrentSelectedTextElement();

    if (selectedType == null || currentElement == null) {
      return Container(
        padding: const EdgeInsets.all(10),
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

        // Font Family, Font Size, and Color Picker Sections
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Font Family Section - Fixed width
            SizedBox(
              width: 180, // Reduced width for font family
              child: _FormattingSection(
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
                  previewWithFont: true,
                  onChanged: (value) {
                    editorNotifier.updateTextFormatting(
                      type: selectedType,
                      fontFamily: value,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Font Size Section - Takes remaining space
            Expanded(
              child: _FormattingSection(
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
            ),

            const SizedBox(width: 16),

            // Color Picker Section - Fixed width
            SizedBox(
              width: 60, // Reduced width for color picker
              child: _ColorPickerSection(
                currentColor: currentElement.color,
                onColorChanged: (color) {
                  editorNotifier.updateTextFormatting(
                    type: selectedType,
                    color: color,
                  );
                },
              ),
            ),
          ],
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
        // Vertical and Horizontal Alignment Sections - Side by Side
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vertical Alignment Section
            Expanded(
              child: _FormattingSection(
                title: 'Vertical Alignment',
                child: Row(
                  children: VerticalPosition.values.map((position) {
                    // Get the current screen text config to check grouping
                    final currentScreenTextConfig =
                        editorNotifier.getCurrentScreenTextConfig();
                    final isGrouped =
                        currentScreenTextConfig?.hasBothElementsVisible ==
                                true &&
                            currentScreenTextConfig?.textGrouping ==
                                TextGrouping.together;

                    // Use primary element for positioning display if grouped
                    final positioningElement = isGrouped
                        ? currentScreenTextConfig?.primaryElement ??
                            currentElement
                        : currentElement;

                    final isSelected = (positioningElement.verticalPosition ??
                            _getDefaultVerticalPosition(
                                positioningElement.type)) ==
                        position;

                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
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
            ),

            const SizedBox(width: 16),

            // Horizontal Alignment Section
            Expanded(
              child: _FormattingSection(
                title: 'Horizontal Alignment',
                child: Row(
                  children: [
                    ...EditorTextAlign.values.map((align) => Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: _IconButton(
                            icon: align.icon,
                            isSelected:
                                currentElement.textAlign == align.textAlign,
                            onPressed: () {
                              editorNotifier.updateTextFormatting(
                                type: selectedType,
                                textAlign: align.textAlign,
                              );
                            },
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Precise Positioning (anchor + offsets)
        _TextPositioningControls(project: project),
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

class _TextPositioningControls extends ConsumerWidget {
  final ProjectModel project;
  const _TextPositioningControls({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorProv = editorByProjectIdProvider(project.id);
    final editorState = ref.watch(editorProv);
    final editorNotifier = ref.read(editorProv.notifier);

    final selectedType = editorState.textElementState.selectedType;
    if (selectedType == null) return const SizedBox.shrink();

    final t = editorNotifier.resolveTextTransformForCurrentScreen(selectedType);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Positioning',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF495057)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LabeledDropdown<HorizontalAnchor>(
                  label: 'H Anchor',
                  value: t.hAnchor,
                  items: const {
                    HorizontalAnchor.left: 'Left',
                    HorizontalAnchor.center: 'Center',
                    HorizontalAnchor.right: 'Right',
                  },
                  onChanged: (v) {
                    editorNotifier.updateTextTransformOverrideForCurrentScreen(
                      selectedType,
                      t.copyWith(hAnchor: v),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LabeledDropdown<VerticalAnchor>(
                  label: 'V Anchor',
                  value: t.vAnchor,
                  items: const {
                    VerticalAnchor.top: 'Top',
                    VerticalAnchor.center: 'Center',
                    VerticalAnchor.bottom: 'Bottom',
                  },
                  onChanged: (v) {
                    editorNotifier.updateTextTransformOverrideForCurrentScreen(
                      selectedType,
                      t.copyWith(vAnchor: v),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _LabeledRow(
            label: 'H Offset',
            child: _SliderWithValue(
              min: -1.0,
              max: 1.0,
              value: t.hPercent.clamp(-1.0, 1.0),
              format: (v) => '${(v * 100).round()}%',
              onChanged: (v) {
                editorNotifier.updateTextTransformOverrideForCurrentScreen(
                  selectedType,
                  t.copyWith(hPercent: v),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _LabeledRow(
            label: 'V Offset',
            child: _SliderWithValue(
              min: -1.0,
              max: 1.0,
              value: t.vPercent.clamp(-1.0, 1.0),
              format: (v) => '${(v * 100).round()}%',
              onChanged: (v) {
                editorNotifier.updateTextTransformOverrideForCurrentScreen(
                  selectedType,
                  t.copyWith(vPercent: v),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledRow({required this.label, required this.child});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _SliderWithValue extends StatelessWidget {
  final double min;
  final double max;
  final double value;
  final String Function(double) format;
  final ValueChanged<double> onChanged;
  const _SliderWithValue({
    required this.min,
    required this.max,
    required this.value,
    required this.format,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            min: min,
            max: max,
            value: value.clamp(min, max),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 56,
          child: Text(
            format(value),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, color: Color(0xFF495057)),
          ),
        ),
      ],
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE1E5E9)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              items: items.entries
                  .map((e) => DropdownMenuItem<T>(value: e.key, child: Text(e.value)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
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
        const SizedBox(height: 6),
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
    this.previewWithFont = false,
    this.previewFontSize = 14,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final bool previewWithFont;
  final double previewFontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
                      style: previewWithFont
                          ? TextRenderer.previewStyleForFontFamily(
                              item,
                              fontSize: previewFontSize.toDouble(),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF212529),
                            )
                          : const TextStyle(fontSize: 13),
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
          displayName,
          style: TextStyle(
            fontSize: 11,
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
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE91E63) : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 14,
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
        const SizedBox(height: 6),
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
            height: 50,
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
