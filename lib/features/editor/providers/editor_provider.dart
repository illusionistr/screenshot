import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';

import '../../projects/models/project_model.dart';
import '../../projects/models/project_screen_config.dart';
import '../../projects/providers/project_provider.dart';
import '../../projects/services/project_service.dart';
import '../../../providers/app_providers.dart';
import '../../shared/data/devices_data.dart';
import '../../shared/models/screenshot_model.dart';
import '../constants/layouts_data.dart';
import '../constants/platform_dimensions.dart';
import '../models/background_models.dart';
import '../models/editor_state.dart';
import '../models/text_models.dart';
import '../models/layout_models.dart';
import '../models/positioning_models.dart';
import '../services/layout_application_service.dart';
import '../services/platform_detection_service.dart';
import '../utils/background_renderer.dart';

class EditorNotifier extends StateNotifier<EditorState> {
  EditorNotifier([ProjectModel? project, this.ref])
      : super(_createInitialState(project));

  final Ref? ref;

  ProjectService? get _projectService =>
      ref == null ? null : ref!.read(projectServiceProvider);

  // Debounce per-screen persistence to avoid flooding Firestore during typing
  final Map<String, Timer> _persistTimers = {};

  void _persistScreen(int index) {
    try {
      final project = state.project;
      if (project == null || _projectService == null) return;
      if (index < 0 || index >= state.screens.length) return;
      final screen = state.screens[index];
      // Debounce by screen ID
      _persistTimers[screen.id]?.cancel();
      _persistTimers[screen.id] = Timer(const Duration(milliseconds: 350), () {
        final cfg = ProjectScreenConfig.fromScreenConfig(screen);
        _projectService!.updateScreenConfig(
          projectId: project.id,
          screenId: screen.id,
          config: cfg,
        );
        _persistScreenOrder();
      });
    } catch (_) {}
  }

  void _persistNewScreen(ScreenConfig screen) {
    try {
      final project = state.project;
      if (project == null || _projectService == null) return;
      final cfg = ProjectScreenConfig.fromScreenConfig(screen);
      _projectService!.updateScreenConfig(
        projectId: project.id,
        screenId: screen.id,
        config: cfg,
      );
      _persistScreenOrder();
    } catch (_) {}
  }

  void _persistDeleteScreen(int deletedIndex) {
    try {
      final project = state.project;
      if (project == null || _projectService == null) return;
      // Determine removed screen id using previous state inference isn't trivial here;
      // rely on order persistence only (removal handled by overwrite in future step),
      // or implement a more robust tracking if needed.
      _persistScreenOrder();
    } catch (_) {}
  }

  void _persistScreenOrder() {
    try {
      final project = state.project;
      if (project == null || _projectService == null) return;
      final order = state.screens.map((s) => s.id).toList();
      _projectService!.updateScreenOrder(projectId: project.id, order: order);
    } catch (_) {}
  }

  bool _bootstrapped = false;

  static EditorState _createInitialState(ProjectModel? project) {
    // Mock screenshots for now - will be replaced with real screenshots later
    final mockScreenshots = [
      ScreenshotItem(
        id: '1',
        title: 'CREATE VIBES FROM\nYOUR PHONE fam',
        subtitle: 'MUSIC • REMIXES • VIBES',
        imagePath: 'assets/placeholder_screenshot.png',
        backgroundColor: const Color(0xFFE91E63), // Pink
        gradientColor: const Color(0xFF2196F3), // Blue
      ),
      ScreenshotItem(
        id: '2',
        title: 'CREATE AND FIND\nAWESOME TUNES',
        subtitle: '',
        imagePath: 'assets/placeholder_screenshot.png',
        backgroundColor: const Color(0xFFE91E63), // Pink
        gradientColor: const Color(0xFFFFC107), // Yellow
      ),
      ScreenshotItem(
        id: '3',
        title: 'TALK TO THE MUSIC\nPROS',
        subtitle: '',
        imagePath: 'assets/placeholder_screenshot.png',
        backgroundColor: const Color(0xFFE91E63), // Pink
        gradientColor: const Color(0xFFFF9800), // Orange
      ),
      ScreenshotItem(
        id: '4',
        title: 'STORE SONGS FOR LATER\nVIBIN\'',
        subtitle: '',
        imagePath: 'assets/placeholder_screenshot.png',
        backgroundColor: const Color(0xFF2196F3), // Blue
        gradientColor: const Color(0xFFFF9800), // Orange
      ),
    ];

    // Create initial screens
    final initialScreens = List.generate(
        5,
        (index) => ScreenConfig(
              id: 'screen_${index + 1}',
              backgroundColor: Colors.white,
              isLandscape: false,
            ));

    if (project == null) {
      return EditorState(
        screenshots: mockScreenshots,
        screens: initialScreens,
        selectedScreenIndex: 0,
        currentDimensions:
            PlatformDimensions.appStoreDimensions[DeviceType.iphonePortrait]!,
      );
    }

    // Create initial state with project data
    final availableDevices = project.devices;
    final availableLanguages = project.supportedLanguages;
    final selectedDevice =
        availableDevices.isNotEmpty ? availableDevices.first.id : '';
    final currentDimensions = selectedDevice.isNotEmpty
        ? PlatformDetectionService.getDimensionsForDevice(selectedDevice)
        : PlatformDimensions.appStoreDimensions[DeviceType.iphonePortrait]!;

    // If project already has persistent screen configs, hydrate from them
    List<ScreenConfig> screensFromProject = [];
    if (project.screenConfigs.isNotEmpty) {
      final order = project.screenOrder.isNotEmpty
          ? project.screenOrder
          : project.screenConfigs.keys.toList();
      screensFromProject = [
        for (final id in order)
          if (project.screenConfigs.containsKey(id))
            ProjectScreenConfig.toScreenConfig(project.screenConfigs[id]!)
      ];
    } else {
      screensFromProject = initialScreens;
    }

    return EditorState(
      project: project,
      availableLanguages: availableLanguages,
      availableDevices: availableDevices,
      selectedLanguage:
          availableLanguages.isNotEmpty ? availableLanguages.first : 'en',
      selectedDevice: selectedDevice,
      screenshots: mockScreenshots,
      screens: screensFromProject,
      selectedScreenIndex: 0,
      currentDimensions: currentDimensions,
    );
  }

  void updateCaption(String caption) {
    state = state.copyWith(caption: caption);
  }

  void updateFontFamily(String fontFamily) {
    state = state.copyWith(fontFamily: fontFamily);
  }

  void updateFontSize(double fontSize) {
    state = state.copyWith(fontSize: fontSize);
  }

  void updateFontWeight(FontWeight fontWeight) {
    state = state.copyWith(fontWeight: fontWeight);
  }

  void updateTextAlign(TextAlign textAlign) {
    state = state.copyWith(textAlign: textAlign);
  }

  void updateTextColor(Color color) {
    state = state.copyWith(textColor: color);
  }

  void updateSelectedLanguage(String language) {
    state = state.copyWith(selectedLanguage: language);
  }


