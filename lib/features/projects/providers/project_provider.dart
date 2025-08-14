import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../providers/app_providers.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/project_model.dart';

part 'project_provider.g.dart';

// Main projects stream provider that depends on current user
@riverpod
Stream<List<ProjectModel>> projectsStream(Ref ref) {
  final currentUser = ref.watch(currentUserProvider);
  
  if (currentUser == null) {
    return Stream.value([]);
  }
  
  final projectService = ref.read(projectServiceProvider);
  return projectService.streamUserProjects(currentUser.id);
}

// Project actions notifier (for create/delete operations)
@riverpod
class ProjectsNotifier extends _$ProjectsNotifier {
  @override
  String build() {
    return 'ready'; // Simple state tracker
  }

  Future<void> createProject({
    required String appName,
    required List<String> platforms,
    required Map<String, List<String>> devices,
  }) async {
    // Get current user directly from Firebase Auth service instead of stream
    final authService = ref.read(authServiceProvider);
    final firebaseUser = authService.currentUser;
    
    if (firebaseUser == null) {
      return;
    }
    
    // Create AppUser from Firebase user
    final currentUser = AppUser(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      createdAt: DateTime.now(),
      exportCount: 0,
    );
    
    try {
      final projectService = ref.read(projectServiceProvider);
      final id = const Uuid().v4();
      final now = DateTime.now();
      
      final project = ProjectModel(
        id: id,
        userId: currentUser.id,
        appName: appName,
        platforms: platforms,
        devices: devices,
        createdAt: now,
        updatedAt: now,
      );
      
      await projectService.createProject(project);
      
      // Invalidate the projects stream to refresh the list
      ref.invalidate(projectsStreamProvider);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      final projectService = ref.read(projectServiceProvider);
      await projectService.deleteProject(id);
      // Invalidate the projects stream to refresh the list
      ref.invalidate(projectsStreamProvider);
    } catch (error) {
      rethrow;
    }
  }
}