import 'package:cloud_firestore/cloud_firestore.dart';
import 'screen_settings.dart';

class ScreenModel {
  final String id;
  final String projectId;
  final String userId;
  final int order; // for reordering
  final Map<String, String> screenshots; // {"Galaxy S8": "url", "Pixel 3": "url"}
  final Map<String, String> annotations; // {"en_US": "text", "fr_FR": "text"}
  final ScreenSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScreenModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.order,
    required this.screenshots,
    required this.annotations,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  ScreenModel copyWith({
    int? order,
    Map<String, String>? screenshots,
    Map<String, String>? annotations,
    ScreenSettings? settings,
    DateTime? updatedAt,
  }) {
    return ScreenModel(
      id: id,
      projectId: projectId,
      userId: userId,
      order: order ?? this.order,
      screenshots: screenshots ?? this.screenshots,
      annotations: annotations ?? this.annotations,
      settings: settings ?? this.settings,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ScreenModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ScreenModel(
      id: doc.id,
      projectId: data['projectId'] as String,
      userId: data['userId'] as String,
      order: data['order'] as int,
      screenshots: Map<String, String>.from(data['screenshots'] ?? {}),
      annotations: Map<String, String>.from(data['annotations'] ?? {}),
      settings: ScreenSettings.fromMap(data['settings'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'userId': userId,
      'order': order,
      'screenshots': screenshots,
      'annotations': annotations,
      'settings': settings.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}