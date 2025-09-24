import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/frame_variant_model.dart';
import '../../../shared/services/device_service.dart';
import '../../constants/layouts_data.dart';
import '../../models/layout_models.dart';
import '../../models/positioning_models.dart';
import '../../providers/editor_provider.dart';

extension TextEditingControllerExtension on TextEditingController {
  void selectAll() {
    if (text.isEmpty) return;
    selection = TextSelection(baseOffset: 0, extentOffset: text.length);
  }
}

class LayoutControls extends ConsumerStatefulWidget {
  const LayoutControls({
    super.key,
    required this.selectedFrameVariant,
    required this.onFrameVariantChanged,
    required this.deviceId,
    required this.projectId,
  });

  final String selectedFrameVariant;
  final Function(String) onFrameVariantChanged;
  final String deviceId;
  final String projectId;

  @override
  ConsumerState<LayoutControls> createState() => _LayoutControlsState();
}

class _LayoutControlsState extends ConsumerState<LayoutControls> {
  List<FrameVariantModel> _availableFrameVariants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFrameVariants();
  }

  @override
  void didUpdateWidget(LayoutControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deviceId != widget.deviceId) {
      _loadFrameVariants();
    }
  }

  Future<void> _loadFrameVariants() async {
    if (widget.deviceId.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final variants =
          await DeviceService.getAvailableFrameVariants(widget.deviceId);
      setState(() {
        _availableFrameVariants = variants;
        _isLoading = false;
      });

      // If no frame is selected and we have variants, select the first one
      if (widget.selectedFrameVariant.isEmpty && variants.isNotEmpty) {
        widget.onFrameVariantChanged(variants.first.id);
      }
    } catch (e) {
      setState(() {
        _availableFrameVariants = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[LayoutControls] ===== REBUILDING LayoutControls =====');

    final editorProv = editorByProjectIdProvider(widget.projectId);
    final editorNotifier = ref.read(editorProv.notifier);

    // Only watch the specific properties we need for device transform
    final selectedScreenIndex = ref.watch(editorProv.select((s) => s.selectedScreenIndex));
    final screens = ref.watch(editorProv.select((s) => s.screens));

    print('[LayoutControls] selectedScreenIndex: $selectedScreenIndex, screens count: ${screens.length}');

    // Resolve current transform (per-screen override or from layout)
    final currentLayoutId = editorNotifier.getCurrentScreenLayoutId();
    final baseLayout = LayoutsData.getLayoutConfigOrDefault(currentLayoutId);
    final overrides = selectedScreenIndex != null &&
            selectedScreenIndex < screens.length
        ? screens[selectedScreenIndex].customSettings
        : const <String, dynamic>{};
    final deviceTransform = _resolveDeviceTransform(baseLayout, overrides);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Device Style Selection
        Row(
          children: [
            const Text(
              'Frame:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF495057),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStyleDropdown(),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Device Transform Controls
        _buildTransformControls(
          deviceTransform,
          onChanged: (t) {
            editorNotifier.updateDeviceTransformOverrideForCurrentScreen(t);
          },
        ),

        const SizedBox(height: 16),

        // Color Selection (placeholder)
        _buildColorSelection(),
      ],
    );
  }

  Widget _buildStyleDropdown() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE1E5E9)),
        ),
        child: const Text(
          'Loading frames...',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6C757D),
          ),
        ),
      );
    }

    if (_availableFrameVariants.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE1E5E9)),
        ),
        child: const Text(
          'No frames available',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6C757D),
          ),
        ),
      );
    }

    // Find the selected variant or use the first one as fallback
    String? selectedValue = widget.selectedFrameVariant.isNotEmpty
        ? widget.selectedFrameVariant
        : _availableFrameVariants.first.id;

    // Ensure the selected value exists in our list
    final hasSelectedValue =
        _availableFrameVariants.any((v) => v.id == selectedValue);
    if (!hasSelectedValue) {
      selectedValue = _availableFrameVariants.first.id;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6C757D)),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1A1A),
          ),
          items: _availableFrameVariants.map((variant) {
            return DropdownMenuItem<String>(
              value: variant.id,
              child: Row(
                children: [
                  Icon(
                    variant.isGeneric ? Icons.info_outline : Icons.check,
                    size: 16,
                    color: variant.isGeneric ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${variant.name} ${variant.isGeneric ? '(Generic)' : '(Real)'}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onFrameVariantChanged(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildColorSelection() {
    return Row(
      children: [
        const Text(
          'Color:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF495057),
          ),
        ),
        const SizedBox(width: 12),

        // Color options
        _buildColorOption(const Color(0xFFE91E63), 'Primary'),
        const SizedBox(width: 8),
        _buildColorOption(const Color(0xFF1A1A1A), 'Dark'),
        const SizedBox(width: 8),
        _buildColorOption(Colors.white, 'Light', hasBorder: true),
      ],
    );
  }

  Widget _buildColorOption(Color color, String label,
      {bool hasBorder = false}) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement color selection logic
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: hasBorder
              ? Border.all(color: const Color(0xFFE1E5E9), width: 1.5)
              : null,
        ),
      ),
    );
  }

  ElementTransform _resolveDeviceTransform(
      LayoutConfig layout, Map<String, dynamic> settings) {
    if (settings.containsKey('deviceTransform')) {
      final v = settings['deviceTransform'];
      if (v is Map<String, dynamic>) return ElementTransform.fromJson(v);
      if (v is Map) return ElementTransform.fromJson(Map<String, dynamic>.from(v));
    }
    return layout.deviceTransform;
  }

  Widget _buildTransformControls(ElementTransform value,
      {required ValueChanged<ElementTransform> onChanged}) {
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
            'Device Positioning',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF495057)),
          ),
          const SizedBox(height: 12),
          _LabeledRow(
            label: 'Scale',
            child: _SliderWithValue(
              min: 0.1,
              max: 3.0,
              value: value.scale.clamp(0.1, 3.0),
              format: (v) => '${v.toStringAsFixed(2)}x',
              decimalPlaces: 2,
              suffix: 'x',
              onChanged: (v) {
                print('[LayoutControls] Device scale slider changed to: $v');
                onChanged(value.copyWith(scale: v));
              },
            ),
          ),
          const SizedBox(height: 8),
          _LabeledRow(
            label: 'Rotation',
            child: _SliderWithValue(
              min: 0,
              max: 360,
              value: value.rotationDeg % 360,
              format: (v) => '${v.round()}°',
              decimalPlaces: 0,
              suffix: '°',
              onChanged: (v) => onChanged(value.copyWith(rotationDeg: v)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _LabeledDropdown<HorizontalAnchor>(
                  label: 'H Anchor',
                  value: value.hAnchor,
                  items: const {
                    HorizontalAnchor.left: 'Left',
                    HorizontalAnchor.center: 'Center',
                    HorizontalAnchor.right: 'Right',
                  },
                  onChanged: (v) => onChanged(value.copyWith(hAnchor: v)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LabeledDropdown<VerticalAnchor>(
                  label: 'V Anchor',
                  value: value.vAnchor,
                  items: const {
                    VerticalAnchor.top: 'Top',
                    VerticalAnchor.center: 'Center',
                    VerticalAnchor.bottom: 'Bottom',
                  },
                  onChanged: (v) => onChanged(value.copyWith(vAnchor: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _LabeledRow(
            label: 'H Offset',
            child: _SliderWithValue(
              min: -100.0,
              max: 100.0,
              value: (value.hPercent * 100).clamp(-100.0, 100.0),
              format: (v) => '${v.round()}%',
              decimalPlaces: 0,
              suffix: '%',
              onChanged: (v) => onChanged(value.copyWith(hPercent: v / 100)),
            ),
          ),
          const SizedBox(height: 8),
          _LabeledRow(
            label: 'V Offset',
            child: _SliderWithValue(
              min: -100.0,
              max: 100.0,
              value: (value.vPercent * 100).clamp(-100.0, 100.0),
              format: (v) => '${v.round()}%',
              decimalPlaces: 0,
              suffix: '%',
              onChanged: (v) => onChanged(value.copyWith(vPercent: v / 100)),
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
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _SliderWithValue extends StatefulWidget {
  final double min;
  final double max;
  final double value;
  final String Function(double) format;
  final ValueChanged<double> onChanged;
  final String? suffix;
  final int decimalPlaces;

  const _SliderWithValue({
    required this.min,
    required this.max,
    required this.value,
    required this.format,
    required this.onChanged,
    this.suffix,
    this.decimalPlaces = 2,
  });

  @override
  State<_SliderWithValue> createState() => _SliderWithValueState();
}

class _SliderWithValueState extends State<_SliderWithValue> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(_SliderWithValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isEditing) {
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    // Remove suffix and formatting for clean editing
    String valueText;
    if (widget.suffix != null) {
      valueText = widget.value.toStringAsFixed(widget.decimalPlaces);
    } else {
      valueText = widget.value.toStringAsFixed(widget.decimalPlaces);
    }
    _controller.text = valueText;
  }

  void _handleTextSubmitted(String text) {
    setState(() => _isEditing = false);

    try {
      double newValue = double.parse(text.replaceAll(widget.suffix ?? '', '').trim());
      newValue = newValue.clamp(widget.min, widget.max);
      widget.onChanged(newValue);
    } catch (e) {
      // If parsing fails, revert to current value
      _updateControllerText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            min: widget.min,
            max: widget.max,
            value: widget.value.clamp(widget.min, widget.max),
            onChanged: widget.onChanged,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE1E5E9)),
            ),
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF495057)),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onTap: () {
                setState(() => _isEditing = true);
                _controller.selectAll();
              },
              onSubmitted: _handleTextSubmitted,
              onEditingComplete: () {
                _handleTextSubmitted(_controller.text);
              },
              onTapOutside: (_) {
                _handleTextSubmitted(_controller.text);
              },
            ),
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
                  .map((e) => DropdownMenuItem<T>(
                      value: e.key, child: Text(e.value)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
