import 'package:flutter/material.dart';

import '../../editor/models/background_models.dart';
import '../../editor/models/text_models.dart';
import '../../editor/models/editor_state.dart' show ScreenConfig;

class ProjectScreenConfig {
  final String id;
  final bool isLandscape;
  final ScreenBackground background;
  final ScreenTextConfig textConfig;
  final String layoutId;

  // Language+Device aware screenshot assignment (matching screenshot storage pattern)
  final String? fallbackScreenshotId; // Global default for ALL languages & devices (first assignment)
  final Map<String, Map<String, String>> assignedScreenshotsByLanguage; // language → device → screenshotId

  // Legacy fields for backward compatibility
  @Deprecated('Use fallbackScreenshotId or assignedScreenshotsByLanguage instead')
  final String? assignedScreenshotId;
  @Deprecated('Migrated to assignedScreenshotsByLanguage')
  final Map<String, String>? assignedScreenshotsByDevice;

  final Map<String, dynamic> customSettings; // per-screen overrides (e.g., transforms)

  const ProjectScreenConfig({
    required this.id,
    this.isLandscape = false,
    this.background = ScreenBackground.defaultBackground,
    this.textConfig = const ScreenTextConfig(),
    this.layoutId = 'centered_above',
    this.fallbackScreenshotId,
    this.assignedScreenshotsByLanguage = const {},
    @Deprecated('Use fallbackScreenshotId or assignedScreenshotsByLanguage instead')
    this.assignedScreenshotId,
    @Deprecated('Migrated to assignedScreenshotsByLanguage')
    this.assignedScreenshotsByDevice,
    this.customSettings = const {},
  });

  /// Get the screenshot ID for a specific language and device
  /// Three-tier fallback: language+device → language fallback → global fallback
  String? getScreenshotForLanguageAndDevice(String languageCode, String deviceId) {
    // 1. Check language+device specific (most specific)
    final deviceMap = assignedScreenshotsByLanguage[languageCode];
    if (deviceMap != null && deviceMap.containsKey(deviceId)) {
      return deviceMap[deviceId];
    }

    // 2. Check if there's any screenshot for this language (language fallback)
    if (deviceMap != null && deviceMap.isNotEmpty) {
      return deviceMap.values.first;
    }

    // 3. Fall back to global default (applies to all languages & devices)
    return fallbackScreenshotId;
  }

  /// Check if this screen has any screenshot assigned
  bool get hasAnyScreenshot {
    return fallbackScreenshotId != null || assignedScreenshotsByLanguage.isNotEmpty;
  }

  /// Check if a specific language+device has a custom screenshot (not using fallback)
  bool hasLanguageDeviceSpecificScreenshot(String languageCode, String deviceId) {
    return assignedScreenshotsByLanguage[languageCode]?.containsKey(deviceId) ?? false;
  }

  /// Check if a language has any screenshots assigned
  bool hasLanguageScreenshots(String languageCode) {
    final deviceMap = assignedScreenshotsByLanguage[languageCode];
    return deviceMap != null && deviceMap.isNotEmpty;
  }

  /// Get all languages that have custom screenshots
  List<String> get languagesWithCustomScreenshots {
    return assignedScreenshotsByLanguage.keys.toList();
  }

  /// Get all devices that have custom screenshots for a specific language
  List<String> getDevicesWithCustomScreenshotsForLanguage(String languageCode) {
    return assignedScreenshotsByLanguage[languageCode]?.keys.toList() ?? [];
  }

