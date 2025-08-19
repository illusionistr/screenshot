import 'package:flutter/material.dart';
import '../services/platform_detection_service.dart';

class PlatformDimensionCalculator {
  static const double containerHeight = 800.0;

  static Size calculateContainerSize(String deviceId, {bool isLandscape = false}) {
    final dimensions = PlatformDetectionService.getDimensionsForDevice(
      deviceId,
      isLandscape: isLandscape,
    );

    final width = dimensions.getWidthForHeight(containerHeight);
    return Size(width, containerHeight);
  }

  static double calculateAspectRatio(String deviceId, {bool isLandscape = false}) {
    final dimensions = PlatformDetectionService.getDimensionsForDevice(
      deviceId,
      isLandscape: isLandscape,
    );
    return dimensions.aspectRatio;
  }

  static Size calculateSizeForConstraints({
    required String deviceId,
    double? maxWidth,
    double? maxHeight,
    bool isLandscape = false,
  }) {
    final dimensions = PlatformDetectionService.getDimensionsForDevice(
      deviceId,
      isLandscape: isLandscape,
    );

    double width;
    double height;

    if (maxHeight != null) {
      height = maxHeight;
      width = dimensions.getWidthForHeight(height);
    } else if (maxWidth != null) {
      width = maxWidth;
      height = dimensions.getHeightForWidth(width);
    } else {
      height = containerHeight;
      width = dimensions.getWidthForHeight(height);
    }

    if (maxWidth != null && width > maxWidth) {
      width = maxWidth;
      height = dimensions.getHeightForWidth(width);
    }

    if (maxHeight != null && height > maxHeight) {
      height = maxHeight;
      width = dimensions.getWidthForHeight(height);
    }

    return Size(width, height);
  }

  static BoxConstraints getContainerConstraints(String deviceId, {bool isLandscape = false}) {
    final size = calculateContainerSize(deviceId, isLandscape: isLandscape);
    return BoxConstraints.tightFor(
      width: size.width,
      height: size.height,
    );
  }

  static String getDimensionDisplayText(String deviceId, {bool isLandscape = false}) {
    final dimensions = PlatformDetectionService.getDimensionsForDevice(
      deviceId,
      isLandscape: isLandscape,
    );
    
    return '${dimensions.width} × ${dimensions.height}';
  }

  static String getContainerDisplayText(String deviceId, {bool isLandscape = false}) {
    final size = calculateContainerSize(deviceId, isLandscape: isLandscape);
    return '${size.width.round()} × ${size.height.round()}';
  }
}

