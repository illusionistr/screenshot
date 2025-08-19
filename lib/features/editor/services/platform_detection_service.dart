import '../../shared/models/device_model.dart';
import '../../shared/data/devices_data.dart';
import '../constants/platform_dimensions.dart';

class PlatformDetectionService {
  static DeviceType detectDeviceType(String deviceId, {bool isLandscape = false}) {
    final device = DevicesData.getDeviceById(deviceId);
    if (device == null) {
      return DeviceType.iphonePortrait;
    }

    return PlatformDimensions.getDeviceTypeFromDevice(device, isLandscape: isLandscape);
  }

  static PlatformDimensions getDimensionsForDevice(String deviceId, {bool isLandscape = false}) {
    final device = DevicesData.getDeviceById(deviceId);
    if (device == null) {
      return PlatformDimensions.appStoreDimensions[DeviceType.iphonePortrait]!;
    }

    return PlatformDimensions.getDimensionsForDevice(device, isLandscape: isLandscape);
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