import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'App Screenshot Studio';
  static const String appVersion = '0.1.0';

  // Limits
  static const int maxProjectsPerUser = 50;
  static const int maxExportsPerMonth = 200;

  // Supported platforms
  static const List<String> supportedPlatforms = <String>['android', 'ios'];

  // Device definitions by platform
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


