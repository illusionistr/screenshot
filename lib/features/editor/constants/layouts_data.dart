import 'package:flutter/material.dart';

import '../models/layout_models.dart';
import '../models/text_models.dart';

/// Predefined layouts for app store screenshots
class LayoutsData {
  static const List<LayoutModel> layouts = [
    // Basic Centered Layouts
    LayoutModel(
      config: LayoutConfig(
        id: 'centered_above',
        name: 'Centered Above',
        description: 'Device centered with text above',
        devicePosition: LayoutPosition.centered,
        titlePosition: TextPosition.above,
        subtitlePosition: TextPosition.above,
        deviceRotation: 0.0,
        deviceScale: 1.4,
        deviceOffset: Offset(0, 0.0), // Slightly below center
        textPadding: EdgeInsets.fromLTRB(40, 60, 40, 40),
        titleAlignment: TextAlign.center,
        subtitleAlignment: TextAlign.center,
        defaultTextGrouping: TextGrouping.together, // Group text above device
      ),
      category: 'Basic',
      sortOrder: 1,
    ),

    LayoutModel(
      config: LayoutConfig(
        id: 'centered_below',
        name: 'Centered Below',
        description: 'Device centered with text below',
        devicePosition: LayoutPosition.centered,
        titlePosition: TextPosition.below,
        subtitlePosition: TextPosition.below,
        deviceRotation: 0.0,
        deviceScale: 1.6,
        deviceOffset: Offset(0, -0.1), // Slightly above center
        textPadding: EdgeInsets.fromLTRB(40, 40, 40, 60),
        titleAlignment: TextAlign.center,
        subtitleAlignment: TextAlign.center,
        defaultTextGrouping: TextGrouping.together, // Group text below device
      ),
      category: 'Basic',
      sortOrder: 2,
    ),

    // Tilted Layouts
    LayoutModel(
      config: LayoutConfig(
        id: 'left_tilted_above',
        name: 'Left Tilted Above',
        description: 'Device tilted left with text above',
        devicePosition: LayoutPosition.leftTilted,
        titlePosition: TextPosition.above,
        subtitlePosition: TextPosition.above,
        deviceRotation: -15.0,
        deviceScale: 0.9,
        deviceOffset: Offset(0.1, 0.1),
        textPadding: EdgeInsets.fromLTRB(60, 60, 40, 40),
        titleAlignment: TextAlign.center,
        subtitleAlignment: TextAlign.center,
        defaultTextGrouping:
            TextGrouping.together, // Group text above tilted device
      ),
      category: 'Tilted',
      sortOrder: 3,
    ),

    LayoutModel(
      config: LayoutConfig(
        id: 'right_tilted_above',
        name: 'Right Tilted Above',
        description: 'Device tilted right with text above',
        devicePosition: LayoutPosition.rightTilted,
        titlePosition: TextPosition.above,
        subtitlePosition: TextPosition.above,
        deviceRotation: 0.0,
        deviceScale: 2.2,
        deviceOffset: Offset(0.0, 0.25),
        textPadding: EdgeInsets.fromLTRB(40, 60, 60, 40),
        titleAlignment: TextAlign.center,
        subtitleAlignment: TextAlign.center,
        defaultTextGrouping:
            TextGrouping.together, // Group text above tilted device
      ),
      category: 'Tilted',
      sortOrder: 4,
    ),

    LayoutModel(
      config: LayoutConfig(
        id: 'left_tilted_below',
        name: 'Left Tilted Below',
        description: 'Device tilted left with text below',
        devicePosition: LayoutPosition.leftTilted,
        titlePosition: TextPosition.below,
        subtitlePosition: TextPosition.below,
        deviceRotation: -15.0,
        deviceScale: 0.9,
        deviceOffset: Offset(0.1, -0.1),
        textPadding: EdgeInsets.fromLTRB(60, 40, 40, 60),
        titleAlignment: TextAlign.center,
        subtitleAlignment: TextAlign.center,
        defaultTextGrouping:
            TextGrouping.together, // Group text below tilted device
      ),
      category: 'Tilted',
      sortOrder: 5,
    ),

    LayoutModel(
      config: LayoutConfig(
        id: 'right_tilted_below',
        name: 'Right Tilted Below',
        description: 'Device tilted right with text below',
        devicePosition: LayoutPosition.rightTilted,
        titlePosition: TextPosition.below,
        subtitlePosition: TextPosition.below,
        deviceRotation: 15.0,
        deviceScale: 0.9,
        deviceOffset: Offset(-0.1, -0.1),
        textPadding: EdgeInsets.fromLTRB(40, 40, 60, 60),
        titleAlignment: TextAlign.center,
        subtitleAlignment: TextAlign.center,
        defaultTextGrouping:
            TextGrouping.together, // Group text below tilted device
      ),
      category: 'Tilted',
      sortOrder: 6,
    ),

    // Text-Focused Layouts
    LayoutModel(
      config: LayoutConfig(
        id: 'text_left_device_right',
        name: 'Text Left, Device Right',
        description: 'Text on left, device on right',
        devicePosition: LayoutPosition.rightAligned,
        titlePosition: TextPosition.left,
        subtitlePosition: TextPosition.left,
        deviceRotation: 0.0,
        deviceScale: 0.8,
        deviceOffset: Offset(0.2, 0),
        textPadding: EdgeInsets.fromLTRB(60, 80, 40, 80),
        titleAlignment: TextAlign.left,
        subtitleAlignment: TextAlign.left,
        defaultTextGrouping:
            TextGrouping.together, // Group text as cohesive block on left
      ),
      category: 'Text-Focused',
      sortOrder: 7,
    ),

    LayoutModel(
      config: LayoutConfig(
        id: 'text_right_device_left',
        name: 'Text Right, Device Left',
        description: 'Text on right, device on left',
        devicePosition: LayoutPosition.leftAligned,
        titlePosition: TextPosition.right,
        subtitlePosition: TextPosition.right,
        deviceRotation: 0.0,
        deviceScale: 0.8,
        deviceOffset: Offset(-0.2, 0),
        textPadding: EdgeInsets.fromLTRB(40, 80, 60, 80),
        titleAlignment: TextAlign.right,
        subtitleAlignment: TextAlign.right,
        defaultTextGrouping:
            TextGrouping.together, // Group text as cohesive block on right
      ),
      category: 'Text-Focused',
      sortOrder: 8,
    ),

    // Device-Focused Layouts
    LayoutModel(
      config: LayoutConfig(
        id: 'device_large_centered',
        name: 'Large Centered Device',
        description: 'Large device frame centered',
        devicePosition: LayoutPosition.centered,
        titlePosition: TextPosition.above,
        subtitlePosition: TextPosition.above,
        deviceRotation: 0.0,
        deviceScale: 1.1,
        deviceOffset: Offset(0, 0),
        textPadding: EdgeInsets.fromLTRB(40, 40, 40, 40),
        titleAlignment: TextAlign.center,
        subtitleAlignment: TextAlign.center,
        defaultTextGrouping: TextGrouping
            .separated, // Allow independent positioning around large device
      ),
      category: 'Device-Focused',
      sortOrder: 9,
    ),

    LayoutModel(
      config: LayoutConfig(
        id: 'device_small_centered',
        name: 'Small Centered Device',
        description: 'Small device frame centered',
        devicePosition: LayoutPosition.centered,
        titlePosition: TextPosition.above,
        subtitlePosition: TextPosition.below,
        deviceRotation: 0.0,
        deviceScale: 0.7,
        deviceOffset: Offset(0, 0),
        textPadding: EdgeInsets.fromLTRB(40, 60, 40, 60),
        titleAlignment: TextAlign.center,
        subtitleAlignment: TextAlign.center,
        defaultTextGrouping: TextGrouping
            .separated, // Allow independent positioning around small device
      ),
      category: 'Device-Focused',
      sortOrder: 10,
    ),

    // Overlay Layouts
    LayoutModel(
      config: LayoutConfig(
        id: 'text_overlay_centered',
        name: 'Text Overlay Centered',
        description: 'Text overlaid on device frame',
        devicePosition: LayoutPosition.centered,
        titlePosition: TextPosition.overlay,
        subtitlePosition: TextPosition.overlay,
        deviceRotation: 0.0,
        deviceScale: 1.0,
        deviceOffset: Offset(0, 0),
        textPadding: EdgeInsets.fromLTRB(40, 40, 40, 40),
        titleAlignment: TextAlign.center,
        subtitleAlignment: TextAlign.center,
        defaultTextGrouping:
            TextGrouping.together, // Group overlay text as unified element
      ),
      category: 'Overlay',
      sortOrder: 11,
    ),

    LayoutModel(
      config: LayoutConfig(
        id: 'text_overlay_tilted',
        name: 'Text Overlay Tilted',
        description: 'Text overlaid on tilted device',
        devicePosition: LayoutPosition.leftTilted,
        titlePosition: TextPosition.overlay,
        subtitlePosition: TextPosition.overlay,
        deviceRotation: -20.0,
        deviceScale: 0.9,
        deviceOffset: Offset(0.05, 0),
        textPadding: EdgeInsets.fromLTRB(40, 40, 40, 40),
        titleAlignment: TextAlign.center,
        subtitleAlignment: TextAlign.center,
        defaultTextGrouping:
            TextGrouping.together, // Group overlay text as unified element
      ),
      category: 'Overlay',
      sortOrder: 12,
    ),
  ];

  /// Get layouts by category
  static List<LayoutModel> getLayoutsByCategory(String category) {
    return layouts.where((layout) => layout.category == category).toList();
  }

  /// Get layout by ID
  static LayoutModel? getLayoutById(String id) {
    try {
      return layouts.firstWhere((layout) => layout.config.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get default layout (first one)
  static LayoutModel getDefaultLayout() {
    return layouts.first;
  }

  /// Get default layout ID
  static String getDefaultLayoutId() {
    return layouts.first.config.id;
  }

  /// Get layout by ID or return default if not found
  static LayoutModel getLayoutOrDefault(String? layoutId) {
    if (layoutId == null) {
      return getDefaultLayout();
    }

    final layout = getLayoutById(layoutId);
    return layout ?? getDefaultLayout();
  }

  /// Get layout config by ID or return default if not found
  static LayoutConfig getLayoutConfigOrDefault(String? layoutId) {
    return getLayoutOrDefault(layoutId).config;
  }

  /// Check if a layout ID is valid
  static bool isValidLayoutId(String layoutId) {
    return layouts.any((layout) => layout.config.id == layoutId);
  }

  /// Get all categories
  static List<String> getCategories() {
    return layouts.map((layout) => layout.category).toSet().toList();
  }
}
