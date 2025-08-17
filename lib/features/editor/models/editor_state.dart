import 'package:flutter/material.dart';

import '../../projects/models/project_model.dart';
import '../../shared/models/device_model.dart';

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
  final Color gradientStartColor;
  final Color gradientEndColor;
  final String gradientDirection;
  
  // Project-related data
  final ProjectModel? project;
  final List<String> availableLanguages;
  final List<DeviceModel> availableDevices;

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
    this.gradientStartColor = Colors.white,
    this.gradientEndColor = Colors.white,
    this.gradientDirection = 'vertical',
    this.project,
    this.availableLanguages = const [],
    this.availableDevices = const [],
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
    Color? gradientStartColor,
    Color? gradientEndColor,
    String? gradientDirection,
    ProjectModel? project,
    List<String>? availableLanguages,
    List<DeviceModel>? availableDevices,
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
      gradientStartColor: gradientStartColor ?? this.gradientStartColor,
      gradientEndColor: gradientEndColor ?? this.gradientEndColor,
      gradientDirection: gradientDirection ?? this.gradientDirection,
      project: project ?? this.project,
      availableLanguages: availableLanguages ?? this.availableLanguages,
      availableDevices: availableDevices ?? this.availableDevices,
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
