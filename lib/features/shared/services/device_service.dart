import '../models/device_model.dart';
import '../models/frame_variant_model.dart';
import '../data/devices_data.dart';
import '../data/frame_variants_data.dart';

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

  static FrameVariantModel? getDefaultFrameVariant(String deviceId) {
    // First try to get a real frame variant
    final variants = getFrameVariants(deviceId);
    final realFrameVariants = variants.where((variant) => !variant.isGeneric).toList();
    
    if (realFrameVariants.isNotEmpty) {
      return realFrameVariants.first;
    }
    
    // Fallback to generic frame variant
    final genericVariants = variants.where((variant) => variant.isGeneric).toList();
    return genericVariants.isNotEmpty ? genericVariants.first : null;
  }

  static FrameVariantModel? getGenericFrameVariant(String deviceId) {
    final variants = getFrameVariants(deviceId);
    return variants.where((variant) => variant.isGeneric).firstOrNull;
  }

  static bool hasRealFrameVariants(String deviceId) {
    final variants = getFrameVariants(deviceId);
    return variants.any((variant) => !variant.isGeneric);
  }

  static List<FrameVariantModel> getRealFrameVariants(String deviceId) {
    final variants = getFrameVariants(deviceId);
    return variants.where((variant) => !variant.isGeneric).toList();
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