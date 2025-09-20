import '../../../core/constants/api_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firebase_service.dart';
import '../models/project_model.dart';
import '../models/project_screen_config.dart';

class ProjectService {
  ProjectService({required this.firebaseService});

  final FirebaseService firebaseService;

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
}


