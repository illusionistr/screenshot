import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../config/dependency_injection.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  ProjectProvider({ProjectService? projectService, required this.authProvider})
      : _projectService = projectService ?? serviceLocator<ProjectService>();

  final ProjectService _projectService;
  final AuthProvider authProvider;

  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  StreamSubscription<List<ProjectModel>>? _subscription;

  void listenToProjects() {
    final userId = authProvider.currentUser?.id;
    if (userId == null) return;
    _subscription?.cancel();
    _subscription = _projectService.streamUserProjects(userId).listen((event) {
      _projects = event;
      notifyListeners();
    });
  }

  Future<void> createProject({
    required String appName,
    required List<String> platforms,
    required Map<String, List<String>> devices,
  }) async {
    final userId = authProvider.currentUser?.id;
    if (userId == null) return;

    _setLoading(true);
    try {
      final id = const Uuid().v4();
      final now = DateTime.now();
      final project = ProjectModel(
        id: id,
        userId: userId,
        appName: appName,
        platforms: platforms,
        devices: devices,
        createdAt: now,
        updatedAt: now,
      );
      await _projectService.createProject(project);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProject(String id) async {
    _setLoading(true);
    try {
      await _projectService.deleteProject(id);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}


