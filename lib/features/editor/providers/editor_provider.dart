import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/editor_state.dart';

class EditorNotifier extends StateNotifier<EditorState> {
  EditorNotifier() : super(_createInitialState());

  static EditorState _createInitialState() {
    return EditorState(
      screenshots: [
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
      ],
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
    state = state.copyWith(selectedDevice: device);
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
}

final editorProvider =
    StateNotifierProvider<EditorNotifier, EditorState>((ref) {
  return EditorNotifier();
});
