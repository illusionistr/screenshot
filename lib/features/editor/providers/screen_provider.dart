import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../config/dependency_injection.dart';
import '../models/screen_model.dart';
import '../models/screen_settings.dart';
import '../services/screen_service.dart';
import '../../auth/providers/auth_provider.dart';

class ScreenProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  final ScreenService _screenService = serviceLocator<ScreenService>();

  List<ScreenModel> _screens = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<ScreenModel>>? _screensSubscription;
  String? _currentProjectId;

  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  ScreenProvider({required AuthProvider authProvider})
      : _authProvider = authProvider;

  // Getters
  List<ScreenModel> get screens => _screens;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasScreens => _screens.isNotEmpty;
  int get screenCount => _screens.length;

  // Get screen by index
  ScreenModel? getScreenByIndex(int index) {
    if (index >= 0 && index < _screens.length) {
      return _screens[index];
    }
    return null;
  }

  // Get screen by ID
  ScreenModel? getScreenById(String screenId) {
    try {
      return _screens.firstWhere((screen) => screen.id == screenId);
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Load screens for a project
  Future<void> loadProjectScreens(String projectId) async {
    if (_currentProjectId == projectId && _screensSubscription != null) {
      return; // Already listening to this project
    }

    _currentProjectId = projectId;
    _setLoading(true);
    _setError(null);

    // Cancel previous subscription
    await _screensSubscription?.cancel();

    try {
      _screensSubscription = _screenService
          .streamProjectScreens(projectId)
          .listen(
            (screens) {
              _screens = screens;
              _setLoading(false);
              notifyListeners();
            },
            onError: (error) {
              _setError('Failed to load screens: $error');
              print('Failed to load screens: $error');
              _setLoading(false);
            },
          );
    } catch (e) {
      _setError('Failed to load screens: $e');
      _setLoading(false);
    }
  }

  // Add new screen
  Future<void> addScreen(String projectId) async {
    if (_screens.length >= 10) {
      _setError('Maximum of 10 screens allowed');
      return;
    }

    final userId = _authProvider.currentUser?.id;
    if (userId == null) {
      _setError('User not authenticated');
      return;
    }

    try {
      _setError(null);
      final nextOrder = _screens.length;
      
      await _screenService.createDefaultScreen(
        projectId: projectId,
        userId: userId,
        order: nextOrder,
      );
      
      // The stream will automatically update the UI
    } catch (e) {
      _setError('Failed to create screen: $e');
    }
  }

  // Delete screen
  Future<void> deleteScreen(String screenId) async {
    try {
      _setError(null);
      
      final screenToDelete = getScreenById(screenId);
      if (screenToDelete == null) {
        _setError('Screen not found');
        return;
      }

      // Don't allow deleting the last screen
      if (_screens.length <= 1) {
        _setError('Cannot delete the last screen');
        return;
      }

      await _screenService.deleteScreen(screenId);

      // Reorder remaining screens
      final remainingScreens = _screens
          .where((screen) => screen.id != screenId)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      if (remainingScreens.isNotEmpty) {
        final reorderedIds = remainingScreens
            .asMap()
            .entries
            .map((entry) => remainingScreens[entry.key].id)
            .toList();

        await _screenService.reorderScreens(
          remainingScreens.first.projectId,
          reorderedIds,
        );
      }

      // The stream will automatically update the UI
    } catch (e) {
      _setError('Failed to delete screen: $e');
    }
  }

  // Reorder screens
  Future<void> reorderScreens(List<String> newOrder) async {
    if (newOrder.length != _screens.length) {
      _setError('Invalid reorder operation');
      return;
    }

    try {
      _setError(null);
      
      if (_screens.isNotEmpty) {
        await _screenService.reorderScreens(
          _screens.first.projectId,
          newOrder,
        );
      }
      
      // The stream will automatically update the UI
    } catch (e) {
      _setError('Failed to reorder screens: $e');
    }
  }

  // Update screen annotation with debouncing
  void updateScreenAnnotation({
    required String screenId,
    required String languageCode,
    required String annotation,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      _performUpdateScreenAnnotation(
        screenId: screenId,
        languageCode: languageCode,
        annotation: annotation,
      );
    });
  }

  Future<void> _performUpdateScreenAnnotation({
    required String screenId,
    required String languageCode,
    required String annotation,
  }) async {
    try {
      _setError(null);
      await _screenService.updateScreenAnnotation(
        screenId: screenId,
        languageCode: languageCode,
        annotation: annotation,
      );
    } catch (e) {
      _setError('Failed to update annotation: $e');
    }
  }

  // Update screen settings with debouncing
  void updateScreenSettings({
    required String screenId,
    required ScreenSettings settings,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      _performUpdateScreenSettings(
        screenId: screenId,
        settings: settings,
      );
    });
  }

  Future<void> _performUpdateScreenSettings({
    required String screenId,
    required ScreenSettings settings,
  }) async {
    try {
      _setError(null);
      await _screenService.updateScreenSettings(
        screenId: screenId,
        settings: settings,
      );
    } catch (e) {
      _setError('Failed to update settings: $e');
    }
  }

  // Clear error
  void clearError() {
    _setError(null);
  }

  @override
  void dispose() {
    _screensSubscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}