import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/device_model.dart';
import '../../shared/data/devices_data.dart';

class ProjectModel {
  final String id;
  final String userId;
  final String appName;
  final List<String> platforms;
  final List<String> deviceIds; // List of device IDs using new device model
  final List<String> supportedLanguages; // List of language codes
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
    required this.createdAt,
    required this.updatedAt,
    this.legacyDevices,
  });

  ProjectModel copyWith({
    String? appName,
    List<String>? platforms,
    List<String>? deviceIds,
    List<String>? supportedLanguages,
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
    
    return ProjectModel(
      id: doc.id,
      userId: data['userId'] as String,
      appName: data['appName'] as String,
      platforms: List<String>.from(data['platforms'] as List),
      deviceIds: deviceIds,
      supportedLanguages: List<String>.from(data['supportedLanguages'] as List? ?? ['en']),
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
    return {
      'userId': userId,
      'appName': appName,
      'platforms': platforms,
      'deviceIds': deviceIds,
      'supportedLanguages': supportedLanguages,
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
}