  /// Applies a completed translation to the corresponding text element
  void applyTranslation({
    required String elementId,
    required String language,
    required String translatedText,
  }) {
    print('[EditorNotifier] applyTranslation called');
    print('[EditorNotifier] Element ID: $elementId');
    print('[EditorNotifier] Language: $language');
    print('[EditorNotifier] Translated text: "$translatedText"');

    // Find the screen and element that matches this elementId
    for (int screenIndex = 0; screenIndex < state.screens.length; screenIndex++) {
      final screen = state.screens[screenIndex];
      
      // Check if this screen has the element
      final titleElement = screen.textConfig.getElement(TextFieldType.title);
      final subtitleElement = screen.textConfig.getElement(TextFieldType.subtitle);
      
      TextElement? targetElement;
      TextFieldType? targetType;
      
      if (titleElement?.id == elementId) {
        targetElement = titleElement;
        targetType = TextFieldType.title;
      } else if (subtitleElement?.id == elementId) {
        targetElement = subtitleElement;
        targetType = TextFieldType.subtitle;
      }
      
      if (targetElement != null && targetType != null) {
        print('[EditorNotifier] Found element in screen $screenIndex');
        print('[EditorNotifier] Element type: ${targetType.displayName}');
        print('[EditorNotifier] Current translations: ${targetElement.translations}');
        
        // Update the element with the new translation
        final updatedElement = targetElement.addTranslation(language, translatedText);
        print('[EditorNotifier] Updated translations: ${updatedElement.translations}');
        
        // Update the text config
        final updatedTextConfig = screen.textConfig.updateElement(updatedElement);
        
        // Update the screen
        final updatedScreen = screen.copyWith(textConfig: updatedTextConfig);
        
        // Update the screens list
        final updatedScreens = List<ScreenConfig>.from(state.screens);
        updatedScreens[screenIndex] = updatedScreen;
        
        // Update the state
        state = state.copyWith(screens: updatedScreens);
        
        print('[EditorNotifier] Translation applied successfully');
        
        // Persist the changes
        _persistScreen(screenIndex);
        
        return;
      }
    }
    
    print('[EditorNotifier] WARNING: Element $elementId not found in any screen');
  }

  void updateSelectedDevice(String device) {
    final newDimensions =
        PlatformDetectionService.getDimensionsForDevice(device);
    state = state.copyWith(
      selectedDevice: device,
      currentDimensions: newDimensions,
    );
  }

  void applyToAll() {
    // This would apply current settings to all screenshots
    // For now, we'll just trigger a rebuild to show the effect
    state = state.copyWith();
  }

  void reorderScreenshots(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final List<ScreenshotItem> newScreenshots = List.from(state.screenshots);
    final item = newScreenshots.removeAt(oldIndex);
    newScreenshots.insert(newIndex, item);
    state = state.copyWith(screenshots: newScreenshots);
  }

  void updateSelectedTab(EditorTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void updateSelectedBackgroundTab(BackgroundTab tab) {
    state = state.copyWith(selectedBackgroundTab: tab);
  }

  void updateGradientStartColor(Color color) {
    state = state.copyWith(gradientStartColor: color);
  }

  void updateGradientEndColor(Color color) {
    state = state.copyWith(gradientEndColor: color);
  }

  void updateGradientDirection(String direction) {
    state = state.copyWith(gradientDirection: direction);
  }

  // Background Management Methods
  void updateSolidBackgroundColor(Color color) {
    state = state.copyWith(solidBackgroundColor: color);

    // Apply to currently selected screen if any
    if (state.selectedScreenIndex != null &&
        state.selectedScreenIndex! < state.screens.length) {
      final currentScreen = state.screens[state.selectedScreenIndex!];
      final updatedScreen = currentScreen.copyWith(
        background: BackgroundRenderer.createSolidBackground(color),
      );
      updateScreenConfig(state.selectedScreenIndex!, updatedScreen);
    }
  }

  void updateBackgroundType(BackgroundType type) {
    // Get the currently selected screen
    if (state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      return;
    }

    final currentScreen = state.screens[state.selectedScreenIndex!];
    ScreenBackground newBackground;

    switch (type) {
      case BackgroundType.solid:
        newBackground = BackgroundRenderer.createSolidBackground(
          state.solidBackgroundColor,
        );
        break;
      case BackgroundType.gradient:
        newBackground = BackgroundRenderer.createGradientBackground(
          startColor: state.gradientStartColor,
          endColor: state.gradientEndColor,
          direction: state.gradientDirection,
        );
        break;
      case BackgroundType.image:
        // Keep existing image background or create empty one
        if (currentScreen.background.type == BackgroundType.image) {
          newBackground = currentScreen.background;
        } else {
          newBackground = const ScreenBackground(type: BackgroundType.image);
        }
        break;
    }

    final updatedScreen = currentScreen.copyWith(background: newBackground);
    updateScreenConfig(state.selectedScreenIndex!, updatedScreen);
  }

  void selectBackgroundImage(String imageId, String imageUrl) {
    // Apply to currently selected screen
    if (state.selectedScreenIndex != null &&
        state.selectedScreenIndex! < state.screens.length) {
      final currentScreen = state.screens[state.selectedScreenIndex!];
      final updatedScreen = currentScreen.copyWith(
        background: BackgroundRenderer.createImageBackground(
          imageUrl: imageUrl,
          imageId: imageId,
        ),
      );
      updateScreenConfig(state.selectedScreenIndex!, updatedScreen);
    }
  }

  void applyBackgroundToAllScreens() {
    // Get the currently selected screen's background
    if (state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      return;
    }

    final selectedScreen = state.screens[state.selectedScreenIndex!];
    final backgroundToCopy = selectedScreen.background;

    // Apply to all screens
    final updatedScreens = state.screens.map((screen) {
      return screen.copyWith(background: backgroundToCopy);
    }).toList();

    state = state.copyWith(screens: updatedScreens);

    // Persist changes for all screens
    for (int i = 0; i < updatedScreens.length; i++) {
      _persistScreen(i);
    }
  }

  // Enhanced gradient methods with real-time preview
  void updateGradientStartColorWithPreview(Color color) {
    state = state.copyWith(gradientStartColor: color);

    // Apply to currently selected screen if it has gradient background
    if (state.selectedScreenIndex != null &&
        state.selectedScreenIndex! < state.screens.length) {
      final currentScreen = state.screens[state.selectedScreenIndex!];
      if (currentScreen.background.type == BackgroundType.gradient) {
        final updatedScreen = currentScreen.copyWith(
          background: BackgroundRenderer.createGradientBackground(
            startColor: color,
            endColor: state.gradientEndColor,
            direction: state.gradientDirection,
          ),
        );
        updateScreenConfig(state.selectedScreenIndex!, updatedScreen);
      }
    }
  }

  void updateGradientEndColorWithPreview(Color color) {
    state = state.copyWith(gradientEndColor: color);

    // Apply to currently selected screen if it has gradient background
    if (state.selectedScreenIndex != null &&
        state.selectedScreenIndex! < state.screens.length) {
      final currentScreen = state.screens[state.selectedScreenIndex!];
      if (currentScreen.background.type == BackgroundType.gradient) {
        final updatedScreen = currentScreen.copyWith(
          background: BackgroundRenderer.createGradientBackground(
            startColor: state.gradientStartColor,
            endColor: color,
            direction: state.gradientDirection,
          ),
        );
        updateScreenConfig(state.selectedScreenIndex!, updatedScreen);
      }
    }
  }

  void updateGradientDirectionWithPreview(String direction) {
    state = state.copyWith(gradientDirection: direction);

    // Apply to currently selected screen if it has gradient background
    if (state.selectedScreenIndex != null &&
        state.selectedScreenIndex! < state.screens.length) {
      final currentScreen = state.screens[state.selectedScreenIndex!];
      if (currentScreen.background.type == BackgroundType.gradient) {
        final updatedScreen = currentScreen.copyWith(
          background: BackgroundRenderer.createGradientBackground(
            startColor: state.gradientStartColor,
            endColor: state.gradientEndColor,
            direction: direction,
          ),
        );
        updateScreenConfig(state.selectedScreenIndex!, updatedScreen);
      }
    }
  }

  // Helper methods for getting current screen background info
  ScreenBackground? getCurrentScreenBackground() {
    if (state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      return null;
    }
    return state.screens[state.selectedScreenIndex!].background;
  }

  Color getCurrentScreenSolidColor() {
    final background = getCurrentScreenBackground();
    if (background?.type == BackgroundType.solid &&
        background?.solidColor != null) {
      return background!.solidColor!;
    }
    return state.solidBackgroundColor;
  }

  String? getCurrentScreenImageId() {
    final background = getCurrentScreenBackground();
    if (background?.type == BackgroundType.image) {
      return background?.imageId;
    }
    return null;
  }

  // Screen Management Methods
  void addScreen() {
    if (state.screens.length >= 10) return;

    // Copy background from currently selected screen or use default
    ScreenBackground backgroundToUse = ScreenBackground.defaultBackground;
    if (state.selectedScreenIndex != null &&
        state.selectedScreenIndex! < state.screens.length) {
      backgroundToUse = state.screens[state.selectedScreenIndex!].background;
    }

    final newScreen = ScreenConfig(
      id: 'screen_${DateTime.now().millisecondsSinceEpoch}',
      backgroundColor: Colors.white,
      isLandscape: false,
      background: backgroundToUse,
    );

    final newScreens = [...state.screens, newScreen];
    state = state.copyWith(screens: newScreens);

    // Persist new screen and order
    _persistNewScreen(newScreen);
  }

  void duplicateScreen(int index) {
    if (index < 0 ||
        index >= state.screens.length ||
        state.screens.length >= 10) return;

    final screenToDuplicate = state.screens[index];
    final newScreen = ScreenConfig(
      id: 'screen_${DateTime.now().millisecondsSinceEpoch}',
      backgroundColor: screenToDuplicate.backgroundColor,
      isLandscape: screenToDuplicate.isLandscape,
      backgroundImagePath: screenToDuplicate.backgroundImagePath,
      customSettings: Map.from(screenToDuplicate.customSettings),
      background: screenToDuplicate.background, // Copy background
      textConfig: screenToDuplicate.textConfig, // Copy text configuration
    );

    final newScreens = [...state.screens];
    newScreens.insert(index + 1, newScreen);
    state = state.copyWith(screens: newScreens);

    // Persist duplicated screen and order
    _persistNewScreen(newScreen);
  }

  void deleteScreen(int index) {
    if (index < 0 || index >= state.screens.length || state.screens.length <= 1)
      return;

    final removedId = (index >= 0 && index < state.screens.length)
        ? state.screens[index].id
        : null;
    final newScreens = [...state.screens];
    newScreens.removeAt(index);

    int? newSelectedIndex = state.selectedScreenIndex;
    if (newSelectedIndex != null) {
      if (newSelectedIndex == index) {
        newSelectedIndex = newSelectedIndex > 0 ? newSelectedIndex - 1 : 0;
      } else if (newSelectedIndex > index) {
        newSelectedIndex = newSelectedIndex - 1;
      }
      if (newSelectedIndex >= newScreens.length) {
        newSelectedIndex = newScreens.length - 1;
      }
    }

    state = state.copyWith(
      screens: newScreens,
      selectedScreenIndex: newSelectedIndex,
    );

    // Persist removal and order
    try {
      final project = state.project;
      if (project != null && _projectService != null && removedId != null) {
        final order = state.screens.map((s) => s.id).toList();
        _projectService!.removeScreen(
          projectId: project.id,
          screenId: removedId,
          newOrder: order,
        );
      }
    } catch (_) {}
  }

  void reorderScreens(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= state.screens.length ||
        newIndex < 0 ||
        newIndex >= state.screens.length ||
        oldIndex == newIndex) {
      return;
    }

    final newScreens = [...state.screens];
    final screen = newScreens.removeAt(oldIndex);
    newScreens.insert(newIndex, screen);

    int? newSelectedIndex = state.selectedScreenIndex;
    if (newSelectedIndex == oldIndex) {
      newSelectedIndex = newIndex;
    } else if (newSelectedIndex != null) {
      if (oldIndex < newIndex) {
        if (newSelectedIndex > oldIndex && newSelectedIndex <= newIndex) {
          newSelectedIndex = newSelectedIndex - 1;
        }
      } else {
        if (newSelectedIndex >= newIndex && newSelectedIndex < oldIndex) {
          newSelectedIndex = newSelectedIndex + 1;
        }
      }
    }

    state = state.copyWith(
      screens: newScreens,
      selectedScreenIndex: newSelectedIndex,
    );

    // Persist new order
    _persistScreenOrder();
  }

