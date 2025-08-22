import 'dart:typed_data';

enum ExportStatus {
  pending('pending', 'Pending'),
  validating('validating', 'Validating'),
  processing('processing', 'Processing'),
  completed('completed', 'Completed'),
  failed('failed', 'Failed'),
  cancelled('cancelled', 'Cancelled');

  const ExportStatus(this.id, this.displayName);

  final String id;
  final String displayName;
}

class ExportProgress {
  final int currentScreen;
  final int totalScreens;
  final String currentScreenId;
  final String currentScreenName;
  final ExportStatus status;
  final String? errorMessage;
  final double progressPercentage;

  const ExportProgress({
    required this.currentScreen,
    required this.totalScreens,
    required this.currentScreenId,
    required this.currentScreenName,
    required this.status,
    this.errorMessage,
  }) : progressPercentage = totalScreens > 0 ? (currentScreen / totalScreens) * 100 : 0;

  ExportProgress copyWith({
    int? currentScreen,
    int? totalScreens,
    String? currentScreenId,
    String? currentScreenName,
    ExportStatus? status,
    String? errorMessage,
  }) {
    return ExportProgress(
      currentScreen: currentScreen ?? this.currentScreen,
      totalScreens: totalScreens ?? this.totalScreens,
      currentScreenId: currentScreenId ?? this.currentScreenId,
      currentScreenName: currentScreenName ?? this.currentScreenName,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isCompleted => status == ExportStatus.completed;
  bool get isFailed => status == ExportStatus.failed;
  bool get isCancelled => status == ExportStatus.cancelled;
  bool get isFinished => isCompleted || isFailed || isCancelled;
  bool get isProcessing => status == ExportStatus.processing;
  bool get canCancel => status == ExportStatus.validating || status == ExportStatus.processing;

  @override
  String toString() {
    return 'ExportProgress(currentScreen: $currentScreen, totalScreens: $totalScreens, status: $status, progressPercentage: ${progressPercentage.toStringAsFixed(1)}%)';
  }
}

class ExportedFile {
  final String filename;
  final Uint8List data;
  final String screenId;
  final String screenName;
  final DateTime exportedAt;
  final int fileSizeBytes;

  const ExportedFile({
    required this.filename,
    required this.data,
    required this.screenId,
    required this.screenName,
    required this.exportedAt,
    required this.fileSizeBytes,
  });

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '${fileSizeBytes}B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  @override
  String toString() {
    return 'ExportedFile(filename: $filename, screenId: $screenId, size: $fileSizeFormatted)';
  }
}

class ExportResult {
  final List<ExportedFile> exportedFiles;
  final List<String> skippedScreens;
  final List<String> errors;
  final ExportStatus finalStatus;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String projectName;
  final String deviceId;
  final String languageCode;

  const ExportResult({
    required this.exportedFiles,
    required this.skippedScreens,
    required this.errors,
    required this.finalStatus,
    required this.startedAt,
    this.completedAt,
    required this.projectName,
    required this.deviceId,
    required this.languageCode,
  });

  bool get isSuccessful => finalStatus == ExportStatus.completed && errors.isEmpty;
  bool get hasErrors => errors.isNotEmpty;
  bool get hasSkippedScreens => skippedScreens.isNotEmpty;
  
  int get totalFilesExported => exportedFiles.length;
  int get totalSizeBytes => exportedFiles.fold(0, (sum, file) => sum + file.fileSizeBytes);
  
  String get totalSizeFormatted {
    if (totalSizeBytes < 1024) {
      return '${totalSizeBytes}B';
    } else if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  Duration? get totalDuration {
    if (completedAt == null) return null;
    return completedAt!.difference(startedAt);
  }

  String get summaryMessage {
    if (finalStatus == ExportStatus.cancelled) {
      return 'Export cancelled';
    } else if (finalStatus == ExportStatus.failed) {
      return 'Export failed: ${errors.isNotEmpty ? errors.first : 'Unknown error'}';
    } else if (isSuccessful) {
      return 'Successfully exported $totalFilesExported screens for $deviceId ($languageCode)';
    } else {
      return 'Export completed with ${errors.length} errors';
    }
  }

  ExportResult copyWith({
    List<ExportedFile>? exportedFiles,
    List<String>? skippedScreens,
    List<String>? errors,
    ExportStatus? finalStatus,
    DateTime? startedAt,
    DateTime? completedAt,
    String? projectName,
    String? deviceId,
    String? languageCode,
  }) {
    return ExportResult(
      exportedFiles: exportedFiles ?? this.exportedFiles,
      skippedScreens: skippedScreens ?? this.skippedScreens,
      errors: errors ?? this.errors,
      finalStatus: finalStatus ?? this.finalStatus,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      projectName: projectName ?? this.projectName,
      deviceId: deviceId ?? this.deviceId,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  String toString() {
    return 'ExportResult(status: $finalStatus, files: $totalFilesExported, errors: ${errors.length}, skipped: ${skippedScreens.length})';
  }
}

class ExportConfiguration {
  final String projectName;
  final String deviceId;
  final String languageCode;
  final List<String> screenIds;
  final bool exportOnlyValid; // Skip screens without screenshots
  final bool highQuality; // Use high quality rendering
  final String fileFormat; // For now, only PNG

  const ExportConfiguration({
    required this.projectName,
    required this.deviceId,
    required this.languageCode,
    required this.screenIds,
    this.exportOnlyValid = true,
    this.highQuality = true,
    this.fileFormat = 'png',
  });

  String generateFilename(int screenIndex, String screenId) {
    // Sanitize project name for filesystem compatibility
    final sanitizedProjectName = projectName
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special chars except word chars, spaces, hyphens
        .replaceAll(RegExp(r'\s+'), '_') // Replace spaces with underscores
        .replaceAll(RegExp(r'_+'), '_') // Replace multiple underscores with single
        .trim();
    
    // Use 1-based indexing for screen numbers
    final screenNumber = screenIndex + 1;
    
    return '${sanitizedProjectName}_screen${screenNumber}_${deviceId}_$languageCode.$fileFormat';
  }

  ExportConfiguration copyWith({
    String? projectName,
    String? deviceId,
    String? languageCode,
    List<String>? screenIds,
    bool? exportOnlyValid,
    bool? highQuality,
    String? fileFormat,
  }) {
    return ExportConfiguration(
      projectName: projectName ?? this.projectName,
      deviceId: deviceId ?? this.deviceId,
      languageCode: languageCode ?? this.languageCode,
      screenIds: screenIds ?? this.screenIds,
      exportOnlyValid: exportOnlyValid ?? this.exportOnlyValid,
      highQuality: highQuality ?? this.highQuality,
      fileFormat: fileFormat ?? this.fileFormat,
    );
  }

  @override
  String toString() {
    return 'ExportConfiguration(project: $projectName, device: $deviceId, language: $languageCode, screens: ${screenIds.length})';
  }
}