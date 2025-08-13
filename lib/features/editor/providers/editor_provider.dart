import 'package:flutter/foundation.dart';

import '../../../config/dependency_injection.dart';
import '../../projects/models/project_model.dart';
import '../../projects/services/project_service.dart';
import '../../auth/providers/auth_provider.dart';

class EditorProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  final ProjectService _projectService = serviceLocator<ProjectService>();

  ProjectModel? _currentProject;
  int _selectedScreenIndex = 0;
  String _currentLanguage = 'en_US';
  String? _currentDevice;
  bool _isLoading = false;
  String? _error;
  bool _isSaving = false;

  EditorProvider({required AuthProvider authProvider})
      : _authProvider = authProvider;

  // Getters
  ProjectModel? get currentProject => _currentProject;
  int get selectedScreenIndex => _selectedScreenIndex;
  String get currentLanguage => _currentLanguage;
  String? get currentDevice => _currentDevice;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSaving => _isSaving;
  bool get hasProject => _currentProject != null;

  // Available devices from current project
  List<String> get availableDevices {
    return _currentProject?.devices ?? [];
  }

  // Current device or first available device
  String? get selectedDevice {
    if (_currentDevice != null && availableDevices.contains(_currentDevice)) {
      return _currentDevice;
    }
    return availableDevices.isNotEmpty ? availableDevices.first : null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSaving(bool saving) {
    _isSaving = saving;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Load project for editing
  Future<void> loadProject(String projectId) async {
    if (_currentProject?.id == projectId) {
      return; // Already loaded
    }

    _setLoading(true);
    _setError(null);

    try {
      final project = await _projectService.getProject(projectId);
      
      if (project == null) {
        _setError('Project not found');
        _setLoading(false);
        return;
      }

      // Verify user owns this project
      final userId = _authProvider.currentUser?.id;
      if (userId == null || project.userId != userId) {
        _setError('Access denied');
        _setLoading(false);
        return;
      }

      _currentProject = project;
      
      // Set initial device if not set or invalid
      if (_currentDevice == null || !availableDevices.contains(_currentDevice)) {
        _currentDevice = availableDevices.isNotEmpty ? availableDevices.first : null;
      }

      // Reset selected screen index
      _selectedScreenIndex = 0;

      _setLoading(false);
    } catch (e) {
      _setError('Failed to load project: $e');
      _setLoading(false);
    }
  }

  // Select screen by index
  void selectScreen(int index) {
    if (index >= 0) {
      _selectedScreenIndex = index;
      notifyListeners();
    }
  }

  // Select next screen
  void selectNextScreen() {
    _selectedScreenIndex++;
    notifyListeners();
  }

  // Select previous screen
  void selectPreviousScreen() {
    if (_selectedScreenIndex > 0) {
      _selectedScreenIndex--;
      notifyListeners();
    }
  }

  // Change current language
  void changeLanguage(String languageCode) {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      notifyListeners();
    }
  }

  // Change current device
  void changeDevice(String device) {
    if (availableDevices.contains(device) && _currentDevice != device) {
      _currentDevice = device;
      notifyListeners();
    }
  }

  // Update project name
  Future<void> updateProjectName(String newName) async {
    if (_currentProject == null || newName.trim().isEmpty) {
      return;
    }

    final trimmedName = newName.trim();
    if (_currentProject!.appName == trimmedName) {
      return; // No change
    }

    _setSaving(true);
    _setError(null);

    try {
      await _projectService.updateProject(_currentProject!.id, {
        'appName': trimmedName,
      });

      _currentProject = _currentProject!.copyWith(
        appName: trimmedName,
        updatedAt: DateTime.now(),
      );

      _setSaving(false);
    } catch (e) {
      _setError('Failed to update project name: $e');
      _setSaving(false);
    }
  }

  // Clear error
  void clearError() {
    _setError(null);
  }

  // Reset editor state
  void reset() {
    _currentProject = null;
    _selectedScreenIndex = 0;
    _currentLanguage = 'en_US';
    _currentDevice = null;
    _isLoading = false;
    _error = null;
    _isSaving = false;
    notifyListeners();
  }

}