  void selectScreen(int index) {
    if (index < 0 || index >= state.screens.length) return;

    // Get the selected screen's background
    final selectedScreen = state.screens[index];
    final background = selectedScreen.background;

    // Sync background panel state with the selected screen's background
    BackgroundTab tabToSelect = state.selectedBackgroundTab;
    Color? solidColor;
    Color? gradientStart;
    Color? gradientEnd;
    String? gradientDir;

    switch (background.type) {
      case BackgroundType.solid:
        tabToSelect = BackgroundTab.color;
        solidColor = background.solidColor ?? state.solidBackgroundColor;
        break;
      case BackgroundType.gradient:
        tabToSelect = BackgroundTab.gradient;
        // Extract colors from LinearGradient
        if (background.gradient != null) {
          final colors = background.gradient!.colors;
          if (colors.isNotEmpty) {
            gradientStart = colors.first;
            gradientEnd = colors.length > 1 ? colors.last : colors.first;
          }
          // Determine direction from alignment
          final begin = background.gradient!.begin as Alignment;
          final end = background.gradient!.end as Alignment;
          if (begin == Alignment.topCenter && end == Alignment.bottomCenter) {
            gradientDir = 'vertical';
          } else if (begin == Alignment.centerLeft && end == Alignment.centerRight) {
            gradientDir = 'horizontal';
          } else if (begin == Alignment.topLeft && end == Alignment.bottomRight) {
            gradientDir = 'diagonal';
          } else {
            gradientDir = 'vertical'; // default
          }
        }
        break;
      case BackgroundType.image:
        tabToSelect = BackgroundTab.image;
        break;
    }

    state = state.copyWith(
      selectedScreenIndex: index,
      selectedBackgroundTab: tabToSelect,
      solidBackgroundColor: solidColor ?? state.solidBackgroundColor,
      gradientStartColor: gradientStart ?? state.gradientStartColor,
      gradientEndColor: gradientEnd ?? state.gradientEndColor,
      gradientDirection: gradientDir ?? state.gradientDirection,
    );
  }

  void updateScreenConfig(int index, ScreenConfig newConfig) {
    if (index < 0 || index >= state.screens.length) return;

    final newScreens = [...state.screens];
    newScreens[index] = newConfig;
    state = state.copyWith(screens: newScreens);

    // Persist this screen
    _persistScreen(index);
  }

  void updateScreenTextConfig(ScreenTextConfig textConfig) {
    if (state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) return;

    final currentScreen = state.screens[state.selectedScreenIndex!];
    final updatedScreen = currentScreen.copyWith(textConfig: textConfig);
    updateScreenConfig(state.selectedScreenIndex!, updatedScreen);
  }

