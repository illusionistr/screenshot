import 'package:flutter/material.dart';

import 'color_picker_dialog.dart';

class GradientTab extends StatefulWidget {
  final Color startColor;
  final Color endColor;
  final String direction;
  final ValueChanged<Color> onStartColorChanged;
  final ValueChanged<Color> onEndColorChanged;
  final ValueChanged<String> onDirectionChanged;

  const GradientTab({
    super.key,
    required this.startColor,
    required this.endColor,
    required this.direction,
    required this.onStartColorChanged,
    required this.onEndColorChanged,
    required this.onDirectionChanged,
  });

  @override
  State<GradientTab> createState() => _GradientTabState();
}

class _GradientTabState extends State<GradientTab> {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gradient Preview
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            gradient: _buildGradient(),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Gradient Preview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Gradient Colors
        const Text(
          'Gradient Colors',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF495057),
          ),
        ),

        const SizedBox(height: 16),

        // Start and End Color Pickers
        Row(
          children: [
            Expanded(
              child: _ColorPicker(
                label: 'Start Color',
                color: widget.startColor,
                onColorChanged: widget.onStartColorChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ColorPicker(
                label: 'End Color',
                color: widget.endColor,
                onColorChanged: widget.onEndColorChanged,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Direction
        const Text(
          'Direction',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF495057),
          ),
        ),

        const SizedBox(height: 16),

        // Direction Dropdown
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE1E5E9)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.direction,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'vertical',
                  child: Text('Vertical (Top to Bottom)'),
                ),
                DropdownMenuItem(
                  value: 'horizontal',
                  child: Text('Horizontal (Left to Right)'),
                ),
                DropdownMenuItem(
                  value: 'diagonal',
                  child: Text('Diagonal (Top-Left to Bottom-Right)'),
                ),
              ],
              onChanged: (newValue) {
                if (newValue != null) {
                  widget.onDirectionChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  LinearGradient _buildGradient() {
    Alignment beginAlignment;
    Alignment endAlignment;

    switch (widget.direction) {
      case 'horizontal':
        beginAlignment = Alignment.centerLeft;
        endAlignment = Alignment.centerRight;
        break;
      case 'diagonal':
        beginAlignment = Alignment.topLeft;
        endAlignment = Alignment.bottomRight;
        break;
      case 'vertical':
      default:
        beginAlignment = Alignment.topCenter;
        endAlignment = Alignment.bottomCenter;
        break;
    }

    return LinearGradient(
      begin: beginAlignment,
      end: endAlignment,
      colors: [widget.startColor, widget.endColor],
    );
  }
}

class _ColorPicker extends StatefulWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const _ColorPicker({
    super.key,
    required this.label,
    required this.color,
    required this.onColorChanged,
  });

  @override
  State<_ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<_ColorPicker> {
  final GlobalKey _buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6C757D),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          key: _buttonKey,
          onTap: () {
            ColorPickerPopup.show(
              context: context,
              buttonKey: _buttonKey,
              initialColor: widget.color,
              title: widget.label,
              onColorChanged: widget.onColorChanged,
            );
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE1E5E9)),
            ),
            child: Center(
              child: Text(
                '#${widget.color.value.toRadixString(16).substring(2).toUpperCase()}',
                style: TextStyle(
                  color: widget.color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}