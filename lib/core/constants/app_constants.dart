import 'package:flutter/material.dart';
import '../../features/shared/models/device_model.dart';
import '../../features/shared/data/devices_data.dart';
import '../../features/shared/data/languages_data.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'App Screenshot Studio';
  static const String appVersion = '0.1.0';

  // Limits
  static const int maxProjectsPerUser = 50;
  static const int maxExportsPerMonth = 200;

  // Supported platforms (enum values as strings)
  static List<String> get supportedPlatforms => 
      Platform.values.map((p) => p.id).toList();

  // Device access helpers
  static List<DeviceModel> get allDevices => DevicesData.allDevices;
  
  static List<DeviceModel> getDevicesByPlatform(Platform platform) => 
      DevicesData.getDevicesByPlatform(platform);
  
  static List<String> getDeviceIdsByPlatform(Platform platform) => 
      DevicesData.getDeviceIdsByPlatform(platform);

  // Language access helpers
  static List<String> get supportedLanguageCodes => 
      LanguagesData.getAllLanguageCodes();
  
  static List<String> get defaultLanguages => ['en'];
  
  static List<String> get popularLanguages => [
    'en', 'es', 'fr', 'de', 'zh-Hans', 'ja', 'pt', 'ar'
  ];

  // Legacy device mapping for backward compatibility
  @Deprecated('Use DevicesData.getDevicesByPlatform() instead')
  static const Map<String, List<String>> devicesByPlatform = {
    'android': [
      'Galaxy S8',
      'Pixel 3', 
      'OnePlus 6',
      'Pixel 3 XL',
      'Galaxy S10',
      'Nexus 6',
    ],
    'ios': [
      'iPhone 14 Pro',
      'iPhone 13',
      'iPhone 12',
      'iPad Pro',
    ],
  };

  // Colors
  static const Color primaryColor = Color(0xFF4ECDC4); // Teal/Blue
  static const Color backgroundLight = Color(0xFFF6F7F9);
  static const Color textDark = Color(0xFF333333);
}


