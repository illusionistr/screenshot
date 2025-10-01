import 'package:flutter/material.dart';

import '../../projects/models/project_model.dart';
import '../../shared/models/device_model.dart';
import '../constants/platform_dimensions.dart';
import 'background_models.dart';
import 'text_element_state.dart';
import 'text_models.dart';

// Editor tab enum
enum EditorTab {
  text,
  uploads,
  layouts,
  background,
  template,
}

// Background tab enum
enum BackgroundTab {
  color,
  gradient,
  image,
}

class EditorState {
  final String caption;
  final String fontFamily;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final Color textColor;
  final String selectedLanguage;
  final String selectedDevice;
  final List<ScreenshotItem> screenshots;
  final EditorTab selectedTab;
  final BackgroundTab selectedBackgroundTab;
  final Color solidBackgroundColor;
  final Color gradientStartColor;
  final Color gradientEndColor;
  final String gradientDirection;

  // Project-related data
  final ProjectModel? project;
  final List<String> availableLanguages;
  final List<DeviceModel> availableDevices;

  // Screen management
  final List<ScreenConfig> screens;
  final int? selectedScreenIndex;
  final PlatformDimensions currentDimensions;

  // Text element management
  final TextElementState textElementState;

  // Layout management
  final String selectedLayoutId;
  final String selectedFrameVariant;

  const EditorState({
    this.caption = '',
    this.fontFamily = 'Inter',
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
    this.textColor = Colors.black,
    this.selectedLanguage = 'en',
    this.selectedDevice = '',
    this.screenshots = const [],
    this.selectedTab = EditorTab.text,
    this.selectedBackgroundTab = BackgroundTab.gradient,
    this.solidBackgroundColor = Colors.white,
    this.gradientStartColor = Colors.white,
    this.gradientEndColor = Colors.white,
    this.gradientDirection = 'vertical',
    this.project,
    this.availableLanguages = const [],
    this.availableDevices = const [],
    this.screens = const [],
    this.selectedScreenIndex,
    this.currentDimensions = const PlatformDimensions(
      width: 1290,
      height: 2796,
      deviceType: DeviceType.iphonePortrait,
    ),
    this.textElementState = const TextElementState(),
    this.selectedLayoutId = 'centered_above',
    this.selectedFrameVariant =
        '', // Changed from 'generic' to empty string - will be set dynamically
  });

  EditorState copyWith({
    String? caption,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    Color? textColor,
    String? selectedLanguage,
    String? selectedDevice,
    List<ScreenshotItem>? screenshots,
    EditorTab? selectedTab,
    BackgroundTab? selectedBackgroundTab,
    Color? solidBackgroundColor,
    Color? gradientStartColor,
    Color? gradientEndColor,
    String? gradientDirection,
    ProjectModel? project,
    List<String>? availableLanguages,
    List<DeviceModel>? availableDevices,
    List<ScreenConfig>? screens,
    int? selectedScreenIndex,
    PlatformDimensions? currentDimensions,
    TextElementState? textElementState,
    String? selectedLayoutId,
    String? selectedFrameVariant,
  }) {
    return EditorState(
      caption: caption ?? this.caption,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      textAlign: textAlign ?? this.textAlign,
      textColor: textColor ?? this.textColor,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedDevice: selectedDevice ?? this.selectedDevice,
      screenshots: screenshots ?? this.screenshots,
      selectedTab: selectedTab ?? this.selectedTab,
      selectedBackgroundTab:
          selectedBackgroundTab ?? this.selectedBackgroundTab,
      solidBackgroundColor: solidBackgroundColor ?? this.solidBackgroundColor,
      gradientStartColor: gradientStartColor ?? this.gradientStartColor,
      gradientEndColor: gradientEndColor ?? this.gradientEndColor,
      gradientDirection: gradientDirection ?? this.gradientDirection,
      project: project ?? this.project,
      availableLanguages: availableLanguages ?? this.availableLanguages,
      availableDevices: availableDevices ?? this.availableDevices,
      screens: screens ?? this.screens,
      selectedScreenIndex: selectedScreenIndex ?? this.selectedScreenIndex,
      currentDimensions: currentDimensions ?? this.currentDimensions,
      textElementState: textElementState ?? this.textElementState,
      selectedLayoutId: selectedLayoutId ?? this.selectedLayoutId,
      selectedFrameVariant: selectedFrameVariant ?? this.selectedFrameVariant,
    );
  }
}

class ScreenshotItem {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;
  final Color backgroundColor;
  final Color gradientColor;

  const ScreenshotItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.backgroundColor,
    required this.gradientColor,
  });
}