  // Transform overrides management (per-screen, persisted via customSettings)
  void updateDeviceTransformOverrideForCurrentScreen(ElementTransform transform) {
    print('[EditorNotifier] updateDeviceTransformOverrideForCurrentScreen called');
    print('[EditorNotifier] Device Transform: scale=${transform.scale}, rotation=${transform.rotationDeg}');

    if (state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      print('[EditorNotifier] No valid screen selected for device transform, returning');
      return;
    }
    final idx = state.selectedScreenIndex!;
    final screen = state.screens[idx];
    final updatedSettings = Map<String, dynamic>.from(screen.customSettings);
    updatedSettings['deviceTransform'] = transform.toJson();
    final updatedScreen = screen.copyWith(customSettings: updatedSettings);
    updateScreenConfig(idx, updatedScreen);
  }

  ElementTransform resolveCurrentDeviceTransform() {
    final layoutId = getCurrentScreenLayoutId();
    final base = LayoutsData.getLayoutConfigOrDefault(layoutId).deviceTransform;
    if (state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      return base;
    }
    final settings = state.screens[state.selectedScreenIndex!].customSettings;
    final raw = settings['deviceTransform'];
    if (raw is Map<String, dynamic>) return ElementTransform.fromJson(raw);
    if (raw is Map) return ElementTransform.fromJson(Map<String, dynamic>.from(raw));
    return base;
  }

  // Text transform overrides (title/subtitle)
  void updateTextTransformOverrideForCurrentScreen(
      TextFieldType type, ElementTransform transform) {
    print('[EditorNotifier] updateTextTransformOverrideForCurrentScreen called - type: $type');
    print('[EditorNotifier] Transform: scale=${transform.scale}, rotation=${transform.rotationDeg}');

    if (state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      print('[EditorNotifier] No valid screen selected, returning');
      return;
    }

    final idx = state.selectedScreenIndex!;
    final screen = state.screens[idx];
    final isGrouped = screen.textConfig.hasBothElementsVisible &&
        screen.textConfig.textGrouping == TextGrouping.together;

    final targetKey = (isGrouped || type == TextFieldType.title)
        ? 'titleTransform'
        : 'subtitleTransform';

    final updatedSettings = Map<String, dynamic>.from(screen.customSettings);
    updatedSettings[targetKey] = transform.toJson();
    final updatedScreen = screen.copyWith(customSettings: updatedSettings);
    updateScreenConfig(idx, updatedScreen);
  }

  ElementTransform resolveTextTransformForCurrentScreen(TextFieldType type) {
    final layoutId = getCurrentScreenLayoutId();
    final baseLayout = LayoutsData.getLayoutConfigOrDefault(layoutId);
    final isTitle = type == TextFieldType.title;
    // Base transform from layout (may be null)
    final base = isTitle
        ? (baseLayout.titleTransform ?? const ElementTransform())
        : (baseLayout.subtitleTransform ?? const ElementTransform());

    if (state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      return base;
    }

    final screen = state.screens[state.selectedScreenIndex!];
    final isGrouped = screen.textConfig.hasBothElementsVisible &&
        screen.textConfig.textGrouping == TextGrouping.together;
    final settings = screen.customSettings;
    final key = (isGrouped || isTitle) ? 'titleTransform' : 'subtitleTransform';
    final raw = settings[key];
    if (raw is Map<String, dynamic>) return ElementTransform.fromJson(raw);
    if (raw is Map) return ElementTransform.fromJson(Map<String, dynamic>.from(raw));
    return base;
  }

  // Text Element Management Methods
  void selectTextElement(TextFieldType type) {
    // Update selection state
    state = state.copyWith(
      textElementState: state.textElementState.selectType(type),
    );

    // Auto-create element if it doesn't exist on the current screen
    if (state.selectedScreenIndex != null &&
        state.selectedScreenIndex! < state.screens.length) {
      final currentScreen = state.screens[state.selectedScreenIndex!];
      if (!currentScreen.textConfig.hasElement(type)) {
        final newElement = TextElement.createDefault(type);
        final updatedTextConfig =
            currentScreen.textConfig.addElement(newElement);
        final updatedScreen =
            currentScreen.copyWith(textConfig: updatedTextConfig);
        updateScreenConfig(state.selectedScreenIndex!, updatedScreen);
      }
    }
  }

  void removeTextElement(TextFieldType type) {
    if (state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      return;
    }

    final currentScreen = state.screens[state.selectedScreenIndex!];
    final updatedTextConfig = currentScreen.textConfig.removeElement(type);
    final updatedScreen = currentScreen.copyWith(textConfig: updatedTextConfig);
    updateScreenConfig(state.selectedScreenIndex!, updatedScreen);

    // Clear selection if removing the selected element
    if (state.textElementState.selectedType == type) {
      state = state.copyWith(
        textElementState: state.textElementState.clearSelection(),
      );
    }
  }

  void updateTextContent(TextFieldType type, String content) {
    if (state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      return;
    }

    final currentScreen = state.screens[state.selectedScreenIndex!];
    final currentElement = currentScreen.textConfig.getElement(type);

    if (currentElement != null) {
      final updatedElement = currentElement.updateContent(content);
      final updatedTextConfig =
          currentScreen.textConfig.updateElement(updatedElement);
      final updatedScreen =
          currentScreen.copyWith(textConfig: updatedTextConfig);
      updateScreenConfig(state.selectedScreenIndex!, updatedScreen);
    }
  }

  void updateTextContentForLanguage(TextFieldType type, String language, String content) {
    if (state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      return;
    }

    final currentScreen = state.screens[state.selectedScreenIndex!];
    final currentElement = currentScreen.textConfig.getElement(type);

    if (currentElement != null) {
      final updatedElement = currentElement.addTranslation(language, content);
      final updatedTextConfig =
          currentScreen.textConfig.updateElement(updatedElement);
      final updatedScreen =
          currentScreen.copyWith(textConfig: updatedTextConfig);
      updateScreenConfig(state.selectedScreenIndex!, updatedScreen);
    }
  }

  void updateTextFormatting({
    required TextFieldType type,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    Color? color,
    bool? isVisible,
  }) {
    if (state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      return;
    }

    final currentScreen = state.screens[state.selectedScreenIndex!];

    // Check if elements are grouped
    final isGrouped = currentScreen.textConfig.hasBothElementsVisible &&
        currentScreen.textConfig.textGrouping == TextGrouping.together;
    final isPositioningChange = textAlign != null;

    // Determine which element to update
    TextElement? elementToUpdate;

    if (isGrouped && isPositioningChange) {
      // For positioning changes in grouped mode, always update the primary element
      elementToUpdate = currentScreen.textConfig.primaryElement;
    } else {
      // For non-positioning changes or non-grouped mode, update the specific element
      elementToUpdate = currentScreen.textConfig.getElement(type);
    }

    if (elementToUpdate != null) {
      final updatedElement = elementToUpdate.copyWith(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        textAlign: textAlign,
        color: color,
        isVisible: isVisible,
      );

      final updatedTextConfig =
          currentScreen.textConfig.updateElement(updatedElement);
      final updatedScreen =
          currentScreen.copyWith(textConfig: updatedTextConfig);
      updateScreenConfig(state.selectedScreenIndex!, updatedScreen);
    }
  }

