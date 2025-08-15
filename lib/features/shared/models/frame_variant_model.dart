class FrameVariantModel {
  final String id;
  final String name;
  final String assetPath;
  final String deviceId;

  const FrameVariantModel({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.deviceId,
  });

  FrameVariantModel copyWith({
    String? id,
    String? name,
    String? assetPath,
    String? deviceId,
  }) {
    return FrameVariantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      assetPath: assetPath ?? this.assetPath,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'assetPath': assetPath,
      'deviceId': deviceId,
    };
  }

  factory FrameVariantModel.fromJson(Map<String, dynamic> json) {
    return FrameVariantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      assetPath: json['assetPath'] as String,
      deviceId: json['deviceId'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FrameVariantModel &&
        other.id == id &&
        other.name == name &&
        other.assetPath == assetPath &&
        other.deviceId == deviceId;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, assetPath, deviceId);
  }

  @override
  String toString() {
    return 'FrameVariantModel(id: $id, name: $name, deviceId: $deviceId)';
  }
}