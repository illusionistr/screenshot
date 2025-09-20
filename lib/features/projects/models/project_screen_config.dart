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
  final String? assignedScreenshotId;
  final Map<String, dynamic> customSettings; // per-screen overrides (e.g., transforms)

  const ProjectScreenConfig({
    required this.id,
    this.isLandscape = false,
    this.background = ScreenBackground.defaultBackground,
    this.textConfig = const ScreenTextConfig(),
    this.layoutId = 'centered_above',
    this.assignedScreenshotId,
    this.customSettings = const {},
  });

  ProjectScreenConfig copyWith({
    String? id,
    bool? isLandscape,
    ScreenBackground? background,
    ScreenTextConfig? textConfig,
    String? layoutId,
    String? assignedScreenshotId,
    bool clearAssignedScreenshotId = false,
    Map<String, dynamic>? customSettings,
  }) {
    return ProjectScreenConfig(
      id: id ?? this.id,
      isLandscape: isLandscape ?? this.isLandscape,
      background: background ?? this.background,
      textConfig: textConfig ?? this.textConfig,
      layoutId: layoutId ?? this.layoutId,
      assignedScreenshotId:
          clearAssignedScreenshotId ? null : (assignedScreenshotId ?? this.assignedScreenshotId),
      customSettings: customSettings ?? this.customSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isLandscape': isLandscape,
      'background': background.toJson(),
      'textConfig': textConfig.toJson(),
      'layoutId': layoutId,
      'assignedScreenshotId': assignedScreenshotId,
      'customSettings': customSettings,
    };
  }

  static ProjectScreenConfig fromJson(String id, Map<String, dynamic> json) {
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
      assignedScreenshotId: json['assignedScreenshotId'] as String?,
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
      assignedScreenshotId: screen.assignedScreenshotId,
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
      assignedScreenshotId: p.assignedScreenshotId,
      backgroundColor: Colors.white,
      customSettings: p.customSettings,
    );
  }
}

