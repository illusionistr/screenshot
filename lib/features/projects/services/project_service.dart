import '../../../core/constants/api_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../models/project_model.dart';

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
}


