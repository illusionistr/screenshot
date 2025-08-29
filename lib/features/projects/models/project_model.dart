import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/device_model.dart';
import '../../shared/models/screenshot_model.dart';
import '../../shared/data/devices_data.dart';
import '../../editor/models/text_models.dart';
import 'project_screen_config.dart';

class ProjectModel {
  final String id;
  final String userId;
  final String appName;
  final List<String> platforms;
  final List<String> deviceIds; // List of device IDs using new device model
  final List<String> supportedLanguages; // List of language codes
  final Map<String, Map<String, List<ScreenshotModel>>> screenshots; // Language → Device → Screenshots
  // New per-screen persistent configuration (background, text, layout, assigned screenshot)
  final Map<String, ProjectScreenConfig> screenConfigs; // Screen ID → Screen Config
  final List<String> screenOrder; // Ordering of screen IDs
  // (Legacy) standalone text configs kept for now until fully removed from code
  final Map<String, ScreenTextConfig> screenTextConfigs; // Screen ID → Text Configuration
  final DateTime createdAt;
  final DateTime updatedAt;

  // Legacy field for backward compatibility during migration
  final Map<String, List<String>>? legacyDevices;

  const ProjectModel({
    required this.id,
    required this.userId,
    required this.appName,
    required this.platforms,
    required this.deviceIds,
    required this.supportedLanguages,
    required this.screenshots,
    this.screenConfigs = const {},
    this.screenOrder = const [],
    this.screenTextConfigs = const {},
    required this.createdAt,
    required this.updatedAt,
    this.legacyDevices,
  });

  ProjectModel copyWith({
    String? appName,
    List<String>? platforms,
    List<String>? deviceIds,
    List<String>? supportedLanguages,
    Map<String, Map<String, List<ScreenshotModel>>>? screenshots,
    Map<String, ProjectScreenConfig>? screenConfigs,
    List<String>? screenOrder,
    Map<String, ScreenTextConfig>? screenTextConfigs,
    DateTime? updatedAt,
    Map<String, List<String>>? legacyDevices,
  }) {
    return ProjectModel(
      id: id,
      userId: userId,
      appName: appName ?? this.appName,
      platforms: platforms ?? this.platforms,
      deviceIds: deviceIds ?? this.deviceIds,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      screenshots: screenshots ?? this.screenshots,
      screenConfigs: screenConfigs ?? this.screenConfigs,
      screenOrder: screenOrder ?? this.screenOrder,
      screenTextConfigs: screenTextConfigs ?? this.screenTextConfigs,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      legacyDevices: legacyDevices ?? this.legacyDevices,
    );
  }

  factory ProjectModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    // Handle migration from old structure to new structure
    List<String> deviceIds = [];
    Map<String, List<String>>? legacyDevices;
    
    if (data.containsKey('deviceIds')) {
      // New structure
      deviceIds = List<String>.from(data['deviceIds'] as List? ?? []);
    } else if (data.containsKey('devices')) {
      // Legacy structure - keep for backward compatibility
      final rawDevices = Map<String, dynamic>.from(data['devices'] as Map);
      legacyDevices = rawDevices.map((key, value) => MapEntry(key, List<String>.from(value as List)));
      
      // For legacy projects, attempt to migrate device names to IDs
      deviceIds = _migrateLegacyDevicesToIds(legacyDevices);
    }
    
    // Parse screenshots data
    Map<String, Map<String, List<ScreenshotModel>>> screenshots = {};
    if (data.containsKey('screenshots')) {
      final rawScreenshots = Map<String, dynamic>.from(data['screenshots'] as Map? ?? {});
      for (final languageEntry in rawScreenshots.entries) {
        final languageCode = languageEntry.key;
        final devicesMap = Map<String, dynamic>.from(languageEntry.value as Map? ?? {});
        screenshots[languageCode] = {};
        
        for (final deviceEntry in devicesMap.entries) {
          final deviceId = deviceEntry.key;
          final screenshotsList = List<dynamic>.from(deviceEntry.value as List? ?? []);
          screenshots[languageCode]![deviceId] = screenshotsList
              .map((s) => ScreenshotModel.fromMap(Map<String, dynamic>.from(s as Map)))
              .toList();
        }
      }
    }
    
    // Parse new per-screen configs
    Map<String, ProjectScreenConfig> screenConfigs = {};
    if (data.containsKey('screenConfigs')) {
      final raw = Map<String, dynamic>.from(data['screenConfigs'] as Map? ?? {});
      for (final e in raw.entries) {
        final screenId = e.key;
        final cfg = Map<String, dynamic>.from(e.value as Map);
        screenConfigs[screenId] = ProjectScreenConfig.fromJson(screenId, cfg);
      }
    }

    // (Optional legacy) Parse screen text configurations
    Map<String, ScreenTextConfig> screenTextConfigs = {};
    if (data.containsKey('screenTextConfigs')) {
      final rawConfigs = Map<String, dynamic>.from(data['screenTextConfigs'] as Map? ?? {});
      for (final entry in rawConfigs.entries) {
        final screenId = entry.key;
        final configData = Map<String, dynamic>.from(entry.value as Map);
        screenTextConfigs[screenId] = ScreenTextConfig.fromJson(configData);
      }
    }

