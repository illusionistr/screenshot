import 'package:flutter/material.dart';

import '../constants/layouts_data.dart';
import '../models/layout_models.dart';
import '../services/platform_detection_service.dart';

/// Utility class for rendering layouts and calculating positions
class LayoutRenderer {
  /// Get the layout configuration for a given layout ID (always returns a valid config)
  static LayoutConfig getLayoutConfig(String layoutId) {
    return LayoutsData.getLayoutConfigOrDefault(layoutId);
  }

  /// Calculate device frame position based on layout configuration
  static Offset calculateDevicePosition(
    LayoutConfig layout,
    Size containerSize,
  ) {
    final centerX = containerSize.width / 2;
    final centerY = containerSize.height / 2;

    // Apply offset from layout configuration
    final offsetX = layout.deviceOffset.dx * containerSize.width;
    final offsetY = layout.deviceOffset.dy * containerSize.height;

    return Offset(centerX + offsetX, centerY + offsetY);
  }

  /// Calculate text position based on layout configuration
  static Offset calculateTextPosition(
    TextPosition textPosition,
    LayoutConfig layout,
    Size containerSize,
    Size deviceSize,
    Offset devicePosition,
  ) {
    final centerX = containerSize.width / 2;
    final centerY = containerSize.height / 2;

    double x, y;

    switch (textPosition) {
      case TextPosition.above:
        x = centerX;
        y = devicePosition.dy - deviceSize.height / 2 - layout.textPadding.top;
        break;
      case TextPosition.below:
        x = centerX;
        y = devicePosition.dy +
            deviceSize.height / 2 +
            layout.textPadding.bottom;
        break;
      case TextPosition.left:
        x = devicePosition.dx - deviceSize.width / 2 - layout.textPadding.left;
        y = centerY;
        break;
      case TextPosition.right:
        x = devicePosition.dx + deviceSize.width / 2 + layout.textPadding.right;
        y = centerY;
        break;
      case TextPosition.topLeft:
        x = layout.textPadding.left;
        y = layout.textPadding.top;
        break;
      case TextPosition.topRight:
        x = containerSize.width - layout.textPadding.right;
        y = layout.textPadding.top;
        break;
      case TextPosition.bottomLeft:
        x = layout.textPadding.left;
        y = containerSize.height - layout.textPadding.bottom;
        break;
      case TextPosition.bottomRight:
        x = containerSize.width - layout.textPadding.right;
        y = containerSize.height - layout.textPadding.bottom;
        break;
      case TextPosition.overlay:
        // For overlay, position text over the device frame
        x = devicePosition.dx;
        y = devicePosition.dy;
        break;
    }

    return Offset(x, y);
  }

  /// Get text alignment based on layout configuration
  static TextAlign getTextAlignment(
      TextPosition textPosition, LayoutConfig layout) {
    switch (textPosition) {
      case TextPosition.left:
      case TextPosition.topLeft:
      case TextPosition.bottomLeft:
        return TextAlign.left;
      case TextPosition.right:
      case TextPosition.topRight:
      case TextPosition.bottomRight:
        return TextAlign.right;
      case TextPosition.above:
      case TextPosition.below:
      case TextPosition.overlay:
      default:
        return layout.titleAlignment; // Use layout default
    }
  }

  /// Calculate device frame size based on layout configuration and actual device dimensions
  static Size calculateDeviceSize(
    LayoutConfig layout,
    Size containerSize, {
    String? deviceId,
    bool isLandscape = false,
  }) {
    // If deviceId is provided, use actual device proportions for visual differentiation
    if (deviceId != null) {
      final actualDeviceAspectRatio = PlatformDetectionService.getActualDeviceAspectRatio(
        deviceId,
        isLandscape: isLandscape,
      );
      
      // Base device width as a percentage of container width
      final baseWidth = containerSize.width * 0.4;
      final baseHeight = baseWidth / actualDeviceAspectRatio; // Use actual aspect ratio
      
      // Apply scale from layout
      final scaledWidth = baseWidth * layout.deviceScale;
      final scaledHeight = baseHeight * layout.deviceScale;
      
      print('DEBUG LayoutRenderer: deviceId=$deviceId, aspectRatio=${actualDeviceAspectRatio.toStringAsFixed(3)}, baseSize=${baseWidth.toStringAsFixed(1)}x${baseHeight.toStringAsFixed(1)}, scaledSize=${scaledWidth.toStringAsFixed(1)}x${scaledHeight.toStringAsFixed(1)}, scale=${layout.deviceScale}');
      
      return Size(scaledWidth, scaledHeight);
    }
    
    // Fallback to original hardcoded phone aspect ratio if no deviceId provided
    final baseWidth = containerSize.width * 0.4;
    final baseHeight = baseWidth * 2; // Phone aspect ratio
    
    // Apply scale from layout
    final scaledWidth = baseWidth * layout.deviceScale;
    final scaledHeight = baseHeight * layout.deviceScale;
    
    return Size(scaledWidth, scaledHeight);
  }

  /// Get frame variant asset path based on selected variant
  static String getFrameVariantPath(String frameVariant, String deviceId) {
    // This would map to actual asset paths based on device and frame variant
    // For now, return a placeholder
    switch (frameVariant) {
      case 'real':
        return 'assets/frames/$deviceId/real.png';
      case 'clay':
        return 'assets/frames/$deviceId/clay.png';
      case 'matte':
        return 'assets/frames/$deviceId/matte.png';
      case 'no device':
        return '';
      default:
        return 'assets/frames/$deviceId/real.png';
    }
  }

  /// Validate if a layout is compatible with a device
  static bool isLayoutCompatibleWithDevice(
    LayoutConfig layout,
    String deviceId,
    bool isLandscape,
  ) {
    // Check if layout orientation matches device orientation
    if (layout.isLandscape != isLandscape) {
      return false;
    }

    // Add more validation logic as needed
    return true;
  }

  /// Get recommended layouts for a specific device
  static List<LayoutModel> getRecommendedLayoutsForDevice(
    String deviceId,
    bool isLandscape,
  ) {
    return LayoutsData.layouts.where((layout) {
      return isLayoutCompatibleWithDevice(layout.config, deviceId, isLandscape);
    }).toList();
  }
}
