import 'package:flutter/material.dart';

enum BackgroundType {
  solid('solid', 'Solid Color'),
  gradient('gradient', 'Gradient'),
  image('image', 'Image');

  const BackgroundType(this.id, this.displayName);

  final String id;
  final String displayName;

  factory BackgroundType.fromString(String value) {
    return BackgroundType.values.firstWhere(
      (type) => type.id == value,
      orElse: () => BackgroundType.solid,
    );
  }
}

class ScreenBackground {
  final BackgroundType type;
  final Color? solidColor;
  final LinearGradient? gradient;
  final String? imageUrl;
  final String? imageId;

  const ScreenBackground({
    required this.type,
    this.solidColor,
    this.gradient,
    this.imageUrl,
    this.imageId,
  });

  static const ScreenBackground defaultBackground = ScreenBackground(
    type: BackgroundType.gradient,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, Colors.white],
    ),
  );

  ScreenBackground copyWith({
    BackgroundType? type,
    Color? solidColor,
    LinearGradient? gradient,
    String? imageUrl,
    String? imageId,
  }) {
    return ScreenBackground(
      type: type ?? this.type,
      solidColor: solidColor ?? this.solidColor,
      gradient: gradient ?? this.gradient,
      imageUrl: imageUrl ?? this.imageUrl,
      imageId: imageId ?? this.imageId,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': type.id,
    };

    switch (type) {
      case BackgroundType.solid:
        if (solidColor != null) {
          json['solidColor'] = solidColor!.value;
        }
        break;
      case BackgroundType.gradient:
        if (gradient != null) {
          json['gradient'] = {
            'colors': gradient!.colors.map((c) => c.value).toList(),
            'begin': _alignmentToJson(gradient!.begin as Alignment),
            'end': _alignmentToJson(gradient!.end as Alignment),
          };
        }
        break;
      case BackgroundType.image:
        if (imageUrl != null) {
          json['imageUrl'] = imageUrl;
        }
        if (imageId != null) {
          json['imageId'] = imageId;
        }
        break;
    }

    return json;
  }

  factory ScreenBackground.fromJson(Map<String, dynamic> json) {
    final type = BackgroundType.fromString(json['type'] as String);

    switch (type) {
      case BackgroundType.solid:
        return ScreenBackground(
          type: type,
          solidColor: json['solidColor'] != null 
            ? Color(json['solidColor'] as int)
            : null,
        );
      case BackgroundType.gradient:
        LinearGradient? gradient;
        if (json['gradient'] != null) {
          final gradientData = json['gradient'] as Map<String, dynamic>;
          gradient = LinearGradient(
            colors: (gradientData['colors'] as List)
                .map((c) => Color(c as int))
                .toList(),
            begin: _alignmentFromJson(gradientData['begin']),
            end: _alignmentFromJson(gradientData['end']),
          );
        }
        return ScreenBackground(
          type: type,
          gradient: gradient,
        );
      case BackgroundType.image:
        return ScreenBackground(
          type: type,
          imageUrl: json['imageUrl'] as String?,
          imageId: json['imageId'] as String?,
        );
    }
  }

  static Map<String, double> _alignmentToJson(Alignment alignment) {
    return {
      'x': alignment.x,
      'y': alignment.y,
    };
  }

  static Alignment _alignmentFromJson(Map<String, dynamic> json) {
    return Alignment(
      json['x'] as double,
      json['y'] as double,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScreenBackground &&
        other.type == type &&
        other.solidColor == solidColor &&
        other.gradient == gradient &&
        other.imageUrl == imageUrl &&
        other.imageId == imageId;
  }

  @override
  int get hashCode {
    return Object.hash(type, solidColor, gradient, imageUrl, imageId);
  }

  @override
  String toString() {
    return 'ScreenBackground(type: $type, solidColor: $solidColor, gradient: $gradient, imageUrl: $imageUrl, imageId: $imageId)';
  }
}

class BackgroundImage {
  final String id;
  final String url;
  final String filename;
  final DateTime uploadedAt;
  final int fileSize;
  final String userId;

  const BackgroundImage({
    required this.id,
    required this.url,
    required this.filename,
    required this.uploadedAt,
    required this.fileSize,
    required this.userId,
  });

  BackgroundImage copyWith({
    String? id,
    String? url,
    String? filename,
    DateTime? uploadedAt,
    int? fileSize,
    String? userId,
  }) {
    return BackgroundImage(
      id: id ?? this.id,
      url: url ?? this.url,
      filename: filename ?? this.filename,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      fileSize: fileSize ?? this.fileSize,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'filename': filename,
      'uploadedAt': uploadedAt.millisecondsSinceEpoch,
      'fileSize': fileSize,
      'userId': userId,
    };
  }

  factory BackgroundImage.fromJson(Map<String, dynamic> json) {
    return BackgroundImage(
      id: json['id'] as String,
      url: json['url'] as String,
      filename: json['filename'] as String,
      uploadedAt: DateTime.fromMillisecondsSinceEpoch(json['uploadedAt'] as int),
      fileSize: json['fileSize'] as int,
      userId: json['userId'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BackgroundImage &&
        other.id == id &&
        other.url == url &&
        other.filename == filename &&
        other.uploadedAt == uploadedAt &&
        other.fileSize == fileSize &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(id, url, filename, uploadedAt, fileSize, userId);
  }

  @override
  String toString() {
    return 'BackgroundImage(id: $id, filename: $filename, uploadedAt: $uploadedAt, fileSize: $fileSize, userId: $userId)';
  }
}