    return ProjectModel(
      id: doc.id,
      userId: data['userId'] as String,
      appName: data['appName'] as String,
      platforms: List<String>.from(data['platforms'] as List),
      deviceIds: deviceIds,
      supportedLanguages: List<String>.from(data['supportedLanguages'] as List? ?? ['en']),
      screenshots: screenshots,
      screenConfigs: screenConfigs,
      screenOrder: List<String>.from(data['screenOrder'] as List? ?? const []),
      screenTextConfigs: screenTextConfigs,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      legacyDevices: legacyDevices,
    );
  }
  
  // Helper method to migrate legacy device names to IDs
  static List<String> _migrateLegacyDevicesToIds(Map<String, List<String>> legacyDevices) {
    final deviceIds = <String>[];
    
    // Map legacy device names to new device IDs
    final deviceNameToId = {
      // iOS legacy mappings
      'iPhone 14 Pro': 'iphone-14-pro',
      'iPhone 13': 'iphone-13',
      'iPhone 12': 'iphone-12',
      'iPad Pro': 'ipad-pro-12-9',
      
      // Android legacy mappings
      'Galaxy S8': 'galaxy-s23', // Map to closest modern equivalent
      'Pixel 3': 'pixel-8',
      'OnePlus 6': 'oneplus-11',
      'Pixel 3 XL': 'pixel-8-pro',
      'Galaxy S10': 'galaxy-s24',
      'Nexus 6': 'pixel-8',
    };
    
    for (final deviceNames in legacyDevices.values) {
      for (final deviceName in deviceNames) {
        final deviceId = deviceNameToId[deviceName];
        if (deviceId != null && !deviceIds.contains(deviceId)) {
          deviceIds.add(deviceId);
        }
      }
    }
    
    return deviceIds;
  }

  Map<String, dynamic> toFirestore() {
    // Convert screenshots to Firestore format
    Map<String, dynamic> screenshotsData = {};
    for (final languageEntry in screenshots.entries) {
      final languageCode = languageEntry.key;
      screenshotsData[languageCode] = {};
      
      for (final deviceEntry in languageEntry.value.entries) {
        final deviceId = deviceEntry.key;
        screenshotsData[languageCode][deviceId] = 
            deviceEntry.value.map((screenshot) => screenshot.toMap()).toList();
      }
    }
    
    // Convert new per-screen configs
    Map<String, dynamic> screensData = {};
    for (final entry in screenConfigs.entries) {
      screensData[entry.key] = entry.value.toJson();
    }

    // (Optional legacy) Convert standalone text configurations
    Map<String, dynamic> textConfigsData = {};
    for (final entry in screenTextConfigs.entries) {
      final screenId = entry.key;
      final config = entry.value;
      textConfigsData[screenId] = config.toJson();
    }

    return {
      'userId': userId,
      'appName': appName,
      'platforms': platforms,
      'deviceIds': deviceIds,
      'supportedLanguages': supportedLanguages,
      'screenshots': screenshotsData,
      'screenConfigs': screensData,
      'screenOrder': screenOrder,
      'screenTextConfigs': textConfigsData,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      // Don't save legacy devices to Firestore for new projects
    };
  }
  
  // Helper getters for working with the new models
  List<DeviceModel> get devices {
    return deviceIds
        .map((id) => DevicesData.getDeviceById(id))
        .where((device) => device != null)
        .cast<DeviceModel>()
        .toList();
  }
  
  List<DeviceModel> getDevicesByPlatform(Platform platform) {
    return devices.where((device) => device.platform == platform).toList();
  }
  
  bool get hasLegacyDevices => legacyDevices != null && legacyDevices!.isNotEmpty;
  
  bool get isFullyMigrated => !hasLegacyDevices;

  // Screenshot helper methods
  List<ScreenshotModel> getScreenshotsForDevice(String deviceId, String languageCode) {
    return screenshots[languageCode]?[deviceId] ?? [];
  }

  List<ScreenshotModel> getAllScreenshotsForLanguage(String languageCode) {
    final languageScreenshots = screenshots[languageCode] ?? {};
    return languageScreenshots.values.expand((screenshots) => screenshots).toList();
  }

  List<ScreenshotModel> getAllScreenshots() {
    return screenshots.values
        .expand((deviceMap) => deviceMap.values)
        .expand((screenshots) => screenshots)
        .toList();
  }

  int getTotalScreenshotCount() {
    return getAllScreenshots().length;
  }

  int getScreenshotCountForLanguage(String languageCode) {
    return getAllScreenshotsForLanguage(languageCode).length;
  }

  int getScreenshotCountForDevice(String deviceId, String languageCode) {
    return getScreenshotsForDevice(deviceId, languageCode).length;
  }

  bool hasScreenshots() {
    return getTotalScreenshotCount() > 0;
  }

  bool hasScreenshotsForLanguage(String languageCode) {
    return getScreenshotCountForLanguage(languageCode) > 0;
  }

  bool hasScreenshotsForDevice(String deviceId, String languageCode) {
    return getScreenshotCountForDevice(deviceId, languageCode) > 0;
  }

  // Screen text configuration helper methods
  ScreenTextConfig? getScreenTextConfig(String screenId) {
    return screenTextConfigs[screenId];
  }

  bool hasTextConfigForScreen(String screenId) {
    return screenTextConfigs.containsKey(screenId) && 
           screenTextConfigs[screenId]!.visibleElementCount > 0;
  }

  int getTotalTextElementsCount() {
    return screenTextConfigs.values
        .map((config) => config.visibleElementCount)
        .fold(0, (sum, count) => sum + count);
  }

  List<String> getScreensWithTextElements() {
    return screenTextConfigs.entries
        .where((entry) => entry.value.visibleElementCount > 0)
        .map((entry) => entry.key)
        .toList();
  }

  bool hasAnyTextElements() {
    return getTotalTextElementsCount() > 0;
  }
}


