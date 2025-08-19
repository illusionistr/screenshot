import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerPopup extends StatefulWidget {
  final Color initialColor;
  final String title;
  final Function(Color) onColorChanged;
  final VoidCallback? onClose;

  const ColorPickerPopup({
    super.key,
    required this.initialColor,
    required this.title,
    required this.onColorChanged,
    this.onClose,
  });

  static void show({
    required BuildContext context,
    required GlobalKey buttonKey,
    required Color initialColor,
    required String title,
    Function(Color)? onColorChanged,
    VoidCallback? onClose,
  }) {
    final RenderBox renderBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _PopupOverlay(
        position: position,
        buttonSize: size,
        onDismiss: () {
          overlayEntry.remove();
          onClose?.call();
        },
        child: ColorPickerPopup(
          initialColor: initialColor,
          title: title,
          onColorChanged: onColorChanged ?? (color) {},
          onClose: () {
            overlayEntry.remove();
            onClose?.call();
          },
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }

  @override
  State<ColorPickerPopup> createState() => _ColorPickerPopupState();
}

class _ColorPickerPopupState extends State<ColorPickerPopup> {
  late Color selectedColor;
  late Color originalColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
    originalColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Revert to original color
                    widget.onColorChanged(originalColor);
                    widget.onClose?.call();
                  },
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Color picker with layout similar to image
            ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                });
                // Real-time preview
                widget.onColorChanged(color);
              },
              colorPickerWidth: 280,
              pickerAreaHeightPercent: 0.7,
              displayThumbColor: true,
              paletteType: PaletteType.hsvWithHue,
              enableAlpha: true,
              hexInputBar: true,
              labelTypes: const [],
              portraitOnly: true,
              pickerAreaBorderRadius:
                  const BorderRadius.all(Radius.circular(8)),
            ),

            const SizedBox(height: 16),

            // Preview and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              
                // Action buttons
                TextButton(
                  onPressed: () {
                    // Revert to original color
                    widget.onColorChanged(originalColor);
                    widget.onClose?.call();
                  },
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onClose?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PopupOverlay extends StatelessWidget {
  final Offset position;
  final Size buttonSize;
  final VoidCallback onDismiss;
  final Widget child;

  const _PopupOverlay({
    required this.position,
    required this.buttonSize,
    required this.onDismiss,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Calculate optimal position
    double left =
        position.dx - 160; // Center popup horizontally relative to button
    double top = position.dy + buttonSize.height + 8; // Position below button

    // Adjust horizontal position if popup would go off screen
    if (left < 16) {
      left = 16;
    } else if (left + 320 > screenSize.width - 16) {
      left = screenSize.width - 320 - 16;
    }

    // Adjust vertical position if popup would go off screen
    if (top + 400 > screenSize.height - 16) {
      top = position.dy - 400 - 8; // Position above button
    }

    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.translucent,
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: GestureDetector(
                onTap: () {}, // Prevent dismissal when tapping on popup
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorPickerButton extends StatelessWidget {
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  final double size;

  const ColorPickerButton({
    super.key,
    required this.color,
    required this.tooltip,
    required this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: color == Colors.transparent
              ? Icon(
                  Icons.block,
                  color: Colors.grey.shade600,
                  size: size * 0.6,
                )
              : null,
        ),
      ),
    );
  }
}

class ColorPreviewRow extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const ColorPreviewRow({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.edit,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
