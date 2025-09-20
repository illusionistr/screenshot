import 'package:flutter/material.dart';
import '../models/frame_style_models.dart';

/// Default frame styling configurations
class DefaultFrameStyles {
  DefaultFrameStyles._();

  /// Default project frame style configuration
  static const ProjectFrameStyleConfig defaultProject = ProjectFrameStyleConfig(
    projectId: 'default',
    borderColor: Colors.black,
    shadowIntensity: 0.1,
    borderThickness: 0.5,
    cornerRoundness: 0.5,
  );

  /// Device-specific styling overrides
  static const Map<String, DeviceFrameOverride> deviceOverrides = {
    // iPhone devices - slightly rounder corners
    'iphone-15-pro': DeviceFrameOverride(
      deviceId: 'iphone-15-pro',
      cornerRoundnessOverride: 0.7,
    ),
    'iphone-15': DeviceFrameOverride(
      deviceId: 'iphone-15',
      cornerRoundnessOverride: 0.7,
    ),
    'iphone-14': DeviceFrameOverride(
      deviceId: 'iphone-14',
      cornerRoundnessOverride: 0.6,
    ),
    
    // iPad devices - larger border and more rounded corners
    'ipad-pro-12-9': DeviceFrameOverride(
      deviceId: 'ipad-pro-12-9',
      borderThicknessOverride: 0.7,
      cornerRoundnessOverride: 0.8,
      shadowIntensityOverride: 0.15,
    ),
    'ipad-air': DeviceFrameOverride(
      deviceId: 'ipad-air',
      borderThicknessOverride: 0.6,
      cornerRoundnessOverride: 0.7,
      shadowIntensityOverride: 0.12,
    ),
    
    // Android phones - slightly sharper corners
    'pixel-8-pro': DeviceFrameOverride(
      deviceId: 'pixel-8-pro',
      cornerRoundnessOverride: 0.4,
    ),
    'galaxy-s24-ultra': DeviceFrameOverride(
      deviceId: 'galaxy-s24-ultra',
      cornerRoundnessOverride: 0.3,
    ),
    
    // Android tablets - medium roundness
    'galaxy-tab-s9': DeviceFrameOverride(
      deviceId: 'galaxy-tab-s9',
      borderThicknessOverride: 0.6,
      cornerRoundnessOverride: 0.5,
      shadowIntensityOverride: 0.12,
    ),
  };

  /// Get device override for a specific device ID
  static DeviceFrameOverride? getDeviceOverride(String deviceId) {
    return deviceOverrides[deviceId];
  }

  /// Check if a device has specific styling overrides
  static bool hasDeviceOverride(String deviceId) {
    return deviceOverrides.containsKey(deviceId);
  }

  /// Get all device IDs that have overrides
  static Set<String> getOverriddenDeviceIds() {
    return deviceOverrides.keys.toSet();
  }
}