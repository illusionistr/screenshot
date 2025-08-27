import 'package:flutter/material.dart';

enum Platform {
  android('android', 'Android'),
  ios('ios', 'iOS');

  const Platform(this.id, this.displayName);

  final String id;
  final String displayName;

  factory Platform.fromString(String value) {
    return Platform.values.firstWhere(
      (platform) => platform.id == value,
      orElse: () => throw ArgumentError('Unknown platform: $value'),
    );
  }
}

class DeviceModel {
  final String id;
  final String name;
  final Platform platform;
  final int frameWidth;
  final int frameHeight;
  final int screenWidth;
  final int screenHeight;
  final Offset screenPosition;
  final List<String> availableFrames;
  final String appStoreDisplaySize;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.platform,
    required this.frameWidth,
    required this.frameHeight,
    required this.screenWidth,
    required this.screenHeight,
    required this.screenPosition,
    required this.availableFrames,
    required this.appStoreDisplaySize,
  });

  DeviceModel copyWith({
    String? id,
    String? name,
    Platform? platform,
    int? frameWidth,
    int? frameHeight,
    int? screenWidth,
    int? screenHeight,
    Offset? screenPosition,
    List<String>? availableFrames,
    String? appStoreDisplaySize,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      frameWidth: frameWidth ?? this.frameWidth,
      frameHeight: frameHeight ?? this.frameHeight,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
      screenPosition: screenPosition ?? this.screenPosition,
      availableFrames: availableFrames ?? this.availableFrames,
      appStoreDisplaySize: appStoreDisplaySize ?? this.appStoreDisplaySize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'platform': platform.id,
      'frameWidth': frameWidth,
      'frameHeight': frameHeight,
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'screenPosition': {
        'dx': screenPosition.dx,
        'dy': screenPosition.dy,
      },
      'availableFrames': availableFrames,
      'appStoreDisplaySize': appStoreDisplaySize,
    };
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    final screenPos = json['screenPosition'] as Map<String, dynamic>;
    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      platform: Platform.fromString(json['platform'] as String),
      frameWidth: json['frameWidth'] as int,
      frameHeight: json['frameHeight'] as int,
      screenWidth: json['screenWidth'] as int,
      screenHeight: json['screenHeight'] as int,
      screenPosition: Offset(
        (screenPos['dx'] as num).toDouble(),
        (screenPos['dy'] as num).toDouble(),
      ),
      availableFrames: List<String>.from(json['availableFrames'] as List),
      appStoreDisplaySize: json['appStoreDisplaySize'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceModel &&
        other.id == id &&
        other.name == name &&
        other.platform == platform &&
        other.frameWidth == frameWidth &&
        other.frameHeight == frameHeight &&
        other.screenWidth == screenWidth &&
        other.screenHeight == screenHeight &&
        other.screenPosition == screenPosition &&
        other.availableFrames.length == availableFrames.length &&
        other.availableFrames.every((frame) => availableFrames.contains(frame)) &&
        other.appStoreDisplaySize == appStoreDisplaySize;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      platform,
      frameWidth,
      frameHeight,
      screenWidth,
      screenHeight,
      screenPosition,
      availableFrames,
      appStoreDisplaySize,
    );
  }

  @override
  String toString() {
    return 'DeviceModel(id: $id, name: $name, platform: ${platform.displayName})';
  }

  double get aspectRatio => screenWidth / screenHeight;
  
  bool get isTablet => name.toLowerCase().contains('ipad') || (screenWidth > 1600 && screenHeight > 2000);
  
  bool get isPhone => !isTablet;
}