  void applySelectedElementFormattingToAllScreens() {
    if (state.textElementState.selectedType == null ||
        state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      return;
    }

    final selectedType = state.textElementState.selectedType!;
    final currentScreen = state.screens[state.selectedScreenIndex!];
    final sourceTextConfig = currentScreen.textConfig;
    final sourceElement = sourceTextConfig.getElement(selectedType);

    if (sourceElement == null) {
      return;
    }

    // Check if elements are currently grouped
    final isGrouped = sourceTextConfig.hasBothElementsVisible &&
        sourceTextConfig.textGrouping == TextGrouping.together;

    // Apply formatting to all screens
    final updatedScreens = state.screens.map((screen) {
      final screenIndex = state.screens.indexOf(screen);

      var updatedTextConfig = screen.textConfig;

      if (isGrouped) {
        // When grouped, copy the entire text configuration including grouping and both elements
        final sourceTitleElement =
            sourceTextConfig.getElement(TextFieldType.title);
        final sourceSubtitleElement =
            sourceTextConfig.getElement(TextFieldType.subtitle);

        // Update or create title element (only if it's visible in source)
        if (sourceTitleElement != null && sourceTitleElement.isVisible) {
          final existingTitle =
              updatedTextConfig.getElement(TextFieldType.title);

          final updatedTitle = existingTitle != null
              ? existingTitle.copyWith(
                  fontFamily: sourceTitleElement.fontFamily,
                  fontSize: sourceTitleElement.fontSize,
                  fontWeight: sourceTitleElement.fontWeight,
                  textAlign: sourceTitleElement.textAlign,
                  color: sourceTitleElement.color,
                  verticalPosition: sourceTitleElement.verticalPosition,
                  isVisible: sourceTitleElement.isVisible,
                )
              : TextElement.createDefault(TextFieldType.title).copyWith(
                  fontFamily: sourceTitleElement.fontFamily,
                  fontSize: sourceTitleElement.fontSize,
                  fontWeight: sourceTitleElement.fontWeight,
                  textAlign: sourceTitleElement.textAlign,
                  color: sourceTitleElement.color,
                  verticalPosition: sourceTitleElement.verticalPosition,
                  isVisible: sourceTitleElement.isVisible,
                );

          if (existingTitle != null) {
            updatedTextConfig = updatedTextConfig.updateElement(updatedTitle);
          } else {
            updatedTextConfig = updatedTextConfig.addElement(updatedTitle);
          }
        }

        // Update or create subtitle element (only if it's visible in source)
        if (sourceSubtitleElement != null && sourceSubtitleElement.isVisible) {
          final existingSubtitle =
              updatedTextConfig.getElement(TextFieldType.subtitle);
          final updatedSubtitle = existingSubtitle != null
              ? existingSubtitle.copyWith(
                  fontFamily: sourceSubtitleElement.fontFamily,
                  fontSize: sourceSubtitleElement.fontSize,
                  fontWeight: sourceSubtitleElement.fontWeight,
                  textAlign: sourceSubtitleElement.textAlign,
                  color: sourceSubtitleElement.color,
                  verticalPosition: sourceSubtitleElement.verticalPosition,
                  isVisible: sourceSubtitleElement.isVisible,
                )
              : TextElement.createDefault(TextFieldType.subtitle).copyWith(
                  fontFamily: sourceSubtitleElement.fontFamily,
                  fontSize: sourceSubtitleElement.fontSize,
                  fontWeight: sourceSubtitleElement.fontWeight,
                  textAlign: sourceSubtitleElement.textAlign,
                  color: sourceSubtitleElement.color,
                  verticalPosition: sourceSubtitleElement.verticalPosition,
                  isVisible: sourceSubtitleElement.isVisible,
                );

          if (existingSubtitle != null) {
            updatedTextConfig =
                updatedTextConfig.updateElement(updatedSubtitle);
          } else {
            updatedTextConfig = updatedTextConfig.addElement(updatedSubtitle);
          }
        }

        // Apply the grouping setting
        updatedTextConfig =
            updatedTextConfig.updateGrouping(sourceTextConfig.textGrouping);

        return screen.copyWith(textConfig: updatedTextConfig);
      } else {
        // When not grouped, use original logic for single element
        final existingElement = updatedTextConfig.getElement(selectedType);

        if (existingElement != null) {
          // Update existing element with new formatting
          final updatedElement = existingElement.copyWith(
            fontFamily: sourceElement.fontFamily,
            fontSize: sourceElement.fontSize,
            fontWeight: sourceElement.fontWeight,
            textAlign: sourceElement.textAlign,
            color: sourceElement.color,
            verticalPosition: sourceElement.verticalPosition,
            isVisible: sourceElement.isVisible,
          );
          updatedTextConfig = updatedTextConfig.updateElement(updatedElement);
          return screen.copyWith(textConfig: updatedTextConfig);
        } else {
          // Create new element with source formatting but default content
          final newElement = TextElement.createDefault(selectedType).copyWith(
            fontFamily: sourceElement.fontFamily,
            fontSize: sourceElement.fontSize,
            fontWeight: sourceElement.fontWeight,
            textAlign: sourceElement.textAlign,
            color: sourceElement.color,
            verticalPosition: sourceElement.verticalPosition,
            isVisible: sourceElement.isVisible,
          );
          updatedTextConfig = updatedTextConfig.addElement(newElement);
          return screen.copyWith(textConfig: updatedTextConfig);
        }
      }
    }).toList();

    state = state.copyWith(screens: updatedScreens);

    // Persist changes for all screens
    for (int i = 0; i < updatedScreens.length; i++) {
      _persistScreen(i);
    }
  }

  int getAffectedScreensCount(TextFieldType type) {
    return state.screens.length;
  }

