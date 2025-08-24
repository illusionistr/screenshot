import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/models/project_model.dart';
import '../../projects/providers/project_provider.dart';
import '../../shared/models/screenshot_model.dart';
import '../constants/platform_dimensions.dart';
import '../models/background_models.dart';
import '../models/editor_state.dart';
import '../models/text_models.dart';
import '../services/platform_detection_service.dart';
import '../utils/background_renderer.dart';

class EditorNotifier extends StateNotifier<EditorState> {
  EditorNotifier([ProjectModel? project, this.ref])
      : super(_createInitialState(project));

  final Ref? ref;

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

    return EditorState(
      project: project,
      availableLanguages: availableLanguages,
      availableDevices: availableDevices,
      selectedLanguage:
          availableLanguages.isNotEmpty ? availableLanguages.first : 'en',
      selectedDevice: selectedDevice,
      screenshots: mockScreenshots,
      screens: initialScreens,
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
  }

  void deleteScreen(int index) {
    if (index < 0 || index >= state.screens.length || state.screens.length <= 1)
      return;

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
  }

  void selectScreen(int index) {
    if (index < 0 || index >= state.screens.length) return;

    state = state.copyWith(selectedScreenIndex: index);
  }

  void updateScreenConfig(int index, ScreenConfig newConfig) {
    if (index < 0 || index >= state.screens.length) return;

    final newScreens = [...state.screens];
    newScreens[index] = newConfig;
    state = state.copyWith(screens: newScreens);
  }

