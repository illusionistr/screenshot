import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/models/project_model.dart';
import '../../projects/providers/project_provider.dart';
import '../models/editor_state.dart';
import '../constants/platform_dimensions.dart';
import '../services/platform_detection_service.dart';

class EditorNotifier extends StateNotifier<EditorState> {
  EditorNotifier([ProjectModel? project]) : super(_createInitialState(project));

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
    final initialScreens = List.generate(5, (index) => ScreenConfig(
      id: 'screen_${index + 1}',
      backgroundColor: Colors.white,
      isLandscape: false,
    ));
    
    if (project == null) {
      return EditorState(
        screenshots: mockScreenshots,
        screens: initialScreens,
        selectedScreenIndex: 0,
        currentDimensions: PlatformDimensions.appStoreDimensions[DeviceType.iphonePortrait]!,
      );
    }
    
    // Create initial state with project data
    final availableDevices = project.devices;
    final availableLanguages = project.supportedLanguages;
    final selectedDevice = availableDevices.isNotEmpty ? availableDevices.first.id : '';
    final currentDimensions = selectedDevice.isNotEmpty 
      ? PlatformDetectionService.getDimensionsForDevice(selectedDevice)
      : PlatformDimensions.appStoreDimensions[DeviceType.iphonePortrait]!;
    
    return EditorState(
      project: project,
      availableLanguages: availableLanguages,
      availableDevices: availableDevices,
      selectedLanguage: availableLanguages.isNotEmpty ? availableLanguages.first : 'en',
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
    final newDimensions = PlatformDetectionService.getDimensionsForDevice(device);
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

  // Screen Management Methods
  void addScreen() {
    if (state.screens.length >= 10) return;
    
    final newScreen = ScreenConfig(
      id: 'screen_${DateTime.now().millisecondsSinceEpoch}',
      backgroundColor: Colors.white,
      isLandscape: false,
    );
    
    final newScreens = [...state.screens, newScreen];
    state = state.copyWith(screens: newScreens);
  }

  void duplicateScreen(int index) {
    if (index < 0 || index >= state.screens.length || state.screens.length >= 10) return;
    
    final screenToDuplicate = state.screens[index];
    final newScreen = ScreenConfig(
      id: 'screen_${DateTime.now().millisecondsSinceEpoch}',
      backgroundColor: screenToDuplicate.backgroundColor,
      isLandscape: screenToDuplicate.isLandscape,
      backgroundImagePath: screenToDuplicate.backgroundImagePath,
      customSettings: Map.from(screenToDuplicate.customSettings),
    );
    
    final newScreens = [...state.screens];
    newScreens.insert(index + 1, newScreen);
    state = state.copyWith(screens: newScreens);
  }

  void deleteScreen(int index) {
    if (index < 0 || index >= state.screens.length || state.screens.length <= 1) return;
    
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
    if (oldIndex < 0 || oldIndex >= state.screens.length || 
        newIndex < 0 || newIndex >= state.screens.length ||
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
}

final editorProvider =
    StateNotifierProvider<EditorNotifier, EditorState>((ref) {
  return EditorNotifier();
});

// Project-specific editor provider with real-time synchronization
final editorProviderFamily = StateNotifierProvider.family<EditorNotifier, EditorState, ProjectModel?>((ref, project) {
  final notifier = EditorNotifier(project);
  
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
