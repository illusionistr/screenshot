import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String userId;
  final String appName;
  final List<String> platforms;
  final Map<String, List<String>> devices; // { platform: [deviceNames] }
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectModel({
    required this.id,
    required this.userId,
    required this.appName,
    required this.platforms,
    required this.devices,
    required this.createdAt,
    required this.updatedAt,
  });

  ProjectModel copyWith({
    String? appName,
    List<String>? platforms,
    Map<String, List<String>>? devices,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id,
      userId: userId,
      appName: appName ?? this.appName,
      platforms: platforms ?? this.platforms,
      devices: devices ?? this.devices,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProjectModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final rawDevices = Map<String, dynamic>.from(data['devices'] as Map);
    return ProjectModel(
      id: doc.id,
      userId: data['userId'] as String,
      appName: data['appName'] as String,
      platforms: List<String>.from(data['platforms'] as List),
      devices: rawDevices.map((key, value) => MapEntry(key, List<String>.from(value as List))),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'appName': appName,
      'platforms': platforms,
      'devices': devices,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}


