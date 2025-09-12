import 'package:flutter/material.dart';

import '../models/text_models.dart';
import 'positioning_models.dart';

/// Enum for device frame positions within the layout
// Deprecated: kept for backward compatibility during transition
// to unified positioning model.
enum LayoutPosition {
  centered,
  leftTilted,
  rightTilted,
  leftAligned,
  rightAligned,
}

/// Enum for text positioning relative to the device frame
// Deprecated: kept for backward compatibility during transition
// to unified positioning model.
enum TextPosition {
  above,
  below,
  left,
  right,
  overlay,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Configuration for a predefined layout
class LayoutConfig {
  final String id;
  final String name;
  final String description;
  // Deprecated fields (will be replaced by unified transforms):
  final LayoutPosition devicePosition;
  final TextPosition titlePosition;
  final TextPosition subtitlePosition;
  final double deviceRotation; // in degrees
  final double deviceScale;
  final Offset deviceOffset; // relative positioning
  final EdgeInsets textPadding;
  final TextAlign titleAlignment;
  final TextAlign subtitleAlignment;
  final List<String> supportedFrameVariants; // real, clay, matte, no device
  final bool isLandscape;
  final TextGrouping
      defaultTextGrouping; // NEW: Default grouping for this layout
  // NEW: Unified transforms
  final ElementTransform deviceTransform;
  final ElementTransform? titleTransform;
  final ElementTransform? subtitleTransform;

  const LayoutConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.devicePosition,
    required this.titlePosition,
    required this.subtitlePosition,
    this.deviceRotation = 0.0,
    this.deviceScale = 1.0,
    this.deviceOffset = Offset.zero,
    this.textPadding = const EdgeInsets.all(20.0),
    this.titleAlignment = TextAlign.center,
    this.subtitleAlignment = TextAlign.center,
    this.supportedFrameVariants = const ['real', 'clay', 'matte', 'no device'],
    this.isLandscape = false,
    this.defaultTextGrouping = TextGrouping.separated, // Default to separated
    this.deviceTransform = const ElementTransform(),
    this.titleTransform,
    this.subtitleTransform,
  });

  LayoutConfig copyWith({
    String? id,
    String? name,
    String? description,
    LayoutPosition? devicePosition,
    TextPosition? titlePosition,
    TextPosition? subtitlePosition,
    double? deviceRotation,
    double? deviceScale,
    Offset? deviceOffset,
    EdgeInsets? textPadding,
    TextAlign? titleAlignment,
    TextAlign? subtitleAlignment,
    List<String>? supportedFrameVariants,
    bool? isLandscape,
    TextGrouping? defaultTextGrouping, // NEW: Include in copyWith
    ElementTransform? deviceTransform,
    ElementTransform? titleTransform,
    ElementTransform? subtitleTransform,
  }) {
    return LayoutConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      devicePosition: devicePosition ?? this.devicePosition,
      titlePosition: titlePosition ?? this.titlePosition,
      subtitlePosition: subtitlePosition ?? this.subtitlePosition,
      deviceRotation: deviceRotation ?? this.deviceRotation,
      deviceScale: deviceScale ?? this.deviceScale,
      deviceOffset: deviceOffset ?? this.deviceOffset,
      textPadding: textPadding ?? this.textPadding,
      titleAlignment: titleAlignment ?? this.titleAlignment,
      subtitleAlignment: subtitleAlignment ?? this.subtitleAlignment,
      supportedFrameVariants:
          supportedFrameVariants ?? this.supportedFrameVariants,
      isLandscape: isLandscape ?? this.isLandscape,
      defaultTextGrouping: defaultTextGrouping ??
          this.defaultTextGrouping, // NEW: Include in copyWith
      deviceTransform: deviceTransform ?? this.deviceTransform,
      titleTransform: titleTransform ?? this.titleTransform,
      subtitleTransform: subtitleTransform ?? this.subtitleTransform,
    );
  }
}

/// Complete layout model with all necessary data
class LayoutModel {
  final LayoutConfig config;
  final String previewImagePath; // Optional: for complex layouts
  final String category;
  final int sortOrder;

  const LayoutModel({
    required this.config,
    this.previewImagePath = '',
    required this.category,
    required this.sortOrder,
  });

  LayoutModel copyWith({
    LayoutConfig? config,
    String? previewImagePath,
    String? category,
    int? sortOrder,
  }) {
    return LayoutModel(
      config: config ?? this.config,
      previewImagePath: previewImagePath ?? this.previewImagePath,
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
