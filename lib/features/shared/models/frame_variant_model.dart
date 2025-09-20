class FrameVariantModel {
  final String id;
  final String name;
  final String? assetPath;
  final String deviceId;
  final bool isGeneric;

  const FrameVariantModel({
    required this.id,
    required this.name,
    this.assetPath,
    required this.deviceId,
    this.isGeneric = false,
  });

  FrameVariantModel copyWith({
    String? id,
    String? name,
    String? assetPath,
    String? deviceId,
    bool? isGeneric,
  }) {
    return FrameVariantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      assetPath: assetPath ?? this.assetPath,
      deviceId: deviceId ?? this.deviceId,
      isGeneric: isGeneric ?? this.isGeneric,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'assetPath': assetPath,
      'deviceId': deviceId,
      'isGeneric': isGeneric,
    };
  }

  factory FrameVariantModel.fromJson(Map<String, dynamic> json) {
    return FrameVariantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      assetPath: json['assetPath'] as String?,
      deviceId: json['deviceId'] as String,
      isGeneric: json['isGeneric'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FrameVariantModel &&
        other.id == id &&
        other.name == name &&
        other.assetPath == assetPath &&
        other.deviceId == deviceId &&
        other.isGeneric == isGeneric;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, assetPath, deviceId, isGeneric);
  }

  @override
  String toString() {
    return 'FrameVariantModel(id: $id, name: $name, deviceId: $deviceId)';
  }
}