  void updateScreenTextConfig(ScreenTextConfig textConfig) {
    if (state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) return;

    final currentScreen = state.screens[state.selectedScreenIndex!];
    final updatedScreen = currentScreen.copyWith(textConfig: textConfig);
    updateScreenConfig(state.selectedScreenIndex!, updatedScreen);
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
      final updatedElement = currentElement.copyWith(content: content);
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
    print('\n=== APPLY TO ALL DEBUG START ===');

    if (state.textElementState.selectedType == null ||
        state.selectedScreenIndex == null ||
        state.selectedScreenIndex! >= state.screens.length) {
      print(
          'Early return: selectedType=${state.textElementState.selectedType}, selectedScreenIndex=${state.selectedScreenIndex}, screensLength=${state.screens.length}');
      return;
    }

    final selectedType = state.textElementState.selectedType!;
    final currentScreen = state.screens[state.selectedScreenIndex!];
    final sourceTextConfig = currentScreen.textConfig;
    final sourceElement = sourceTextConfig.getElement(selectedType);

    print('Selected type: $selectedType');
    print('Current screen index: ${state.selectedScreenIndex}');
    print('Source element exists: ${sourceElement != null}');
    print('Source element visible: ${sourceElement?.isVisible}');
    print(
        'Source text config elements: ${sourceTextConfig.elements.keys.toList()}');

    if (sourceElement == null) {
      print('Early return: sourceElement is null');
      return;
    }

    // Check if elements are currently grouped
    final isGrouped = sourceTextConfig.hasBothElementsVisible &&
        sourceTextConfig.textGrouping == TextGrouping.together;

    print(
        'Has both elements visible: ${sourceTextConfig.hasBothElementsVisible}');
    print('Text grouping: ${sourceTextConfig.textGrouping}');
    print('Is grouped: $isGrouped');

    // Apply formatting to all screens
    print('\nProcessing ${state.screens.length} screens...');
    final updatedScreens = state.screens.map((screen) {
      final screenIndex = state.screens.indexOf(screen);
      print('\n--- Processing screen $screenIndex ---');

      var updatedTextConfig = screen.textConfig;
      print(
          'Original screen $screenIndex elements: ${updatedTextConfig.elements.keys.toList()}');

      if (isGrouped) {
        print('Using GROUPED logic for screen $screenIndex');
        // When grouped, copy the entire text configuration including grouping and both elements
        final sourceTitleElement =
            sourceTextConfig.getElement(TextFieldType.title);
        final sourceSubtitleElement =
            sourceTextConfig.getElement(TextFieldType.subtitle);

        print(
            'Source title element: exists=${sourceTitleElement != null}, visible=${sourceTitleElement?.isVisible}');
        print(
            'Source subtitle element: exists=${sourceSubtitleElement != null}, visible=${sourceSubtitleElement?.isVisible}');

        // Update or create title element (only if it's visible in source)
        if (sourceTitleElement != null && sourceTitleElement.isVisible) {
          print('Processing title element for screen $screenIndex');
          final existingTitle =
              updatedTextConfig.getElement(TextFieldType.title);
          print(
              'Existing title on screen $screenIndex: ${existingTitle != null}');

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
          print(
              'Created/updated title element: id=${updatedTitle.id}, content="${updatedTitle.content}", visible=${updatedTitle.isVisible}');

          if (existingTitle != null) {
            updatedTextConfig = updatedTextConfig.updateElement(updatedTitle);
            print('Updated existing title element');
          } else {
            updatedTextConfig = updatedTextConfig.addElement(updatedTitle);
            print('Added new title element');
          }

          print(
              'After title update, screen $screenIndex elements: ${updatedTextConfig.elements.keys.toList()}');
        } else {
          print(
              'Skipping title element for screen $screenIndex - not visible in source');
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
          print(
              'Created/updated subtitle element: id=${updatedSubtitle.id}, content="${updatedSubtitle.content}", visible=${updatedSubtitle.isVisible}');

          if (existingSubtitle != null) {
            updatedTextConfig =
                updatedTextConfig.updateElement(updatedSubtitle);
            print('Updated existing subtitle element');
          } else {
            updatedTextConfig = updatedTextConfig.addElement(updatedSubtitle);
            print('Added new subtitle element');
          }

          print(
              'After subtitle update, screen $screenIndex elements: ${updatedTextConfig.elements.keys.toList()}');
        } else {
          print(
              'Skipping subtitle element for screen $screenIndex - not visible in source');
        }

        // Apply the grouping setting
        print(
            'Applying grouping ${sourceTextConfig.textGrouping} to screen $screenIndex');
        updatedTextConfig =
            updatedTextConfig.updateGrouping(sourceTextConfig.textGrouping);
        print(
            'Final screen $screenIndex elements: ${updatedTextConfig.elements.keys.toList()}');
        print(
            'Final screen $screenIndex grouping: ${updatedTextConfig.textGrouping}');

        return screen.copyWith(textConfig: updatedTextConfig);
      } else {
        print('Using SINGLE ELEMENT logic for screen $screenIndex');
        // When not grouped, use original logic for single element
        final existingElement = updatedTextConfig.getElement(selectedType);
        print(
            'Existing element on screen $screenIndex: ${existingElement != null}');

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
          print(
              'Updated existing element: id=${updatedElement.id}, content="${updatedElement.content}", visible=${updatedElement.isVisible}');
          updatedTextConfig = updatedTextConfig.updateElement(updatedElement);
          print(
              'After single element update, screen $screenIndex elements: ${updatedTextConfig.elements.keys.toList()}');
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
          print(
              'Created new element: id=${newElement.id}, content="${newElement.content}", visible=${newElement.isVisible}');
          updatedTextConfig = updatedTextConfig.addElement(newElement);
          print(
              'After new element creation, screen $screenIndex elements: ${updatedTextConfig.elements.keys.toList()}');
          return screen.copyWith(textConfig: updatedTextConfig);
        }
      }
    }).toList();

    print('\n=== UPDATING STATE ===');
    print('Number of updated screens: ${updatedScreens.length}');
    for (int i = 0; i < updatedScreens.length; i++) {
      final screen = updatedScreens[i];
      print(
          'Updated screen $i text elements: ${screen.textConfig.elements.keys.toList()}');
      print('Updated screen $i grouping: ${screen.textConfig.textGrouping}');
      final visibleElements = screen.textConfig.visibleElements;
      print(
          'Updated screen $i visible elements: ${visibleElements.map((e) => '${e.type}-"${e.content}"').toList()}');
    }

