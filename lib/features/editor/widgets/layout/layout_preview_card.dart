import 'package:flutter/material.dart';

import '../../models/layout_models.dart';

class LayoutPreviewCard extends StatelessWidget {
  const LayoutPreviewCard({
    super.key,
    required this.layout,
    required this.isSelected,
    required this.onTap,
  });

  final LayoutModel layout;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFE91E63) : const Color(0xFFE1E5E9),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Layout Preview
            Expanded(
              child: _buildLayoutPreview(),
            ),

            // Layout Name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                layout.config.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF495057),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // Device Frame
          _buildDeviceFrame(),

          // Text Indicators
          _buildTextIndicators(),
        ],
      ),
    );
  }

  Widget _buildDeviceFrame() {
    final config = layout.config;
    final deviceSize = 40.0;

    // Calculate position based on layout config
    double left = 0.5;
    double top = 0.5;

    switch (config.devicePosition) {
      case LayoutPosition.centered:
        left = 0.5;
        top = 0.5;
        break;
      case LayoutPosition.leftTilted:
        left = 0.3;
        top = 0.5;
        break;
      case LayoutPosition.rightTilted:
        left = 0.7;
        top = 0.5;
        break;
      case LayoutPosition.leftAligned:
        left = 0.2;
        top = 0.5;
        break;
      case LayoutPosition.rightAligned:
        left = 0.8;
        top = 0.5;
        break;
    }

    return Positioned(
      left: (left - 0.5) * 80, // Adjust based on container width
      top: (top - 0.5) * 80, // Adjust based on container height
      child: Transform.rotate(
        angle:
            config.deviceRotation * 3.14159 / 180, // Convert degrees to radians
        child: Container(
          width: deviceSize * config.deviceScale,
          height: deviceSize * config.deviceScale * 2, // Phone aspect ratio
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              width: deviceSize * config.deviceScale * 0.8,
              height: deviceSize * config.deviceScale * 1.6,
              decoration: BoxDecoration(
                color: const Color(0xFF6C757D),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextIndicators() {
    final config = layout.config;

    return Stack(
      children: [
        // Title indicator
        if (config.titlePosition != TextPosition.overlay)
          _buildTextIndicator(
            config.titlePosition,
            'Title',
            const Color(0xFFE91E63),
          ),

        // Subtitle indicator
        if (config.subtitlePosition != TextPosition.overlay)
          _buildTextIndicator(
            config.subtitlePosition,
            'Subtitle',
            const Color(0xFF2196F3),
          ),

        // Overlay text indicators
        if (config.titlePosition == TextPosition.overlay ||
            config.subtitlePosition == TextPosition.overlay)
          _buildOverlayTextIndicator(),
      ],
    );
  }

  Widget _buildTextIndicator(TextPosition position, String text, Color color) {
    double left = 0.5;
    double top = 0.5;

    switch (position) {
      case TextPosition.above:
        left = 0.5;
        top = 0.1;
        break;
      case TextPosition.below:
        left = 0.5;
        top = 0.9;
        break;
      case TextPosition.left:
        left = 0.1;
        top = 0.5;
        break;
      case TextPosition.right:
        left = 0.9;
        top = 0.5;
        break;
      case TextPosition.topLeft:
        left = 0.1;
        top = 0.1;
        break;
      case TextPosition.topRight:
        left = 0.9;
        top = 0.1;
        break;
      case TextPosition.bottomLeft:
        left = 0.1;
        top = 0.9;
        break;
      case TextPosition.bottomRight:
        left = 0.9;
        top = 0.9;
        break;
      case TextPosition.overlay:
        return const SizedBox.shrink();
    }

    return Positioned(
      left: (left - 0.5) * 80,
      top: (top - 0.5) * 80,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayTextIndicator() {
    return Positioned(
      left: 20,
      top: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Text Overlay',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
