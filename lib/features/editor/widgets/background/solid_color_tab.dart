import 'package:flutter/material.dart';
import 'color_picker_dialog.dart';

class SolidColorTab extends StatefulWidget {
  final Color currentColor;
  final Function(Color) onColorChanged;

  const SolidColorTab({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  @override
  State<SolidColorTab> createState() => _SolidColorTabState();
}

class _SolidColorTabState extends State<SolidColorTab> {
  final GlobalKey _colorButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Background Color',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Current color preview and picker button
          GestureDetector(
            key: _colorButtonKey,
            onTap: () => _showColorPicker(context),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: widget.currentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.palette,
                      color: widget.currentColor.computeLuminance() > 0.5 
                        ? Colors.black54 
                        : Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tap to choose color',
                      style: TextStyle(
                        color: widget.currentColor.computeLuminance() > 0.5 
                          ? Colors.black87 
                          : Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Color details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: widget.currentColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Color',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '#${widget.currentColor.value.toRadixString(16).substring(2).toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick color presets
          const Text(
            'Quick Colors',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildQuickColors(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuickColors() {
    final quickColors = [
      Colors.white,
      Colors.black,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.indigo,
      Colors.blue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    return quickColors.map((color) {
      final isSelected = color.value == widget.currentColor.value;
      return GestureDetector(
        onTap: () => widget.onColorChanged(color),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected 
                ? Colors.blue 
                : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: isSelected
              ? Icon(
                  Icons.check,
                  size: 16,
                  color: color.computeLuminance() > 0.5 
                    ? Colors.black 
                    : Colors.white,
                )
              : null,
        ),
      );
    }).toList();
  }

  void _showColorPicker(BuildContext context) {
    ColorPickerPopup.show(
      context: context,
      buttonKey: _colorButtonKey,
      initialColor: widget.currentColor,
      title: 'Choose Background Color',
      onColorChanged: widget.onColorChanged, // Real-time preview
    );
  }
}

