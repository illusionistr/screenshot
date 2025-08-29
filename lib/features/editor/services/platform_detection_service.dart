import 'package:flutter/material.dart';

import '../../shared/data/devices_data.dart';
import '../../shared/models/device_model.dart';
import '../constants/platform_dimensions.dart';

class PlatformDetectionService {
  static DeviceType detectDeviceType(String deviceId, {bool isLandscape = false}) {
    final device = DevicesData.getDeviceById(deviceId);
    if (device == null) {
      return DeviceType.iphonePortrait;
    }

    return PlatformDimensions.getDeviceTypeFromDevice(device, isLandscape: isLandscape);
  }

  // DEPRECATED: Use getPlatformContainerDimensions() for platform compliance or getActualDeviceDimensions() for visual differentiation
  static PlatformDimensions getDimensionsForDevice(String deviceId, {bool isLandscape = false}) {
    final device = DevicesData.getDeviceById(deviceId);
    if (device == null) {
      return PlatformDimensions.appStoreDimensions[DeviceType.iphonePortrait]!;
    }

    return PlatformDimensions.getDimensionsForDevice(device, isLandscape: isLandscape);
  }

  /// Returns platform-compliant container dimensions for App Store/Google Play requirements
  /// Use this for main editor containers that need to meet platform standards
  static PlatformDimensions getPlatformContainerDimensions(String deviceId, {bool isLandscape = false}) {
    final device = DevicesData.getDeviceById(deviceId);
    if (device == null) {
      return PlatformDimensions.appStoreDimensions[DeviceType.iphonePortrait]!;
    }

    return PlatformDimensions.getDimensionsForDevice(device, isLandscape: isLandscape);
  }

  /// Returns actual device screen dimensions for visual differentiation in UI
  /// Use this for device frames and thumbnails to show correct aspect ratios
  static Size getActualDeviceDimensions(String deviceId, {bool isLandscape = false}) {
    final device = DevicesData.getDeviceById(deviceId);
    if (device == null) {
      // Fallback to iPhone portrait dimensions
      return const Size(1170, 2532);
    }

    final width = device.screenWidth.toDouble();
    final height = device.screenHeight.toDouble();
    
    return isLandscape ? Size(height, width) : Size(width, height);
  }

  /// Returns the actual device aspect ratio for visual differentiation
  /// Use this for calculating frame dimensions that show correct proportions
  static double getActualDeviceAspectRatio(String deviceId, {bool isLandscape = false}) {
    final device = DevicesData.getDeviceById(deviceId);
    if (device == null) {
      // Fallback to iPhone aspect ratio
      return isLandscape ? 2532 / 1170 : 1170 / 2532;
    }

    final aspectRatio = device.screenWidth / device.screenHeight;
    final finalRatio = isLandscape ? 1 / aspectRatio : aspectRatio;

    return finalRatio;
  }

  static bool isTablet(String deviceId) {
    final device = DevicesData.getDeviceById(deviceId);
    return device?.isTablet ?? false;
  }

  static bool isIOS(String deviceId) {
    final device = DevicesData.getDeviceById(deviceId);
    return device?.platform == Platform.ios;
  }

  static bool isAndroid(String deviceId) {
    final device = DevicesData.getDeviceById(deviceId);
    return device?.platform == Platform.android;
  }

  static String getPlatformDisplayName(String deviceId) {
    final device = DevicesData.getDeviceById(deviceId);
    if (device == null) return 'Unknown';

    final platformName = device.platform.displayName;
    final deviceTypeName = device.isTablet ? 'Tablet' : 'Phone';
    
    return '$platformName $deviceTypeName';
  }

  static List<String> getSupportedOrientations(String deviceId) {
    final device = DevicesData.getDeviceById(deviceId);
    if (device == null) return ['Portrait'];

    if (device.isTablet) {
      return ['Portrait', 'Landscape'];
    } else {
      return ['Portrait'];
    }
  }
}