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

  // Language options
  static const List<Map<String, String>> supportedLanguages = [
    {"code": "en_US", "name": "English (U.S.)"},
    {"code": "es_ES", "name": "Spanish (Spain)"},
    {"code": "fr_FR", "name": "French (France)"},
    {"code": "de_DE", "name": "German (Germany)"},
  ];

  // Default screen settings
  static const Map<String, dynamic> defaultScreenSettings = {
    "background": {"type": "gradient", "gradientStart": "#FF9966", "gradientEnd": "#FF5E62"},
    "layout": {"mode": "text_above", "orientation": "portrait", "frameStyle": "flat_black"},
    "text": {"alignment": "center", "containerHeight": 15.0},
    "device": {"margins": {"top": 2.0, "bottom": 2.0, "left": 10.0, "right": 10.0}, "angle": 0.0},
    "font": {"family": "Raleway", "size": 40.0, "weight": "Regular", "color": "#FFFFFF"}
  };

  // Colors
  static const Color primaryColor = Color(0xFF4ECDC4); // Teal/Blue
  static const Color backgroundLight = Color(0xFFF6F7F9);
  static const Color textDark = Color(0xFF333333);
}


