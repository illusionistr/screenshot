import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const CustomColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  late HSVColor currentHsv;
  late Color currentColor;

  final TextEditingController _rController = TextEditingController();
  final TextEditingController _gController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _aController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentColor = widget.initialColor;
    currentHsv = HSVColor.fromColor(currentColor);
    _updateControllers();
  }

  @override
  void dispose() {
    _rController.dispose();
    _gController.dispose();
    _bController.dispose();
    _aController.dispose();
    super.dispose();
  }

  void _updateControllers() {
    _rController.text = currentColor.red.toString();
    _gController.text = currentColor.green.toString();
    _bController.text = currentColor.blue.toString();
    _aController.text = '${(currentColor.opacity * 100).round()}%';
  }

  void _updateColor(HSVColor hsv) {
    setState(() {
      currentHsv = hsv;
      currentColor = hsv.toColor();
      _updateControllers();
    });
    widget.onColorChanged(currentColor);
  }

  void _updateFromRGB() {
    try {
      final r = int.parse(_rController.text).clamp(0, 255);
      final g = int.parse(_gController.text).clamp(0, 255);
      final b = int.parse(_bController.text).clamp(0, 255);
      final alphaText = _aController.text.replaceAll('%', '');
      final a = (int.parse(alphaText).clamp(0, 100) / 100.0);
      
      final color = Color.fromRGBO(r, g, b, a);
      setState(() {
        currentColor = color;
        currentHsv = HSVColor.fromColor(color);
      });
      widget.onColorChanged(currentColor);
    } catch (e) {
      // Invalid input, ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Large color picker area
        Container(
          width: 280,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: _ColorPickerArea(
              hue: currentHsv.hue,
              saturation: currentHsv.saturation,
              brightness: currentHsv.value,
              onChanged: (saturation, brightness) {
                _updateColor(currentHsv.withSaturation(saturation).withValue(brightness));
              },
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Hue slider
        SizedBox(
          width: 280,
          child: _HueSlider(
            hue: currentHsv.hue,
            onChanged: (hue) {
              _updateColor(currentHsv.withHue(hue));
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Color preview circle
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: currentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // RGB inputs
            Expanded(
              child: _RGBInputs(
                rController: _rController,
                gController: _gController,
                bController: _bController,
                aController: _aController,
                onChanged: _updateFromRGB,
                currentColor: currentColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorPickerArea extends StatefulWidget {
  final double hue;
  final double saturation;
  final double brightness;
  final ValueChanged<double> onSaturationChanged;
  final ValueChanged<double> onBrightnessChanged;
  final Function(double saturation, double brightness) onChanged;

  const _ColorPickerArea({
    required this.hue,
    required this.saturation,
    required this.brightness,
    required this.onChanged,
  }) : onSaturationChanged = _defaultCallback,
        onBrightnessChanged = _defaultCallback;

  static void _defaultCallback(double value) {}

  @override
  State<_ColorPickerArea> createState() => _ColorPickerAreaState();
}

class _ColorPickerAreaState extends State<_ColorPickerArea> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onTapDown: _handleTapDown,
      child: CustomPaint(
        size: const Size(280, 200),
        painter: _ColorAreaPainter(
          hue: widget.hue,
          saturation: widget.saturation,
          brightness: widget.brightness,
        ),
      ),
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _updatePosition(details.localPosition);
  }

  void _handleTapDown(TapDownDetails details) {
    _updatePosition(details.localPosition);
  }

  void _updatePosition(Offset position) {
    final saturation = (position.dx / 280).clamp(0.0, 1.0);
    final brightness = 1.0 - (position.dy / 200).clamp(0.0, 1.0);
    widget.onChanged(saturation, brightness);
  }
}

class _ColorAreaPainter extends CustomPainter {
  final double hue;
  final double saturation;
  final double brightness;

  _ColorAreaPainter({
    required this.hue,
    required this.saturation,
    required this.brightness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Create the hue color
    final hueColor = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
    
    // Paint the base hue color
    final paint = Paint();
    paint.color = hueColor;
    canvas.drawRect(rect, paint);
    
    // Add white to black gradient (brightness)
    final brightnessGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, Colors.transparent, Colors.black],
      stops: const [0.0, 0.5, 1.0],
    );
    paint.shader = brightnessGradient.createShader(rect);
    canvas.drawRect(rect, paint);
    
    // Add saturation gradient (transparent to color)
    final saturationGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Colors.white, Colors.transparent],
    );
    paint.shader = saturationGradient.createShader(rect);
    canvas.drawRect(rect, paint);
    
    // Draw the picker indicator
    final indicatorX = saturation * size.width;
    final indicatorY = (1.0 - brightness) * size.height;
    
    paint.shader = null;
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    
    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      8,
      paint,
    );
    
    paint.color = Colors.black;
    paint.strokeWidth = 1;
    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      8,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _HueSlider extends StatefulWidget {
  final double hue;
  final ValueChanged<double> onChanged;

  const _HueSlider({
    required this.hue,
    required this.onChanged,
  });

  @override
  State<_HueSlider> createState() => _HueSliderState();
}

class _HueSliderState extends State<_HueSlider> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onTapDown: _handleTapDown,
      child: Container(
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF0000), // Red
              Color(0xFFFFFF00), // Yellow
              Color(0xFF00FF00), // Green
              Color(0xFF00FFFF), // Cyan
              Color(0xFF0000FF), // Blue
              Color(0xFFFF00FF), // Magenta
              Color(0xFFFF0000), // Red
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: (widget.hue / 360) * 280 - 6,
              top: -2,
              child: Container(
                width: 12,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _updateHue(details.localPosition.dx);
  }

  void _handleTapDown(TapDownDetails details) {
    _updateHue(details.localPosition.dx);
  }

  void _updateHue(double x) {
    final hue = (x / 280 * 360).clamp(0.0, 360.0);
    widget.onChanged(hue);
  }
}

class _RGBInputs extends StatelessWidget {
  final TextEditingController rController;
  final TextEditingController gController;
  final TextEditingController bController;
  final TextEditingController aController;
  final VoidCallback onChanged;
  final Color currentColor;

  const _RGBInputs({
    required this.rController,
    required this.gController,
    required this.bController,
    required this.aController,
    required this.onChanged,
    required this.currentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // RGB label
        const Row(
          children: [
            Text(
              'RGB',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 16),
          ],
        ),
        const SizedBox(height: 8),
        
        // RGB values
        Row(
          children: [
            _buildValueColumn('R', rController, currentColor.red),
            const SizedBox(width: 12),
            _buildValueColumn('G', gController, currentColor.green),
            const SizedBox(width: 12),
            _buildValueColumn('B', bController, currentColor.blue),
            const SizedBox(width: 12),
            _buildValueColumn('A', aController, (currentColor.opacity * 100).round()),
          ],
        ),
      ],
    );
  }

  Widget _buildValueColumn(String label, TextEditingController controller, int value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 30,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.blue.shade400),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  label == 'A' ? RegExp(r'[0-9%]') : RegExp(r'[0-9]'),
                ),
                LengthLimitingTextInputFormatter(label == 'A' ? 4 : 3),
              ],
              onChanged: (_) => onChanged(),
            ),
          ),
        ],
      ),
    );
  }
}