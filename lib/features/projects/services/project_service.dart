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
          queryBuilder: (q) => q
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true),
        )
        .map((snapshot) =>
            snapshot.docs.map(ProjectModel.fromFirestore).toList());
  }

  Future<ProjectModel?> getProject(String projectId) async {
    final data = await firebaseService.getDocument(
      collectionPath: ApiConstants.projectsCollection,
      documentId: projectId,
    );
    
    if (data == null) return null;
    
    // Create a mock DocumentSnapshot since we only have the data
    final doc = firebaseService.firestore
        .collection(ApiConstants.projectsCollection)
        .doc(projectId);
    
    // We need to create a snapshot-like object
    final snapshot = await doc.get();
    return ProjectModel.fromFirestore(snapshot);
  }

  Future<void> updateProject(String projectId, Map<String, dynamic> updates) async {
    await firebaseService.updateDocument(
      collectionPath: ApiConstants.projectsCollection,
      documentId: projectId,
      data: updates,
    );
  }

  Future<void> updateProjectModel(ProjectModel project) async {
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
