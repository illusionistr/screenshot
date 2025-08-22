import 'package:flutter/material.dart';

import '../../../shared/models/frame_variant_model.dart';
import '../../../shared/services/device_service.dart';

class LayoutControls extends StatefulWidget {
  const LayoutControls({
    super.key,
    required this.selectedFrameVariant,
    required this.onFrameVariantChanged,
    required this.deviceId,
  });

  final String selectedFrameVariant;
  final Function(String) onFrameVariantChanged;
  final String deviceId;

  @override
  State<LayoutControls> createState() => _LayoutControlsState();
}

class _LayoutControlsState extends State<LayoutControls> {
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

        // Color Selection (if applicable)
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
}
