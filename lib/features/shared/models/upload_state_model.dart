import 'dart:html' as html;

import 'screenshot_model.dart';

/// Represents the progress of a single file upload
class UploadProgress {
  final String fileId;
  final String filename;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final String? errorMessage;
  final int? fileSize;

  const UploadProgress({
    required this.fileId,
    required this.filename,
    required this.progress,
    this.isCompleted = false,
    this.errorMessage,
    this.fileSize,
  });

  UploadProgress copyWith({
    String? fileId,
    String? filename,
    double? progress,
    bool? isCompleted,
    String? errorMessage,
    int? fileSize,
  }) {
    return UploadProgress(
      fileId: fileId ?? this.fileId,
      filename: filename ?? this.filename,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      errorMessage: errorMessage ?? this.errorMessage,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  bool get hasError => errorMessage != null;
  bool get isInProgress => !isCompleted && !hasError;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UploadProgress &&
        other.fileId == fileId &&
        other.filename == filename &&
        other.progress == progress &&
        other.isCompleted == isCompleted &&
        other.errorMessage == errorMessage &&
        other.fileSize == fileSize;
  }

  @override
  int get hashCode {
    return fileId.hashCode ^
        filename.hashCode ^
        progress.hashCode ^
        isCompleted.hashCode ^
        errorMessage.hashCode ^
        fileSize.hashCode;
  }

  @override
  String toString() {
    return 'UploadProgress(fileId: $fileId, filename: $filename, progress: $progress, isCompleted: $isCompleted, errorMessage: $errorMessage, fileSize: $fileSize)';
  }
}

/// Represents the result of a completed upload
class UploadResult {
  final String fileId;
  final ScreenshotModel? screenshot;
  final String? errorMessage;
  final DateTime completedAt;

  const UploadResult({
    required this.fileId,
    this.screenshot,
    this.errorMessage,
    required this.completedAt,
  });

  bool get isSuccess => screenshot != null && errorMessage == null;
  bool get hasError => errorMessage != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UploadResult &&
        other.fileId == fileId &&
        other.screenshot == screenshot &&
        other.errorMessage == errorMessage &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode {
    return fileId.hashCode ^
        screenshot.hashCode ^
        errorMessage.hashCode ^
        completedAt.hashCode;
  }

  @override
  String toString() {
    return 'UploadResult(fileId: $fileId, screenshot: $screenshot, errorMessage: $errorMessage, completedAt: $completedAt)';
  }
}

/// Configuration for upload operations
class UploadConfig {
  final String projectId;
  final String deviceId;
  final String languageCode;
  final bool allowMultiple;
  final int maxFiles;
  final Function(UploadProgress)? onProgress;
  final Function(UploadResult)? onComplete;
  final Function(String)? onError;

  const UploadConfig({
    required this.projectId,
    required this.deviceId,
    required this.languageCode,
    this.allowMultiple = true,
    this.maxFiles = 10,
    this.onProgress,
    this.onComplete,
    this.onError,
  });

  UploadConfig copyWith({
    String? projectId,
    String? deviceId,
    String? languageCode,
    bool? allowMultiple,
    int? maxFiles,
    Function(UploadProgress)? onProgress,
    Function(UploadResult)? onComplete,
    Function(String)? onError,
  }) {
    return UploadConfig(
      projectId: projectId ?? this.projectId,
      deviceId: deviceId ?? this.deviceId,
      languageCode: languageCode ?? this.languageCode,
      allowMultiple: allowMultiple ?? this.allowMultiple,
      maxFiles: maxFiles ?? this.maxFiles,
      onProgress: onProgress ?? this.onProgress,
      onComplete: onComplete ?? this.onComplete,
      onError: onError ?? this.onError,
    );
  }
}

/// Represents a file being prepared for upload
class UploadFile {
  final String id;
  final html.File file;
  final String deviceId;
  final String languageCode;
  final DateTime addedAt;

  const UploadFile({
    required this.id,
    required this.file,
    required this.deviceId,
    required this.languageCode,
    required this.addedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UploadFile &&
        other.id == id &&
        other.file == file &&
        other.deviceId == deviceId &&
        other.languageCode == languageCode &&
        other.addedAt == addedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        file.hashCode ^
        deviceId.hashCode ^
        languageCode.hashCode ^
        addedAt.hashCode;
  }

  @override
  String toString() {
    return 'UploadFile(id: $id, filename: ${file.name}, deviceId: $deviceId, languageCode: $languageCode, addedAt: $addedAt)';
  }
}