import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String userId;
  final String appName;
  final String platform; // 'android' or 'ios'
  final List<String> devices; // device names for the selected platform
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectModel({
    required this.id,
    required this.userId,
    required this.appName,
    required this.platform,
    required this.devices,
    required this.createdAt,
    required this.updatedAt,
  });

  ProjectModel copyWith({
    String? appName,
    String? platform,
    List<String>? devices,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id,
      userId: userId,
      appName: appName ?? this.appName,
      platform: platform ?? this.platform,
      devices: devices ?? this.devices,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProjectModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ProjectModel(
      id: doc.id,
      userId: data['userId'] as String,
      appName: data['appName'] as String,
      platform: data['platform'] as String,
      devices: List<String>.from(data['devices'] as List),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'appName': appName,
      'platform': platform,
      'devices': devices,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