    state = state.copyWith(screens: updatedScreens);
    print('State updated successfully');
    print('=== APPLY TO ALL DEBUG END ===\n');
  }

  int getAffectedScreensCount(TextFieldType type) {
    return state.screens.length;
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
  void assignScreenshotToSelectedScreen(String screenshotId) {
    // Apply to currently selected screen (following the same pattern as background management)
    if (state.selectedScreenIndex != null &&
        state.selectedScreenIndex! < state.screens.length) {
      final currentScreen = state.screens[state.selectedScreenIndex!];
      final updatedScreen =
          currentScreen.copyWith(assignedScreenshotId: screenshotId);
      updateScreenConfig(state.selectedScreenIndex!, updatedScreen);
    }
  }

  void removeScreenshotFromScreen(int screenIndex) {
    if (screenIndex < 0 || screenIndex >= state.screens.length) return;

    final currentScreen = state.screens[screenIndex];
    final updatedScreen = currentScreen.copyWith(assignedScreenshotId: null);
    updateScreenConfig(screenIndex, updatedScreen);
  }

  String? getScreenshotForScreen(int screenIndex) {
    if (screenIndex < 0 || screenIndex >= state.screens.length) return null;

    return state.screens[screenIndex].assignedScreenshotId;
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
    final availableDevices = project.devices;
    final availableLanguages = project.supportedLanguages;

    state = state.copyWith(
      project: project,
      availableLanguages: availableLanguages,
      availableDevices: availableDevices,
      selectedLanguage: availableLanguages.isNotEmpty
          ? (availableLanguages.contains(state.selectedLanguage)
              ? state.selectedLanguage
              : availableLanguages.first)
          : 'en',
      selectedDevice: availableDevices.isNotEmpty
          ? (availableDevices.any((d) => d.id == state.selectedDevice)
              ? state.selectedDevice
              : availableDevices.first.id)
          : '',
    );
  }

  /// Real-time synchronization: Update state when project screenshots change
  void syncWithLatestProject(ProjectModel latestProject) {
    if (state.project?.id == latestProject.id) {
      // Only update if this is the same project
      updateProject(latestProject);
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

    final updatedScreens = List<ScreenConfig>.from(state.screens);
    updatedScreens[state.selectedScreenIndex!] =
        updatedScreens[state.selectedScreenIndex!].copyWith(
      layoutId: layoutId,
    );

    state = state.copyWith(
      screens: updatedScreens,
      selectedLayoutId: layoutId,
    );
  }

  /// Apply the selected layout to all screens
  void applyLayoutToAllScreens(String layoutId) {
    final updatedScreens = state.screens
        .map((screen) => screen.copyWith(
              layoutId: layoutId,
            ))
        .toList();

    state = state.copyWith(
      screens: updatedScreens,
      selectedLayoutId: layoutId,
    );
  }

  /// Get the layout ID for the current screen
  String? getCurrentScreenLayoutId() {
    if (state.selectedScreenIndex == null) return null;
    return state.screens[state.selectedScreenIndex!].layoutId;
  }
}

final editorProvider =
    StateNotifierProvider<EditorNotifier, EditorState>((ref) {
  return EditorNotifier(null, ref);
});

// Project-specific editor provider with real-time synchronization
final editorProviderFamily =
    StateNotifierProvider.family<EditorNotifier, EditorState, ProjectModel?>(
        (ref, project) {
  final notifier = EditorNotifier(project, ref);

  // Set up real-time synchronization if project is provided
  if (project != null) {
    // Listen to projects stream for updates
    final projectsStream = ref.watch(projectsStreamProvider);
    projectsStream.whenData((projects) {
      // Find the updated project
      try {
        final updatedProject = projects.firstWhere((p) => p.id == project.id);
        // Sync editor state with latest project data
        notifier.syncWithLatestProject(updatedProject);
      } catch (e) {
        // Project not found in stream - could be deleted
      }
    });
  }

  return notifier;
});