  ProjectScreenConfig copyWith({
    String? id,
    bool? isLandscape,
    ScreenBackground? background,
    ScreenTextConfig? textConfig,
    String? layoutId,
    String? fallbackScreenshotId,
    bool clearFallbackScreenshotId = false,
    Map<String, Map<String, String>>? assignedScreenshotsByLanguage,
    // Legacy support
    @Deprecated('Use fallbackScreenshotId instead')
    String? assignedScreenshotId,
    @Deprecated('Migrated to assignedScreenshotsByLanguage')
    Map<String, String>? assignedScreenshotsByDevice,
    Map<String, dynamic>? customSettings,
  }) {
    return ProjectScreenConfig(
      id: id ?? this.id,
      isLandscape: isLandscape ?? this.isLandscape,
      background: background ?? this.background,
      textConfig: textConfig ?? this.textConfig,
      layoutId: layoutId ?? this.layoutId,
      fallbackScreenshotId:
          clearFallbackScreenshotId
            ? null
            : (fallbackScreenshotId ?? this.fallbackScreenshotId),
      assignedScreenshotsByLanguage: assignedScreenshotsByLanguage ?? this.assignedScreenshotsByLanguage,
      // Legacy support - deprecated but still functional
      // ignore: deprecated_member_use_from_same_package
      assignedScreenshotId: assignedScreenshotId ?? this.assignedScreenshotId,
      // ignore: deprecated_member_use_from_same_package
      assignedScreenshotsByDevice: assignedScreenshotsByDevice ?? this.assignedScreenshotsByDevice,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  /// Assign a screenshot for a specific language and device (creates override)
  ProjectScreenConfig assignScreenshotForLanguageAndDevice(
    String languageCode,
    String deviceId,
    String screenshotId,
  ) {
    final updated = Map<String, Map<String, String>>.from(assignedScreenshotsByLanguage);
    if (!updated.containsKey(languageCode)) {
      updated[languageCode] = {};
    }
    final deviceMap = Map<String, String>.from(updated[languageCode]!);
    deviceMap[deviceId] = screenshotId;
    updated[languageCode] = deviceMap;
    return copyWith(assignedScreenshotsByLanguage: updated);
  }

  /// Remove screenshot for specific language and device (falls back to language or global fallback)
  ProjectScreenConfig removeScreenshotForLanguageAndDevice(String languageCode, String deviceId) {
    final updated = Map<String, Map<String, String>>.from(assignedScreenshotsByLanguage);
    if (updated.containsKey(languageCode)) {
      final deviceMap = Map<String, String>.from(updated[languageCode]!);
      deviceMap.remove(deviceId);
      if (deviceMap.isEmpty) {
        updated.remove(languageCode);
      } else {
        updated[languageCode] = deviceMap;
      }
    }
    return copyWith(assignedScreenshotsByLanguage: updated);
  }

  /// Remove all screenshots for a specific language
  ProjectScreenConfig removeScreenshotsForLanguage(String languageCode) {
    final updated = Map<String, Map<String, String>>.from(assignedScreenshotsByLanguage);
    updated.remove(languageCode);
    return copyWith(assignedScreenshotsByLanguage: updated);
  }

  /// Set fallback screenshot (applies to all languages and devices)
  ProjectScreenConfig setFallbackScreenshot(String? screenshotId) {
    return copyWith(
      fallbackScreenshotId: screenshotId,
      clearFallbackScreenshotId: screenshotId == null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isLandscape': isLandscape,
      'background': background.toJson(),
      'textConfig': textConfig.toJson(),
      'layoutId': layoutId,
      'fallbackScreenshotId': fallbackScreenshotId,
      'assignedScreenshotsByLanguage': assignedScreenshotsByLanguage,
      // Keep legacy fields for backward compatibility during transition
      // ignore: deprecated_member_use_from_same_package
      'assignedScreenshotId': assignedScreenshotId,
      // ignore: deprecated_member_use_from_same_package
      'assignedScreenshotsByDevice': assignedScreenshotsByDevice,
      'customSettings': customSettings,
    };
  }

  static ProjectScreenConfig fromJson(String id, Map<String, dynamic> json) {
    // Migration logic: convert old structures to new language+device structure
    String? fallbackId = json['fallbackScreenshotId'] as String?;
    String? legacyId = json['assignedScreenshotId'] as String?;

    // If we have the new field, use it; otherwise migrate from legacy
    if (fallbackId == null && legacyId != null) {
      fallbackId = legacyId;
    }

    // Parse language+device screenshots (new structure)
    Map<String, Map<String, String>> languageDeviceScreenshots = {};
    if (json['assignedScreenshotsByLanguage'] != null) {
      final raw = json['assignedScreenshotsByLanguage'] as Map;
      for (final entry in raw.entries) {
        final languageCode = entry.key as String;
        final deviceMap = entry.value as Map;
        languageDeviceScreenshots[languageCode] = Map<String, String>.from(deviceMap);
      }
    }

    // Migration: convert old device-only structure to new language+device structure
    Map<String, String>? oldDeviceScreenshots;
    if (json['assignedScreenshotsByDevice'] != null) {
      final raw = json['assignedScreenshotsByDevice'] as Map;
      oldDeviceScreenshots = Map<String, String>.from(raw);

      // If we have old device screenshots but no new language+device structure,
      // migrate them to the first/default language (will be updated on first save)
      if (languageDeviceScreenshots.isEmpty && oldDeviceScreenshots.isNotEmpty) {
        // We'll need the project's languages to properly migrate, but for now
        // we'll just keep the old structure and let the runtime handle it
      }
    }

    return ProjectScreenConfig(
      id: id,
      isLandscape: json['isLandscape'] as bool? ?? false,
      background: json['background'] != null
          ? ScreenBackground.fromJson(Map<String, dynamic>.from(json['background'] as Map))
          : ScreenBackground.defaultBackground,
      textConfig: json['textConfig'] != null
          ? ScreenTextConfig.fromJson(Map<String, dynamic>.from(json['textConfig'] as Map))
          : const ScreenTextConfig(),
      layoutId: json['layoutId'] as String? ?? 'centered_above',
      fallbackScreenshotId: fallbackId,
      assignedScreenshotsByLanguage: languageDeviceScreenshots,
      // Keep legacy fields for backward compatibility
      // ignore: deprecated_member_use_from_same_package
      assignedScreenshotId: legacyId,
      // ignore: deprecated_member_use_from_same_package
      assignedScreenshotsByDevice: oldDeviceScreenshots,
      customSettings: Map<String, dynamic>.from(json['customSettings'] as Map? ?? const {}),
    );
  }

  static ProjectScreenConfig fromScreenConfig(ScreenConfig screen) {
    return ProjectScreenConfig(
      id: screen.id,
      isLandscape: screen.isLandscape,
      background: screen.background,
      textConfig: screen.textConfig,
      layoutId: screen.layoutId,
      fallbackScreenshotId: screen.fallbackScreenshotId,
      assignedScreenshotsByLanguage: screen.assignedScreenshotsByLanguage,
      // ignore: deprecated_member_use_from_same_package
      assignedScreenshotId: screen.assignedScreenshotId,
      // ignore: deprecated_member_use_from_same_package
      assignedScreenshotsByDevice: screen.assignedScreenshotsByDevice,
      customSettings: screen.customSettings,
    );
  }

  static ScreenConfig toScreenConfig(ProjectScreenConfig p) {
    return ScreenConfig(
      id: p.id,
      isLandscape: p.isLandscape,
      background: p.background,
      textConfig: p.textConfig,
      layoutId: p.layoutId,
      fallbackScreenshotId: p.fallbackScreenshotId,
      assignedScreenshotsByLanguage: p.assignedScreenshotsByLanguage,
      // ignore: deprecated_member_use_from_same_package
      assignedScreenshotId: p.assignedScreenshotId,
      // ignore: deprecated_member_use_from_same_package
      assignedScreenshotsByDevice: p.assignedScreenshotsByDevice,
      backgroundColor: Colors.white,
      customSettings: p.customSettings,
    );
  }
}

