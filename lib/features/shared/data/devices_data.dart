import 'package:flutter/material.dart';

import '../models/device_model.dart';

class DevicesData {
  DevicesData._();

  static const List<DeviceModel> allDevices = [
    // iOS Devices
    DeviceModel(
      id: 'iphone-15-pro',
      name: 'iPhone 15 Pro',
      platform: Platform.ios,
      frameWidth: 1312,
      frameHeight: 2688,
      screenWidth: 1290,
      screenHeight: 2796,
      screenPosition: Offset(11, 46),
      availableFrames: [
        'natural-titanium',
        'blue-titanium',
        'white-titanium',
        'black-titanium'
      ],
      appStoreDisplaySize: '6.1-inch',
    ),
    DeviceModel(
      id: 'iphone-15-pro-max',
      name: 'iPhone 15 Pro Max',
      platform: Platform.ios,
      frameWidth: 1424,
      frameHeight: 2912,
      screenWidth: 1290,
      screenHeight: 2796,
      screenPosition: Offset(67, 58),
      availableFrames: [
        'natural-titanium',
        'blue-titanium',
        'white-titanium',
        'black-titanium'
      ],
      appStoreDisplaySize: '6.7-inch',
    ),
    DeviceModel(
      id: 'iphone-14',
      name: 'iPhone 14',
      platform: Platform.ios,
      frameWidth: 1195,
      frameHeight: 2436,
      screenWidth: 1170,
      screenHeight: 2532,
      screenPosition: Offset(13, 52),
      availableFrames: ['blue', 'purple', 'midnight', 'starlight', 'red'],
      appStoreDisplaySize: '6.1-inch',
    ),
    DeviceModel(
      id: 'iphone-14-pro',
      name: 'iPhone 14 Pro',
      platform: Platform.ios,
      frameWidth: 1195,
      frameHeight: 2436,
      screenWidth: 1290,
      screenHeight: 2796,
      screenPosition: Offset(13, 52),
      availableFrames: ['deep-purple', 'gold', 'silver', 'space-black'],
      appStoreDisplaySize: '6.1-inch',
    ),
    DeviceModel(
      id: 'iphone-14-pro-max',
      name: 'iPhone 14 Pro Max',
      platform: Platform.ios,
      frameWidth: 1307,
      frameHeight: 2668,
      screenWidth: 1290,
      screenHeight: 2796,
      screenPosition: Offset(9, 66),
      availableFrames: ['deep-purple', 'gold', 'silver', 'space-black'],
      appStoreDisplaySize: '6.7-inch',
    ),
    DeviceModel(
      id: 'iphone-13',
      name: 'iPhone 13',
      platform: Platform.ios,
      frameWidth: 1195,
      frameHeight: 2436,
      screenWidth: 1170,
      screenHeight: 2532,
      screenPosition: Offset(13, 52),
      availableFrames: ['pink', 'blue', 'midnight', 'starlight', 'red'],
      appStoreDisplaySize: '6.1-inch',
    ),
    DeviceModel(
      id: 'iphone-13-pro',
      name: 'iPhone 13 Pro',
      platform: Platform.ios,
      frameWidth: 1195,
      frameHeight: 2436,
      screenWidth: 1170,
      screenHeight: 2532,
      screenPosition: Offset(13, 52),
      availableFrames: ['graphite', 'gold', 'silver', 'sierra-blue'],
      appStoreDisplaySize: '6.1-inch',
    ),
    DeviceModel(
      id: 'iphone-13-pro-max',
      name: 'iPhone 13 Pro Max',
      platform: Platform.ios,
      frameWidth: 1307,
      frameHeight: 2668,
      screenWidth: 1284,
      screenHeight: 2778,
      screenPosition: Offset(12, 65),
      availableFrames: ['graphite', 'gold', 'silver', 'sierra-blue'],
      appStoreDisplaySize: '6.7-inch',
    ),
    DeviceModel(
      id: 'iphone-12',
      name: 'iPhone 12',
      platform: Platform.ios,
      frameWidth: 1195,
      frameHeight: 2436,
      screenWidth: 1170,
      screenHeight: 2532,
      screenPosition: Offset(13, 52),
      availableFrames: ['black', 'white', 'red', 'green', 'blue', 'purple'],
      appStoreDisplaySize: '6.1-inch',
    ),
    DeviceModel(
      id: 'iphone-12-pro-max',
      name: 'iPhone 12 Pro Max',
      platform: Platform.ios,
      frameWidth: 1307,
      frameHeight: 2668,
      screenWidth: 1284,
      screenHeight: 2778,
      screenPosition: Offset(12, 65),
      availableFrames: ['graphite', 'silver', 'gold', 'pacific-blue'],
      appStoreDisplaySize: '6.7-inch',
    ),
    DeviceModel(
      id: 'ipad-pro-12-9',
      name: 'iPad Pro 12.9"',
      platform: Platform.ios,
      frameWidth: 2266,
      frameHeight: 3036,
      screenWidth: 2048,
      screenHeight: 2732,
      screenPosition: Offset(109, 152),
      availableFrames: ['silver', 'space-gray'],
      appStoreDisplaySize: '12.9-inch',
    ),
    DeviceModel(
      id: 'ipad-pro-11',
      name: 'iPad Pro 11"',
      platform: Platform.ios,
      frameWidth: 1850,
      frameHeight: 2482,
      screenWidth: 1668,
      screenHeight: 2388,
      screenPosition: Offset(91, 47),
      availableFrames: ['silver', 'space-gray'],
      appStoreDisplaySize: '11-inch',
    ),
    DeviceModel(
      id: 'ipad-air',
      name: 'iPad Air',
      platform: Platform.ios,
      frameWidth: 1850,
      frameHeight: 2482,
      screenWidth: 1620,
      screenHeight: 2160,
      screenPosition: Offset(115, 161),
      availableFrames: ['space-gray', 'starlight', 'pink', 'purple', 'blue'],
      appStoreDisplaySize: '10.9-inch',
    ),

    // Android Devices
    DeviceModel(
      id: 'pixel-8-pro',
      name: 'Pixel 8 Pro',
      platform: Platform.android,
      frameWidth: 1344,
      frameHeight: 2992,
      screenWidth: 1200,
      screenHeight: 2700,
      screenPosition: Offset(72, 146),
      availableFrames: ['obsidian', 'porcelain', 'bay', 'mint'],
      appStoreDisplaySize: '6.7-inch',
    ),
    DeviceModel(
      id: 'pixel-8',
      name: 'Pixel 8',
      platform: Platform.android,
      frameWidth: 1200,
      frameHeight: 2400,
      screenWidth: 1000,
      screenHeight: 2200,
      screenPosition: Offset(90, 160),
      availableFrames: ['obsidian', 'hazel', 'rose'],
      appStoreDisplaySize: '6.2-inch',
    ),
    DeviceModel(
      id: 'pixel-7-pro',
      name: 'Pixel 7 Pro',
      platform: Platform.android,
      frameWidth: 1440,
      frameHeight: 3120,
      screenWidth: 1440,
      screenHeight: 3120,
      screenPosition: Offset(0, 0),
      availableFrames: ['obsidian', 'snow', 'hazel'],
      appStoreDisplaySize: '6.7-inch',
    ),
    DeviceModel(
      id: 'pixel-7',
      name: 'Pixel 7',
      platform: Platform.android,
      frameWidth: 1080,
      frameHeight: 2400,
      screenWidth: 1080,
      screenHeight: 2400,
      screenPosition: Offset(0, 0),
      availableFrames: ['obsidian', 'snow', 'lemongrass'],
      appStoreDisplaySize: '6.3-inch',
    ),
    DeviceModel(
      id: 'galaxy-s24-ultra',
      name: 'Galaxy S24 Ultra',
      platform: Platform.android,
      frameWidth: 1440,
      frameHeight: 3120,
      screenWidth: 1440,
      screenHeight: 3120,
      screenPosition: Offset(0, 0),
      availableFrames: [
        'titanium-black',
        'titanium-gray',
        'titanium-violet',
        'titanium-yellow'
      ],
      appStoreDisplaySize: '6.8-inch',
    ),
    DeviceModel(
      id: 'galaxy-s24',
      name: 'Galaxy S24',
      platform: Platform.android,
      frameWidth: 1080,
      frameHeight: 2340,
      screenWidth: 1080,
      screenHeight: 2340,
      screenPosition: Offset(0, 0),
      availableFrames: [
        'onyx-black',
        'marble-gray',
        'cobalt-violet',
        'amber-yellow'
      ],
      appStoreDisplaySize: '6.2-inch',
    ),
    DeviceModel(
      id: 'galaxy-s23-ultra',
      name: 'Galaxy S23 Ultra',
      platform: Platform.android,
      frameWidth: 1440,
      frameHeight: 3088,
      screenWidth: 1440,
      screenHeight: 3088,
      screenPosition: Offset(0, 0),
      availableFrames: ['phantom-black', 'cream', 'green', 'lavender'],
      appStoreDisplaySize: '6.8-inch',
    ),
    DeviceModel(
      id: 'galaxy-s23',
      name: 'Galaxy S23',
      platform: Platform.android,
      frameWidth: 1080,
      frameHeight: 2340,
      screenWidth: 1080,
      screenHeight: 2340,
      screenPosition: Offset(0, 0),
      availableFrames: ['phantom-black', 'cream', 'green', 'lavender'],
      appStoreDisplaySize: '6.1-inch',
    ),
    DeviceModel(
      id: 'oneplus-11',
      name: 'OnePlus 11',
      platform: Platform.android,
      frameWidth: 1440,
      frameHeight: 3216,
      screenWidth: 1440,
      screenHeight: 3216,
      screenPosition: Offset(0, 0),
      availableFrames: ['titan-black', 'eternal-green'],
      appStoreDisplaySize: '6.7-inch',
    ),
    DeviceModel(
      id: 'oneplus-10-pro',
      name: 'OnePlus 10 Pro',
      platform: Platform.android,
      frameWidth: 1440,
      frameHeight: 3216,
      screenWidth: 1440,
      screenHeight: 3216,
      screenPosition: Offset(0, 0),
      availableFrames: ['volcanic-black', 'emerald-forest'],
      appStoreDisplaySize: '6.7-inch',
    ),
     DeviceModel(
      id: '-galaxy-tab-a-10.1',
      name: 'Galaxy Tab A 10.1',
      platform: Platform.android,
      frameWidth: 1494,
      frameHeight: 2452,
      screenWidth: 1200,
      screenHeight: 1920,
      screenPosition: Offset(0, 0),
      availableFrames: ['black', 'gold', 'silver'],
      appStoreDisplaySize: '10.1-inch',
    ),
    DeviceModel(
      id: 'pixel-tablet',
      name: 'Pixel Tablet',
      platform: Platform.android,
      frameWidth: 1690,
      frameHeight: 2580,
      screenWidth: 1600,
      screenHeight: 2560,
      screenPosition: Offset(45, 10),
      availableFrames: ['porcelain', 'hazel'],
      appStoreDisplaySize: '10.95-inch',
    )
  ];

  static List<DeviceModel> getDevicesByPlatform(Platform platform) {
    return allDevices.where((device) => device.platform == platform).toList();
  }

  static List<DeviceModel> getPhones() {
    return allDevices.where((device) => device.isPhone).toList();
  }

  static List<DeviceModel> getTablets() {
    return allDevices.where((device) => device.isTablet).toList();
  }

  static DeviceModel? getDeviceById(String id) {
    try {
      return allDevices.firstWhere((device) => device.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<String> getAllDeviceIds() {
    return allDevices.map((device) => device.id).toList();
  }

  static List<String> getDeviceIdsByPlatform(Platform platform) {
    return getDevicesByPlatform(platform).map((device) => device.id).toList();
  }
}