class ScreenConfig {
  final String id;
  final Color backgroundColor; // Legacy field, kept for compatibility
  final bool isLandscape;
  final String? backgroundImagePath; // Legacy field, kept for compatibility
  final Map<String, dynamic> customSettings;
  final ScreenBackground background;
  final ScreenTextConfig textConfig;

  // Language+Device aware screenshot assignment (matching screenshot storage pattern)
  final String? fallbackScreenshotId; // Global default for ALL languages & devices (first assignment)
  final Map<String, Map<String, String>> assignedScreenshotsByLanguage; // language → device → screenshotId

  // Legacy fields for backward compatibility
  @Deprecated('Use fallbackScreenshotId or assignedScreenshotsByLanguage instead')
  final String? assignedScreenshotId;
  @Deprecated('Migrated to assignedScreenshotsByLanguage')
  final Map<String, String>? assignedScreenshotsByDevice;

  final String layoutId; // ID of selected layout (never null, has default)

  const ScreenConfig({
    required this.id,
    this.backgroundColor = Colors.white,
    this.isLandscape = false,
    this.backgroundImagePath,
    this.customSettings = const {},
    this.background = ScreenBackground.defaultBackground,
    this.textConfig = const ScreenTextConfig(),
    this.fallbackScreenshotId,
    this.assignedScreenshotsByLanguage = const {},
    @Deprecated('Use fallbackScreenshotId or assignedScreenshotsByLanguage instead')
    this.assignedScreenshotId,
    @Deprecated('Migrated to assignedScreenshotsByLanguage')
    this.assignedScreenshotsByDevice,
    String? layoutId, // Keep nullable in constructor for backward compatibility
  }) : layoutId =
            layoutId ?? 'centered_above'; // Use default layout if not provided

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

  ScreenConfig copyWith({
    String? id,
    Color? backgroundColor,
    bool? isLandscape,
    String? backgroundImagePath,
    Map<String, dynamic>? customSettings,
    ScreenBackground? background,
    ScreenTextConfig? textConfig,
    String? fallbackScreenshotId,
    bool clearFallbackScreenshotId = false,
    Map<String, Map<String, String>>? assignedScreenshotsByLanguage,
    // Legacy support
    @Deprecated('Use fallbackScreenshotId instead')
    String? assignedScreenshotId,
    @Deprecated('Migrated to assignedScreenshotsByLanguage')
    Map<String, String>? assignedScreenshotsByDevice,
    String? layoutId, // Keep nullable in copyWith for flexibility
  }) {
    return ScreenConfig(
      id: id ?? this.id,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isLandscape: isLandscape ?? this.isLandscape,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      customSettings: customSettings ?? this.customSettings,
      background: background ?? this.background,
      textConfig: textConfig ?? this.textConfig,
      fallbackScreenshotId:
          clearFallbackScreenshotId
            ? null
            : (fallbackScreenshotId ?? this.fallbackScreenshotId),
      assignedScreenshotsByLanguage: assignedScreenshotsByLanguage ?? this.assignedScreenshotsByLanguage,
      // ignore: deprecated_member_use_from_same_package
      assignedScreenshotId: assignedScreenshotId ?? this.assignedScreenshotId,
      // ignore: deprecated_member_use_from_same_package
      assignedScreenshotsByDevice: assignedScreenshotsByDevice ?? this.assignedScreenshotsByDevice,
      layoutId: layoutId ?? this.layoutId, // Will use default if null
    );
  }

  /// Assign a screenshot for a specific language and device (creates override)
  ScreenConfig assignScreenshotForLanguageAndDevice(
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

  /// Remove screenshot for specific language and device
  ScreenConfig removeScreenshotForLanguageAndDevice(String languageCode, String deviceId) {
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

  /// Set fallback screenshot (applies to all languages and devices)
  ScreenConfig setFallbackScreenshot(String? screenshotId) {
    return copyWith(
      fallbackScreenshotId: screenshotId,
      clearFallbackScreenshotId: screenshotId == null,
    );
  }
}

// Font weight enum for easier management
enum EditorFontWeight {
  light(FontWeight.w300, 'Light'),
  normal(FontWeight.w400, 'Normal'),
  medium(FontWeight.w500, 'Medium'),
  semiBold(FontWeight.w600, 'Semi Bold'),
  bold(FontWeight.w700, 'Bold');

  const EditorFontWeight(this.fontWeight, this.displayName);
  final FontWeight fontWeight;
  final String displayName;
}

// Text alignment enum
enum EditorTextAlign {
  left(TextAlign.left, Icons.format_align_left),
  center(TextAlign.center, Icons.format_align_center),
  right(TextAlign.right, Icons.format_align_right);

  const EditorTextAlign(this.textAlign, this.icon);
  final TextAlign textAlign;
  final IconData icon;
}
