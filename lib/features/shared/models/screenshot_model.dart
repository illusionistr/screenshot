import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

class Dimensions {
  final int width;
  final int height;

  const Dimensions({
    required this.width,
    required this.height,
  });

  Dimensions copyWith({
    int? width,
    int? height,
  }) {
    return Dimensions(
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'width': width,
      'height': height,
    };
  }

  factory Dimensions.fromMap(Map<String, dynamic> map) {
    return Dimensions(
      width: map['width']?.toInt() ?? 0,
      height: map['height']?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Dimensions && other.width == width && other.height == height;
  }

  @override
  int get hashCode => width.hashCode ^ height.hashCode;

  @override
  String toString() => 'Dimensions(width: $width, height: $height)';
}

class ScreenshotModel extends BaseModel {
  final String id;
  final String filename;
  final String originalFilename;
  final String storageUrl;
  final String deviceId;
  final String languageCode;
  final DateTime uploadedAt;
  final int fileSize;
  final Dimensions dimensions;
  final String? thumbnailUrl;

  ScreenshotModel({
    required this.id,
    required this.filename,
    required this.originalFilename,
    required this.storageUrl,
    required this.deviceId,
    required this.languageCode,
    required this.uploadedAt,
    required this.fileSize,
    required this.dimensions,
    this.thumbnailUrl,
  });

  ScreenshotModel copyWith({
    String? id,
    String? filename,
    String? originalFilename,
    String? storageUrl,
    String? deviceId,
    String? languageCode,
    DateTime? uploadedAt,
    int? fileSize,
    Dimensions? dimensions,
    String? thumbnailUrl,
  }) {
    return ScreenshotModel(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      originalFilename: originalFilename ?? this.originalFilename,
      storageUrl: storageUrl ?? this.storageUrl,
      deviceId: deviceId ?? this.deviceId,
      languageCode: languageCode ?? this.languageCode,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      fileSize: fileSize ?? this.fileSize,
      dimensions: dimensions ?? this.dimensions,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filename': filename,
      'originalFilename': originalFilename,
      'storageUrl': storageUrl,
      'deviceId': deviceId,
      'languageCode': languageCode,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'fileSize': fileSize,
      'dimensions': dimensions.toMap(),
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory ScreenshotModel.fromMap(Map<String, dynamic> map) {
    return ScreenshotModel(
      id: map['id'] ?? '',
      filename: map['filename'] ?? '',
      originalFilename: map['originalFilename'] ?? '',
      storageUrl: map['storageUrl'] ?? '',
      deviceId: map['deviceId'] ?? '',
      languageCode: map['languageCode'] ?? '',
      uploadedAt: (map['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fileSize: map['fileSize']?.toInt() ?? 0,
      dimensions: Dimensions.fromMap(map['dimensions'] ?? {}),
      thumbnailUrl: map['thumbnailUrl'],
    );
  }

  factory ScreenshotModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ScreenshotModel.fromMap({...data, 'id': doc.id});
  }

  Map<String, dynamic> toFirestore() {
    final map = toMap();
    map.remove('id'); // Firestore document ID is handled separately
    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScreenshotModel &&
        other.id == id &&
        other.filename == filename &&
        other.originalFilename == originalFilename &&
        other.storageUrl == storageUrl &&
        other.deviceId == deviceId &&
        other.languageCode == languageCode &&
        other.uploadedAt == uploadedAt &&
        other.fileSize == fileSize &&
        other.dimensions == dimensions &&
        other.thumbnailUrl == thumbnailUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        filename.hashCode ^
        originalFilename.hashCode ^
        storageUrl.hashCode ^
        deviceId.hashCode ^
        languageCode.hashCode ^
        uploadedAt.hashCode ^
        fileSize.hashCode ^
        dimensions.hashCode ^
        thumbnailUrl.hashCode;
  }

  @override
  String toString() {
    return 'ScreenshotModel(id: $id, filename: $filename, originalFilename: $originalFilename, storageUrl: $storageUrl, deviceId: $deviceId, languageCode: $languageCode, uploadedAt: $uploadedAt, fileSize: $fileSize, dimensions: $dimensions, thumbnailUrl: $thumbnailUrl)';
  }
}