  /// Language-aware version of apply to all that respects the current editing language
  void applySelectedElementFormattingToAllScreensForCurrentLanguage() {
    if (state.textElementState.selectedType == null ||
        state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      return;
    }

    final selectedType = state.textElementState.selectedType!;
    final currentEditingLanguage = state.selectedLanguage;
    final currentScreen = state.screens[state.selectedScreenIndex!];
    final sourceTextConfig = currentScreen.textConfig;
    final sourceElement = sourceTextConfig.getElement(selectedType);

    if (sourceElement == null) {
      return;
    }

    // Check if elements are currently grouped
    final isGrouped = sourceTextConfig.hasBothElementsVisible &&
        sourceTextConfig.textGrouping == TextGrouping.together;

    // Apply formatting to all screens while preserving per-language content
    final updatedScreens = state.screens.map((screen) {
      var updatedTextConfig = screen.textConfig;

      if (isGrouped) {
        // When grouped, copy the entire text configuration including grouping and both elements
        final sourceTitleElement = sourceTextConfig.getElement(TextFieldType.title);
        final sourceSubtitleElement = sourceTextConfig.getElement(TextFieldType.subtitle);

        // Update or create title element (only if it's visible in source)
        if (sourceTitleElement != null && sourceTitleElement.isVisible) {
          final existingTitle = updatedTextConfig.getElement(TextFieldType.title);
          
          // Preserve existing translations and only update the current editing language content
          final existingTranslations = existingTitle?.translations ?? <String, String>{};
          final sourceContent = sourceTitleElement.getTranslation(currentEditingLanguage);
          final updatedTranslations = Map<String, String>.from(existingTranslations);
          updatedTranslations[currentEditingLanguage] = sourceContent;

          final updatedTitle = existingTitle != null
              ? existingTitle.copyWith(
                  translations: updatedTranslations,
                  fontFamily: sourceTitleElement.fontFamily,
                  fontSize: sourceTitleElement.fontSize,
                  fontWeight: sourceTitleElement.fontWeight,
                  textAlign: sourceTitleElement.textAlign,
                  color: sourceTitleElement.color,
                  verticalPosition: sourceTitleElement.verticalPosition,
                  isVisible: sourceTitleElement.isVisible,
                )
              : (() {
                  final newId = '${screen.id}_${TextFieldType.title.id}_${DateTime.now().millisecondsSinceEpoch}';
                  print('[EditorProvider] Creating new title element with ID: $newId for screen: ${screen.id}');
                  return TextElement(
                    id: newId,
                    type: TextFieldType.title,
                    translations: updatedTranslations,
                    fontFamily: sourceTitleElement.fontFamily,
                    fontSize: sourceTitleElement.fontSize,
                    fontWeight: sourceTitleElement.fontWeight,
                    textAlign: sourceTitleElement.textAlign,
                    color: sourceTitleElement.color,
                    verticalPosition: sourceTitleElement.verticalPosition,
                    isVisible: sourceTitleElement.isVisible,
                  );
                })();

          if (existingTitle != null) {
            updatedTextConfig = updatedTextConfig.updateElement(updatedTitle);
          } else {
            updatedTextConfig = updatedTextConfig.addElement(updatedTitle);
          }
        }

        // Update or create subtitle element (only if it's visible in source)
        if (sourceSubtitleElement != null && sourceSubtitleElement.isVisible) {
          final existingSubtitle = updatedTextConfig.getElement(TextFieldType.subtitle);
          
          // Preserve existing translations and only update the current editing language content
          final existingTranslations = existingSubtitle?.translations ?? <String, String>{};
          final sourceContent = sourceSubtitleElement.getTranslation(currentEditingLanguage);
          final updatedTranslations = Map<String, String>.from(existingTranslations);
          updatedTranslations[currentEditingLanguage] = sourceContent;

          final updatedSubtitle = existingSubtitle != null
              ? existingSubtitle.copyWith(
                  translations: updatedTranslations,
                  fontFamily: sourceSubtitleElement.fontFamily,
                  fontSize: sourceSubtitleElement.fontSize,
                  fontWeight: sourceSubtitleElement.fontWeight,
                  textAlign: sourceSubtitleElement.textAlign,
                  color: sourceSubtitleElement.color,
                  verticalPosition: sourceSubtitleElement.verticalPosition,
                  isVisible: sourceSubtitleElement.isVisible,
                )
              : (() {
                  final newId = '${screen.id}_${TextFieldType.subtitle.id}_${DateTime.now().millisecondsSinceEpoch}';
                  print('[EditorProvider] Creating new subtitle element with ID: $newId for screen: ${screen.id}');
                  return TextElement(
                    id: newId,
                    type: TextFieldType.subtitle,
                    translations: updatedTranslations,
                    fontFamily: sourceSubtitleElement.fontFamily,
                    fontSize: sourceSubtitleElement.fontSize,
                    fontWeight: sourceSubtitleElement.fontWeight,
                    textAlign: sourceSubtitleElement.textAlign,
                    color: sourceSubtitleElement.color,
                    verticalPosition: sourceSubtitleElement.verticalPosition,
                    isVisible: sourceSubtitleElement.isVisible,
                  );
                })();

          if (existingSubtitle != null) {
            updatedTextConfig = updatedTextConfig.updateElement(updatedSubtitle);
          } else {
            updatedTextConfig = updatedTextConfig.addElement(updatedSubtitle);
          }
        }

        // Apply the grouping setting
        updatedTextConfig = updatedTextConfig.updateGrouping(sourceTextConfig.textGrouping);

        return screen.copyWith(textConfig: updatedTextConfig);
      } else {
        // When not grouped, use language-aware logic for single element
        final existingElement = updatedTextConfig.getElement(selectedType);

        if (existingElement != null) {
          // Preserve existing translations and only update the current editing language content
          final existingTranslations = existingElement.translations;
          final sourceContent = sourceElement.getTranslation(currentEditingLanguage);
          final updatedTranslations = Map<String, String>.from(existingTranslations);
          updatedTranslations[currentEditingLanguage] = sourceContent;

          // Update existing element with new formatting and language-specific content
          final updatedElement = existingElement.copyWith(
            translations: updatedTranslations,
            fontFamily: sourceElement.fontFamily,
            fontSize: sourceElement.fontSize,
            fontWeight: sourceElement.fontWeight,
            textAlign: sourceElement.textAlign,
            color: sourceElement.color,
            verticalPosition: sourceElement.verticalPosition,
            isVisible: sourceElement.isVisible,
          );
          updatedTextConfig = updatedTextConfig.updateElement(updatedElement);
          return screen.copyWith(textConfig: updatedTextConfig);
        } else {
          // Create new element with source formatting and content in current language
          final sourceContent = sourceElement.getTranslation(currentEditingLanguage);
          final newElementId = '${screen.id}_${selectedType.id}_${DateTime.now().millisecondsSinceEpoch}';
          print('[EditorProvider] Creating new ${selectedType.id} element with ID: $newElementId for screen: ${screen.id}');
          final newElement = TextElement(
            id: newElementId,
            type: selectedType,
            translations: {currentEditingLanguage: sourceContent},
            fontFamily: sourceElement.fontFamily,
            fontSize: sourceElement.fontSize,
            fontWeight: sourceElement.fontWeight,
            textAlign: sourceElement.textAlign,
            color: sourceElement.color,
            verticalPosition: sourceElement.verticalPosition,
            isVisible: sourceElement.isVisible,
          );
          updatedTextConfig = updatedTextConfig.addElement(newElement);
          return screen.copyWith(textConfig: updatedTextConfig);
        }
      }
    }).toList();

    state = state.copyWith(screens: updatedScreens);

    // Persist changes for all screens
    for (int i = 0; i < updatedScreens.length; i++) {
      _persistScreen(i);
    }
  }

  void updateTextElement(TextElement updatedElement) {
    if (state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      return;
    }

    final currentScreen = state.screens[state.selectedScreenIndex!];

    // Check if elements are grouped and this is a positioning change
    final isGrouped = currentScreen.textConfig.hasBothElementsVisible &&
        currentScreen.textConfig.textGrouping == TextGrouping.together;
    final isPositioningChange = updatedElement.verticalPosition != null;

    TextElement elementToUpdate = updatedElement;

    if (isGrouped && isPositioningChange) {
      // For positioning changes in grouped mode, always update the primary element
      final primaryElement = currentScreen.textConfig.primaryElement;
      if (primaryElement != null) {
        // Update the primary element with the new positioning
        elementToUpdate = primaryElement.copyWith(
          verticalPosition: updatedElement.verticalPosition,
        );
      }
    }

    final updatedTextConfig =
        currentScreen.textConfig.updateElement(elementToUpdate);
    final updatedScreen = currentScreen.copyWith(textConfig: updatedTextConfig);
    updateScreenConfig(state.selectedScreenIndex!, updatedScreen);
  }

  TextElement? getCurrentSelectedTextElement() {
    if (state.textElementState.selectedType == null ||
        state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      return null;
    }

    final currentScreen = state.screens[state.selectedScreenIndex!];
    return currentScreen.textConfig
        .getElement(state.textElementState.selectedType!);
  }

  ScreenTextConfig? getCurrentScreenTextConfig() {
    if (state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      return null;
    }

    return state.screens[state.selectedScreenIndex!].textConfig;
  }

  String getApplyToAllButtonText() {
    if (state.textElementState.selectedType == null) {
      return 'Apply to All';
    }

    final type = state.textElementState.selectedType!;
    final count = getAffectedScreensCount(type);

    // Check if elements are currently grouped
    final currentScreenTextConfig = getCurrentScreenTextConfig();
    final isGrouped = currentScreenTextConfig?.hasBothElementsVisible == true &&
        currentScreenTextConfig?.textGrouping == TextGrouping.together;

    if (isGrouped) {
      return 'Apply to All Titles & Subtitles ($count)';
    } else {
      return 'Apply to All ${type.displayName}s ($count)';
    }
  }

