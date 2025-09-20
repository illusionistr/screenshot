import '../data/devices_data.dart';
import '../data/frame_variants_data.dart';
import '../models/device_model.dart';
import '../models/frame_variant_model.dart';
import 'frame_asset_service.dart';

class DeviceService {
  DeviceService._();

  static DeviceModel? getDeviceById(String id) {
    return DevicesData.getDeviceById(id);
  }

  static List<DeviceModel> getAllDevices() {
    return DevicesData.allDevices;
  }

  static List<DeviceModel> getDevicesByPlatform(Platform platform) {
    return DevicesData.getDevicesByPlatform(platform);
  }

  static List<DeviceModel> getPhones() {
    return DevicesData.getPhones();
  }

  static List<DeviceModel> getTablets() {
    return DevicesData.getTablets();
  }

  static List<String> getDeviceIdsByPlatform(Platform platform) {
    return DevicesData.getDeviceIdsByPlatform(platform);
  }

  static List<FrameVariantModel> getFrameVariants(String deviceId) {
    return FrameVariantsData.getFrameVariantsByDeviceId(deviceId);
  }

  static FrameVariantModel? getFrameVariant(String deviceId, String variantId) {
    return FrameVariantsData.getFrameVariantById(deviceId, variantId);
  }

  /// Get available frame variants for a device (real frames that exist + generic fallback)
  static Future<List<FrameVariantModel>> getAvailableFrameVariants(
      String deviceId) async {
    return FrameAssetService.getAvailableFrameVariants(deviceId);
  }

  /// Get the best available frame variant for a device
  static Future<FrameVariantModel?> getDefaultFrameVariant(
      String deviceId) async {
    return FrameAssetService.getBestAvailableFrameVariant(deviceId);
  }

  /// Get a specific frame variant if available, otherwise return generic
  static Future<FrameVariantModel?> getFrameVariantWithFallback(
      String deviceId, String variantId) async {
    return FrameAssetService.getFrameVariantWithFallback(deviceId, variantId);
  }

  static FrameVariantModel? getGenericFrameVariant(String deviceId) {
    final variants = getFrameVariants(deviceId);
    return variants.where((variant) => variant.isGeneric).firstOrNull;
  }

  /// Check if a device has any real frame variants available
  static Future<bool> hasRealFrameVariants(String deviceId) async {
    return FrameAssetService.hasRealFrameVariants(deviceId);
  }

  /// Get only the real frame variants that are available
  static Future<List<FrameVariantModel>> getRealFrameVariants(
      String deviceId) async {
    return FrameAssetService.getAvailableRealFrameVariants(deviceId);
  }

  static List<DeviceModel> searchDevices(String query) {
    if (query.isEmpty) return getAllDevices();

    final lowerQuery = query.toLowerCase();
    return getAllDevices().where((device) {
      return device.name.toLowerCase().contains(lowerQuery) ||
          device.id.toLowerCase().contains(lowerQuery) ||
          device.platform.displayName.toLowerCase().contains(lowerQuery) ||
          device.appStoreDisplaySize.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static List<DeviceModel> filterDevices({
    Platform? platform,
    bool? isTablet,
    String? sizeCategory,
  }) {
    var devices = getAllDevices();

    if (platform != null) {
      devices = devices.where((device) => device.platform == platform).toList();
    }

    if (isTablet != null) {
      devices = devices.where((device) => device.isTablet == isTablet).toList();
    }

    if (sizeCategory != null) {
      devices = devices.where((device) {
        switch (sizeCategory.toLowerCase()) {
          case 'small':
            return device.screenWidth < 1200;
          case 'medium':
            return device.screenWidth >= 1200 && device.screenWidth < 1400;
          case 'large':
            return device.screenWidth >= 1400;
          default:
            return true;
        }
      }).toList();
    }

    return devices;
  }

  static Map<Platform, List<DeviceModel>> groupDevicesByPlatform() {
    final grouped = <Platform, List<DeviceModel>>{};

    for (final platform in Platform.values) {
      grouped[platform] = getDevicesByPlatform(platform);
    }

    return grouped;
  }

  static Map<String, List<DeviceModel>> groupDevicesByCategory() {
    return {
      'Phones': getPhones(),
      'Tablets': getTablets(),
    };
  }

  static bool validateDeviceSelection(List<String> deviceIds) {
    return deviceIds.every((id) => getDeviceById(id) != null);
  }

  static List<String> getInvalidDeviceIds(List<String> deviceIds) {
    return deviceIds.where((id) => getDeviceById(id) == null).toList();
  }

  static DeviceModel? getRecommendedDevice(Platform platform) {
    final devices = getDevicesByPlatform(platform);
    if (devices.isEmpty) return null;

    if (platform == Platform.ios) {
      return devices.firstWhere(
        (device) => device.id == 'iphone-15-pro',
        orElse: () => devices.first,
      );
    } else {
      return devices.firstWhere(
        (device) => device.id == 'pixel-8-pro',
        orElse: () => devices.first,
      );
    }
  }

  static List<DeviceModel> getPopularDevices() {
    final popularIds = [
      'iphone-15-pro',
      'iphone-14',
      'ipad-pro-12-9',
      'pixel-8-pro',
      'galaxy-s24-ultra',
    ];

    return popularIds
        .map((id) => getDeviceById(id))
        .where((device) => device != null)
        .cast<DeviceModel>()
        .toList();
  }
}
