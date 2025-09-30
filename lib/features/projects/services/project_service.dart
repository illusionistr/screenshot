import '../../../core/constants/api_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firebase_service.dart';
import '../../../core/services/storage_service.dart';
import '../../shared/models/screenshot_model.dart';
import '../../shared/services/upload_service.dart';
import '../models/project_model.dart';
import '../models/project_screen_config.dart';

class ProjectService {
  ProjectService({
    required this.firebaseService,
    required this.storageService,
    required this.uploadService,
  });

  final FirebaseService firebaseService;
  final StorageService storageService;
  final UploadService uploadService;

  Future<String> createProject(ProjectModel project) async {
    return firebaseService.createDocument(
      collectionPath: ApiConstants.projectsCollection,
      data: project.toFirestore(),
      documentId: project.id.isNotEmpty ? project.id : null,
    );
  }

  Stream<List<ProjectModel>> streamUserProjects(String userId) {
    return firebaseService
        .streamCollection(
          collectionPath: ApiConstants.projectsCollection,
          queryBuilder: (q) => q.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true),
        )
        .map((snapshot) => snapshot.docs.map(ProjectModel.fromFirestore).toList());
  }

  Future<void> updateProject(ProjectModel project) async {
    await firebaseService.updateDocument(
      collectionPath: ApiConstants.projectsCollection,
      documentId: project.id,
      data: project.toFirestore(),
    );
  }

  Future<void> deleteProject(String projectId) async {
    await firebaseService.deleteDocument(
      collectionPath: ApiConstants.projectsCollection,
      documentId: projectId,
    );
  }

  // New helpers for per-screen persistence
  Future<void> updateScreenConfig({
    required String projectId,
    required String screenId,
    required ProjectScreenConfig config,
  }) async {
    await firebaseService.updateDocument(
      collectionPath: ApiConstants.projectsCollection,
      documentId: projectId,
      data: {
        'screenConfigs.$screenId': config.toJson(),
      },
    );
  }

  Future<void> updateScreenOrder({
    required String projectId,
    required List<String> order,
  }) async {
    await firebaseService.updateDocument(
      collectionPath: ApiConstants.projectsCollection,
      documentId: projectId,
      data: {
        'screenOrder': order,
      },
    );
  }

  Future<void> removeScreen({
    required String projectId,
    required String screenId,
    required List<String> newOrder,
  }) async {
    await firebaseService.updateDocument(
      collectionPath: ApiConstants.projectsCollection,
      documentId: projectId,
      data: {
        'screenConfigs.$screenId': FieldValue.delete(),
        'screenOrder': newOrder,
      },
    );
  }

  /// Update project settings (name, devices, languages)
  /// Handles cascading deletion of screenshots and translations
  Future<void> updateProjectSettings({
    required ProjectModel currentProject,
    required String appName,
    required List<String> platforms,
    required List<String> deviceIds,
    required List<String> supportedLanguages,
  }) async {
    // Calculate what's being removed
    final removedDevices = currentProject.deviceIds
        .where((id) => !deviceIds.contains(id))
        .toList();
    final removedLanguages = currentProject.supportedLanguages
        .where((lang) => !supportedLanguages.contains(lang))
        .toList();

    // Start with the current project
    var updatedProject = currentProject;

    // Remove devices and their associated data
    for (final deviceId in removedDevices) {
      updatedProject = updatedProject.removeDevice(deviceId);

      // Delete screenshots from storage
      await _deleteScreenshotsForDevice(
        projectId: currentProject.id,
        deviceId: deviceId,
        screenshots: currentProject.screenshots,
      );
    }

    // Remove languages and their associated data
    for (final languageCode in removedLanguages) {
      updatedProject = updatedProject.removeLanguage(languageCode);

      // Delete screenshots from storage
      await _deleteScreenshotsForLanguage(
        projectId: currentProject.id,
        languageCode: languageCode,
        screenshots: currentProject.screenshots,
      );
    }

    // Update basic project properties
    updatedProject = updatedProject.copyWith(
      appName: appName,
      platforms: platforms,
      deviceIds: deviceIds,
      supportedLanguages: supportedLanguages,
      updatedAt: DateTime.now(),
    );

    // Save the updated project
    await updateProject(updatedProject);
  }

  /// Delete all screenshots for a specific device from Firebase Storage
  Future<void> _deleteScreenshotsForDevice({
    required String projectId,
    required String deviceId,
    required Map<String, Map<String, List<ScreenshotModel>>> screenshots,
  }) async {
    for (final languageEntry in screenshots.entries) {
      final deviceScreenshots = languageEntry.value[deviceId];

      if (deviceScreenshots != null) {
        for (final screenshot in deviceScreenshots) {
          try {
            final storageUrl = screenshot.storageUrl;
            if (storageUrl.isNotEmpty) {
              final storagePath = uploadService.getStoragePathFromUrl(storageUrl);
              await storageService.deleteFile(storagePath);
            }
          } catch (e) {
            // Log error but continue with other deletions
            print('Warning: Failed to delete screenshot: $e');
          }
        }
      }
    }
  }

  /// Delete all screenshots for a specific language from Firebase Storage
  Future<void> _deleteScreenshotsForLanguage({
    required String projectId,
    required String languageCode,
    required Map<String, Map<String, List<ScreenshotModel>>> screenshots,
  }) async {
    final languageScreenshots = screenshots[languageCode];

    if (languageScreenshots != null) {
      for (final deviceEntry in languageScreenshots.entries) {
        final deviceScreenshots = deviceEntry.value;

        for (final screenshot in deviceScreenshots) {
          try {
            final storageUrl = screenshot.storageUrl;
            if (storageUrl.isNotEmpty) {
              final storagePath = uploadService.getStoragePathFromUrl(storageUrl);
              await storageService.deleteFile(storagePath);
            }
          } catch (e) {
            // Log error but continue with other deletions
            print('Warning: Failed to delete screenshot: $e');
          }
        }
      }
    }
  }
}