  // Screenshot Assignment Methods

  /// Assign a screenshot to the selected screen
  /// SMART DEFAULT BEHAVIOR:
  /// - If no screenshot assigned yet → set as fallback (applies to ALL languages & devices)
  /// - If fallback exists → create language+device-specific override
  void assignScreenshotToSelectedScreen(String screenshotId) {
    // Apply to currently selected screen
    if (state.selectedScreenIndex != null &&
        state.selectedScreenIndex! < state.screens.length) {
      final currentScreen = state.screens[state.selectedScreenIndex!];
      final currentDevice = state.selectedDevice;
      final currentLanguage = state.selectedLanguage;

      ScreenConfig updatedScreen;

      // SMART DEFAULT LOGIC:
      if (!currentScreen.hasAnyScreenshot) {
        // First assignment: set as fallback (applies to all languages & devices)
        updatedScreen = currentScreen.setFallbackScreenshot(screenshotId);
      } else {
        // Has existing screenshot: create language+device-specific override
        updatedScreen = currentScreen.assignScreenshotForLanguageAndDevice(
          currentLanguage,
          currentDevice,
          screenshotId,
        );
      }

      updateScreenConfig(state.selectedScreenIndex!, updatedScreen);
    }
  }

  /// Assign a screenshot for a specific language and device (creates override)
  void assignScreenshotForLanguageAndDevice(
    String screenshotId,
    String languageCode,
    String deviceId, {
    int? screenIndex,
  }) {
    final targetIndex = screenIndex ?? state.selectedScreenIndex;
    if (targetIndex == null || targetIndex >= state.screens.length) return;

    final currentScreen = state.screens[targetIndex];
    final updatedScreen = currentScreen.assignScreenshotForLanguageAndDevice(
      languageCode,
      deviceId,
      screenshotId,
    );
    updateScreenConfig(targetIndex, updatedScreen);
  }

  /// Set a screenshot as fallback (applies to all languages and devices)
  void setFallbackScreenshot(String? screenshotId, {int? screenIndex}) {
    final targetIndex = screenIndex ?? state.selectedScreenIndex;
    if (targetIndex == null || targetIndex >= state.screens.length) return;

    final currentScreen = state.screens[targetIndex];
    final updatedScreen = currentScreen.setFallbackScreenshot(screenshotId);
    updateScreenConfig(targetIndex, updatedScreen);
  }

  /// Remove screenshot for specific language+device (falls back appropriately)
  void removeScreenshotForLanguageAndDevice(
    String languageCode,
    String deviceId, {
    int? screenIndex,
  }) {
    final targetIndex = screenIndex ?? state.selectedScreenIndex;
    if (targetIndex == null || targetIndex >= state.screens.length) return;

    final currentScreen = state.screens[targetIndex];
    final updatedScreen = currentScreen.removeScreenshotForLanguageAndDevice(
      languageCode,
      deviceId,
    );
    updateScreenConfig(targetIndex, updatedScreen);
  }

  void removeScreenshotFromScreen(int screenIndex) {
    if (screenIndex < 0 || screenIndex >= state.screens.length) return;

    final currentScreen = state.screens[screenIndex];
    // Clear both fallback and all language+device-specific overrides
    final updatedScreen = currentScreen.copyWith(
      fallbackScreenshotId: null,
      clearFallbackScreenshotId: true,
      assignedScreenshotsByLanguage: {},
    );
    updateScreenConfig(screenIndex, updatedScreen);
  }

  /// Get screenshot ID for a screen based on current language and device
  String? getScreenshotForScreen(int screenIndex, {String? languageCode, String? deviceId}) {
    if (screenIndex < 0 || screenIndex >= state.screens.length) return null;

    final screen = state.screens[screenIndex];
    final targetLanguage = languageCode ?? state.selectedLanguage;
    final targetDevice = deviceId ?? state.selectedDevice;

    return screen.getScreenshotForLanguageAndDevice(targetLanguage, targetDevice);
  }

  ScreenshotItem? getScreenshotItemForScreen(int screenIndex) {
    final screenshotId = getScreenshotForScreen(screenIndex);
    if (screenshotId == null) return null;

    try {
      return state.screenshots
          .firstWhere((screenshot) => screenshot.id == screenshotId);
    } catch (e) {
      return null;
    }
  }

  String? getScreenshotUrlForScreen(int screenIndex) {
    final screenshotId = getScreenshotForScreen(screenIndex);
    if (screenshotId == null) return null;

    // For now, we need to get the ScreenshotModel from somewhere
    // This is a temporary solution - ideally we'd store ScreenshotModel references
    // or have a way to look them up by ID
    return screenshotId; // This will be fixed when we have proper ScreenshotModel access
  }

  // Get the actual ScreenshotModel for a screen by looking it up in the project screenshots
  ScreenshotModel? getScreenshotModelForScreen(int screenIndex) {
    final screenshotId = getScreenshotForScreen(screenIndex);
    if (screenshotId == null || ref == null || state.project == null)
      return null;

    try {
      // For now, we can't synchronously access the async provider data
      // This would require a different approach, like storing ScreenshotModels directly in state
      // or using a consumer widget pattern to reactively update the UI
      return null; // TODO: Implement proper ScreenshotModel lookup
    } catch (e) {
      return null;
    }
  }

  List<int> getScreensWithAssignedScreenshots() {
    final result = <int>[];
    for (int i = 0; i < state.screens.length; i++) {
      if (state.screens[i].assignedScreenshotId != null) {
        result.add(i);
      }
    }
    return result;
  }

  List<String> getAssignedScreenshotIds() {
    return state.screens
        .where((screen) => screen.assignedScreenshotId != null)
        .map((screen) => screen.assignedScreenshotId!)
        .toList();
  }

  bool isScreenshotAssigned(String screenshotId) {
    return getAssignedScreenshotIds().contains(screenshotId);
  }

  int? getScreenIndexForScreenshot(String screenshotId) {
    for (int i = 0; i < state.screens.length; i++) {
      if (state.screens[i].assignedScreenshotId == screenshotId) {
        return i;
      }
    }
    return null;
  }

  void updateProject(ProjectModel project) {
    // Derive available devices; if none on the project, fallback to common phones
    var availableDevices = project.devices;
    if (availableDevices.isEmpty) {
      availableDevices = DevicesData.getPhones();
    }
    final availableLanguages = project.supportedLanguages;
    
    // Compute selected device value first
    final nextSelectedDevice = availableDevices.isNotEmpty
        ? (availableDevices.any((d) => d.id == state.selectedDevice)
            ? state.selectedDevice
            : availableDevices.first.id)
        : '';
    final nextDimensions = nextSelectedDevice.isNotEmpty
        ? PlatformDetectionService.getDimensionsForDevice(nextSelectedDevice)
        : state.currentDimensions;

    state = state.copyWith(
      project: project,
      availableLanguages: availableLanguages,
      availableDevices: availableDevices,
      selectedLanguage: availableLanguages.isNotEmpty
          ? (availableLanguages.contains(state.selectedLanguage)
              ? state.selectedLanguage
              : availableLanguages.first)
          : 'en',
      selectedDevice: nextSelectedDevice,
      currentDimensions: nextDimensions,
    );
  }

