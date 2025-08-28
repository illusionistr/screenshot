import 'package:flutter/material.dart';
import '../constants/default_frame_styles.dart';
import '../models/frame_style_models.dart';
import 'device_service.dart';

/// Service for managing frame styling across editor and export systems
class FrameStyleService {
  FrameStyleService._();

  /// Get computed frame style for a specific device and project
  static ComputedFrameStyle getStyleForDevice({
    required String deviceId,
    String? projectId,
    ProjectFrameStyleConfig? projectConfig,
  }) {
    // Use provided project config or default
    final config = projectConfig ?? DefaultFrameStyles.defaultProject;
    
    // Get device information for context
    final device = DeviceService.getDeviceById(deviceId);
    final isTablet = device?.isTablet ?? false;
    
    // Start with base project configuration
    double shadowIntensity = config.shadowIntensity;
    double borderThickness = config.borderThickness;
    double cornerRoundness = config.cornerRoundness;
    Color borderColor = config.borderColor;
    
    // Apply device-specific overrides
    final deviceOverride = config.deviceOverrides[deviceId] ?? 
                          DefaultFrameStyles.getDeviceOverride(deviceId);
    
    if (deviceOverride != null) {
      shadowIntensity = deviceOverride.shadowIntensityOverride ?? shadowIntensity;
      borderThickness = deviceOverride.borderThicknessOverride ?? borderThickness;
      cornerRoundness = deviceOverride.cornerRoundnessOverride ?? cornerRoundness;
      borderColor = deviceOverride.borderColorOverride ?? borderColor;
    }
    
    // Convert normalized values to pixel values based on device type
    final baseBorderRadius = isTablet ? 24.0 : 20.0;
    final maxBorderRadius = isTablet ? 32.0 : 28.0;
    final borderRadius = baseBorderRadius + (cornerRoundness * (maxBorderRadius - baseBorderRadius));
    
    final baseBorderWidth = isTablet ? 3.0 : 2.0;
    final maxBorderWidth = isTablet ? 6.0 : 5.0;
    final borderWidth = baseBorderWidth + (borderThickness * (maxBorderWidth - baseBorderWidth));
    
    // Create box shadows for Flutter widgets
    final boxShadows = _createBoxShadows(shadowIntensity);
    
    // Create canvas shadow spec for export
    final canvasShadow = _createCanvasShadow(shadowIntensity);
    
    return ComputedFrameStyle(
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      borderColor: borderColor,
      boxShadows: boxShadows,
      canvasShadow: canvasShadow,
    );
  }

  /// Get default style for a device (using default project configuration)
  static ComputedFrameStyle getDefaultStyleForDevice(String deviceId) {
    return getStyleForDevice(deviceId: deviceId);
  }

  /// Create BoxShadow list for Flutter widgets
  static List<BoxShadow> _createBoxShadows(double intensity) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: intensity),
        blurRadius: 8.0 + (intensity * 4.0), // 8-12 blur radius based on intensity
        offset: Offset(0, 2.0 + (intensity * 2.0)), // 2-4 offset based on intensity
      ),
    ];
  }

  /// Create canvas shadow spec for export rendering
  static CanvasShadowSpec _createCanvasShadow(double intensity) {
    return CanvasShadowSpec(
      color: Colors.black.withValues(alpha: intensity),
      blurRadius: 8.0 + (intensity * 4.0), // 8-12 blur radius based on intensity
      offset: Offset(0, 2.0 + (intensity * 2.0)), // 2-4 offset based on intensity
    );
  }

  /// Create a project frame style configuration with device overrides
  static ProjectFrameStyleConfig createProjectConfig({
    required String projectId,
    Color borderColor = Colors.black,
    double shadowIntensity = 0.1,
    double borderThickness = 0.5,
    double cornerRoundness = 0.5,
    Map<String, DeviceFrameOverride> deviceOverrides = const {},
  }) {
    // Merge with default device overrides
    final mergedOverrides = Map<String, DeviceFrameOverride>.from(DefaultFrameStyles.deviceOverrides);
    mergedOverrides.addAll(deviceOverrides);
    
    return ProjectFrameStyleConfig(
      projectId: projectId,
      borderColor: borderColor,
      shadowIntensity: shadowIntensity,
      borderThickness: borderThickness,
      cornerRoundness: cornerRoundness,
      deviceOverrides: mergedOverrides,
    );
  }

  /// Validate style parameters
  static bool validateStyleParameters({
    double? shadowIntensity,
    double? borderThickness,
    double? cornerRoundness,
  }) {
    if (shadowIntensity != null && (shadowIntensity < 0.0 || shadowIntensity > 1.0)) {
      return false;
    }
    if (borderThickness != null && (borderThickness < 0.0 || borderThickness > 1.0)) {
      return false;
    }
    if (cornerRoundness != null && (cornerRoundness < 0.0 || cornerRoundness > 1.0)) {
      return false;
    }
    return true;
  }

  /// Get recommended style parameters for a device type
  static Map<String, double> getRecommendedParameters(String deviceId) {
    final device = DeviceService.getDeviceById(deviceId);
    final isTablet = device?.isTablet ?? false;
    
    if (isTablet) {
      return {
        'shadowIntensity': 0.15,
        'borderThickness': 0.6,
        'cornerRoundness': 0.7,
      };
    } else {
      return {
        'shadowIntensity': 0.1,
        'borderThickness': 0.5,
        'cornerRoundness': 0.5,
      };
    }
  }
}