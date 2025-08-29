import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Configuration for frame styling at the project level
class ProjectFrameStyleConfig {
  final String projectId;
  final Color borderColor;
  final double shadowIntensity; // 0.0 to 1.0
  final double borderThickness; // 0.0 to 1.0  
  final double cornerRoundness; // 0.0 to 1.0
  final Map<String, DeviceFrameOverride> deviceOverrides; // deviceId -> overrides

  const ProjectFrameStyleConfig({
    required this.projectId,
    this.borderColor = Colors.black,
    this.shadowIntensity = 0.1,
    this.borderThickness = 0.5,
    this.cornerRoundness = 0.5,
    this.deviceOverrides = const {},
  });

  ProjectFrameStyleConfig copyWith({
    String? projectId,
    Color? borderColor,
    double? shadowIntensity,
    double? borderThickness,
    double? cornerRoundness,
    Map<String, DeviceFrameOverride>? deviceOverrides,
  }) {
    return ProjectFrameStyleConfig(
      projectId: projectId ?? this.projectId,
      borderColor: borderColor ?? this.borderColor,
      shadowIntensity: shadowIntensity ?? this.shadowIntensity,
      borderThickness: borderThickness ?? this.borderThickness,
      cornerRoundness: cornerRoundness ?? this.cornerRoundness,
      deviceOverrides: deviceOverrides ?? this.deviceOverrides,
    );
  }
}

/// Device-specific overrides for frame styling
class DeviceFrameOverride {
  final String deviceId;
  final Color? borderColorOverride;
  final double? shadowIntensityOverride;
  final double? borderThicknessOverride;
  final double? cornerRoundnessOverride;

  const DeviceFrameOverride({
    required this.deviceId,
    this.borderColorOverride,
    this.shadowIntensityOverride,
    this.borderThicknessOverride,
    this.cornerRoundnessOverride,
  });

  DeviceFrameOverride copyWith({
    String? deviceId,
    Color? borderColorOverride,
    double? shadowIntensityOverride,
    double? borderThicknessOverride,
    double? cornerRoundnessOverride,
  }) {
    return DeviceFrameOverride(
      deviceId: deviceId ?? this.deviceId,
      borderColorOverride: borderColorOverride ?? this.borderColorOverride,
      shadowIntensityOverride: shadowIntensityOverride ?? this.shadowIntensityOverride,
      borderThicknessOverride: borderThicknessOverride ?? this.borderThicknessOverride,
      cornerRoundnessOverride: cornerRoundnessOverride ?? this.cornerRoundnessOverride,
    );
  }
}

  /// Canvas-specific shadow properties for high-quality rendering
class CanvasShadowSpec {
  final Color color;
  final double blurRadius;
  final Offset offset;

  const CanvasShadowSpec({
    required this.color,
    required this.blurRadius,
    required this.offset,
  });

  /// Create a MaskFilter for canvas shadow rendering
  ui.MaskFilter get maskFilter => ui.MaskFilter.blur(ui.BlurStyle.normal, blurRadius);

  CanvasShadowSpec copyWith({
    Color? color,
    double? blurRadius,
    Offset? offset,
  }) {
    return CanvasShadowSpec(
      color: color ?? this.color,
      blurRadius: blurRadius ?? this.blurRadius,
      offset: offset ?? this.offset,
    );
  }
}

/// Final computed style combining project config and device overrides
class ComputedFrameStyle {
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final List<BoxShadow> boxShadows; // For widgets
  final CanvasShadowSpec canvasShadow; // For high-quality canvas rendering

  const ComputedFrameStyle({
    required this.borderRadius,
    required this.borderWidth,
    required this.borderColor,
    required this.boxShadows,
    required this.canvasShadow,
  });

  ComputedFrameStyle copyWith({
    double? borderRadius,
    double? borderWidth,
    Color? borderColor,
    List<BoxShadow>? boxShadows,
    CanvasShadowSpec? canvasShadow,
  }) {
    return ComputedFrameStyle(
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      boxShadows: boxShadows ?? this.boxShadows,
      canvasShadow: canvasShadow ?? this.canvasShadow,
    );
  }

  /// Create a BoxDecoration for Flutter widgets
  BoxDecoration toBoxDecoration({Color? backgroundColor}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      boxShadow: boxShadows,
      color: backgroundColor,
    );
  }
}