  /// Real-time synchronization: Update state when project screenshots change
  void syncWithLatestProject(ProjectModel latestProject) {
    // On first arrival or when same project id, merge latest project data
    if (state.project == null || state.project?.id == latestProject.id) {
      updateProject(latestProject);

      // Hydrate editor screens from persisted project configuration
      if (latestProject.screenConfigs.isNotEmpty) {
        try {
          final order = latestProject.screenOrder.isNotEmpty
              ? latestProject.screenOrder
              : latestProject.screenConfigs.keys.toList();

          final screensFromProject = <ScreenConfig>[
            for (final id in order)
              if (latestProject.screenConfigs.containsKey(id))
                ProjectScreenConfig.toScreenConfig(
                  latestProject.screenConfigs[id]!,
                )
          ];

          if (screensFromProject.isNotEmpty) {
            // Only sync screens if they've actually changed
            // Compare screen IDs to detect real changes vs. local pending updates
            final currentScreenIds = state.screens.map((s) => s.id).toList();
            final projectScreenIds = screensFromProject.map((s) => s.id).toList();

            // Convert to sets for comparison
            final currentSet = currentScreenIds.toSet();
            final projectSet = projectScreenIds.toSet();

            // Check if the screens are actually different (not just reordered)
            // Only sync if project has screens we don't have OR if we have screens project doesn't have
            final screensChanged = !currentSet.containsAll(projectSet) ||
                                   !projectSet.containsAll(currentSet) ||
                                   currentScreenIds.length != projectScreenIds.length;

            if (screensChanged) {
              int? nextSelected = state.selectedScreenIndex;
              if (nextSelected == null || nextSelected >= screensFromProject.length) {
                nextSelected = 0;
              }

              state = state.copyWith(
                screens: screensFromProject,
                selectedScreenIndex: nextSelected,
              );

              // Fix any existing element ID collisions after loading screens
              fixElementIdCollisions();
            }
          }
        } catch (_) {
          // If hydration fails for any reason, keep existing UI state
        }
      }

      // One-time bootstrap of screen persistence if project has none
      if (!_bootstrapped && latestProject.screenConfigs.isEmpty && state.screens.isNotEmpty) {
        for (final screen in state.screens) {
          _persistNewScreen(screen);
        }
        _persistScreenOrder();
      }
      _bootstrapped = true;
    }
  }

  // Layout Management Methods

  /// Update the selected layout for the current screen
  void updateSelectedLayout(String layoutId) {
    state = state.copyWith(selectedLayoutId: layoutId);
  }

  /// Update the selected frame variant (real, clay, matte, no device)
  void updateSelectedFrameVariant(String frameVariant) {
    state = state.copyWith(selectedFrameVariant: frameVariant);
  }

  /// Apply the selected layout to the current screen
  void applyLayoutToCurrentScreen(String layoutId) {
    if (state.selectedScreenIndex == null) return;

    try {
      // Get the layout configuration (will always return a valid layout)
      final layout = LayoutsData.getLayoutOrDefault(layoutId);

      // Get the current screen
      final currentScreen = state.screens[state.selectedScreenIndex!];

      // Apply layout using the Layout Application Service
      final updatedScreen = LayoutApplicationService.applyLayoutToScreen(
        screen: currentScreen,
        layout: layout.config,
      );

      // Update the screen with layout ID and layout-applied configuration
      final finalScreen = updatedScreen.copyWith(layoutId: layoutId);

      // Update state with the modified screen
      final updatedScreens = List<ScreenConfig>.from(state.screens);
      updatedScreens[state.selectedScreenIndex!] = finalScreen;

      state = state.copyWith(
        screens: updatedScreens,
        selectedLayoutId: layoutId,
      );

      // Persist current screen layout
      if (state.selectedScreenIndex != null) {
        _persistScreen(state.selectedScreenIndex!);
      }
    } catch (e) {
      // Log error - in a real app, you might want to show a user-friendly error message
      // For now, silently fail - the UI will remain unchanged
    }
  }

  /// Apply the selected layout to all screens
  /// Note: This method applies layout to ALL screens, but the main behavior should be applyLayoutToCurrentScreen
  void applyLayoutToAllScreens(String layoutId) {
    try {
      // Get the layout configuration (will always return a valid layout)
      final layout = LayoutsData.getLayoutOrDefault(layoutId);

      // Apply layout to each screen using the Layout Application Service
      final updatedScreens = <ScreenConfig>[];
      for (final screen in state.screens) {
        try {
          final updatedScreen = LayoutApplicationService.applyLayoutToScreen(
            screen: screen,
            layout: layout.config,
          );
          updatedScreens.add(updatedScreen.copyWith(layoutId: layoutId));
        } catch (e) {
          // If applying to one screen fails, keep the original screen
          updatedScreens.add(screen);
        }
      }

      state = state.copyWith(
        screens: updatedScreens,
        selectedLayoutId: layoutId,
      );

      // Persist layout changes for all screens
      for (int i = 0; i < updatedScreens.length; i++) {
        _persistScreen(i);
      }
    } catch (e) {
      // Log error - in a real app, you might want to show a user-friendly error message
      // For now, silently fail - the UI will remain unchanged
    }
  }

  /// Get the layout ID for the current screen
  String getCurrentScreenLayoutId() {
    if (state.selectedScreenIndex == null)
      return LayoutsData.getDefaultLayoutId();
    return state.screens[state.selectedScreenIndex!].layoutId;
  }

  /// Fixes element ID collisions across screens by regenerating IDs
  void fixElementIdCollisions() {
    print('[EditorProvider] Fixing element ID collisions...');
    
    final updatedScreens = <ScreenConfig>[];
    final seenIds = <String>{};
    
    for (final screen in state.screens) {
      var updatedTextConfig = screen.textConfig;
      bool hasChanges = false;
      
      for (final element in screen.textConfig.allElements) {
        // Check if this element ID already exists in another screen
        if (seenIds.contains(element.id)) {
          // Generate new unique ID for this element
          final newId = '${screen.id}_${element.type.id}_${DateTime.now().millisecondsSinceEpoch}_${updatedScreens.length}';
          print('[EditorProvider] Fixing collision: ${element.id} -> $newId (screen: ${screen.id})');
          
          final updatedElement = element.copyWith(id: newId);
          updatedTextConfig = updatedTextConfig.updateElement(updatedElement);
          hasChanges = true;
          seenIds.add(newId);
        } else {
          seenIds.add(element.id);
        }
      }
      
      if (hasChanges) {
        updatedScreens.add(screen.copyWith(textConfig: updatedTextConfig));
      } else {
        updatedScreens.add(screen);
      }
    }
    
    if (updatedScreens.any((screen) => screen != state.screens[updatedScreens.indexOf(screen)])) {
      state = state.copyWith(screens: updatedScreens);
      print('[EditorProvider] Element ID collisions fixed, ${seenIds.length} unique IDs now exist');
      
      // Persist all screens after fixing IDs
      for (int i = 0; i < updatedScreens.length; i++) {
        _persistScreen(i);
      }
    } else {
      print('[EditorProvider] No ID collisions found');
    }
  }
}

final editorProvider =
    StateNotifierProvider<EditorNotifier, EditorState>((ref) {
  return EditorNotifier(null, ref);
});

// Project-specific editor provider with real-time synchronization
// Stable-by-id family to avoid provider recreation on every ProjectModel instance refresh
final editorByProjectIdProvider = StateNotifierProvider.family<EditorNotifier, EditorState, String>((ref, projectId) {
  final notifier = EditorNotifier(null, ref);

  // Listen to project stream and push updates into the existing notifier
  ref.listen(projectsStreamProvider, (prev, next) {
    next.whenData((projects) {
      final latest = projects.where((p) => p.id == projectId).firstOrNull;
      if (latest != null) {
        notifier.syncWithLatestProject(latest);
      }
    });
  }, fireImmediately: true);

  return notifier;
});
