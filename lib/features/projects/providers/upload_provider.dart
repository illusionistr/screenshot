import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/screenshot_model.dart';
import 'project_provider.dart';

part 'upload_provider.g.dart';

// Selected language for upload screen
@riverpod
class SelectedLanguage extends _$SelectedLanguage {
  @override
  String build(String projectId) {
    return 'en'; // Default to English
  }

  void setLanguage(String languageCode) {
    state = languageCode;
  }
}

// Upload progress state
class UploadProgress {
  final String filename;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final String? errorMessage;

  const UploadProgress({
    required this.filename,
    required this.progress,
    this.isCompleted = false,
    this.errorMessage,
  });

  UploadProgress copyWith({
    String? filename,
    double? progress,
    bool? isCompleted,
    String? errorMessage,
  }) {
    return UploadProgress(
      filename: filename ?? this.filename,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Upload progress provider
@riverpod
class UploadProgressNotifier extends _$UploadProgressNotifier {
  @override
  Map<String, UploadProgress> build() {
    return {};
  }

  void updateProgress(String fileId, UploadProgress progress) {
    state = {...state, fileId: progress};
  }

  void removeProgress(String fileId) {
    final newState = Map<String, UploadProgress>.from(state);
    newState.remove(fileId);
    state = newState;
  }

  void clearAll() {
    state = {};
  }
}

// Project screenshots organized by language and device
@riverpod
class ProjectScreenshots extends _$ProjectScreenshots {
  @override
  Future<Map<String, Map<String, List<ScreenshotModel>>>> build(String projectId) async {
    final projectsStream = ref.watch(projectsStreamProvider);
    return projectsStream.when(
      data: (projects) {
        final project = projects.where((p) => p.id == projectId).firstOrNull;
        return project?.screenshots ?? {};
      },
      loading: () => {},
      error: (_, __) => {},
    );
  }

  Future<void> addScreenshot(ScreenshotModel screenshot) async {
    final currentState = await future;
    final languageCode = screenshot.languageCode;
    final deviceId = screenshot.deviceId;
    
    final updatedState = Map<String, Map<String, List<ScreenshotModel>>>.from(currentState);
    
    if (!updatedState.containsKey(languageCode)) {
      updatedState[languageCode] = {};
    }
    
    if (!updatedState[languageCode]!.containsKey(deviceId)) {
      updatedState[languageCode]![deviceId] = [];
    }
    
    updatedState[languageCode]![deviceId]!.add(screenshot);
    
    state = AsyncValue.data(updatedState);
    
    // Invalidate the projects stream to refresh the project data
    ref.invalidate(projectsStreamProvider);
  }

  Future<void> removeScreenshot(String screenshotId, String languageCode, String deviceId) async {
    final currentState = await future;
    final updatedState = Map<String, Map<String, List<ScreenshotModel>>>.from(currentState);
    
    if (updatedState.containsKey(languageCode) && 
        updatedState[languageCode]!.containsKey(deviceId)) {
      updatedState[languageCode]![deviceId]!.removeWhere((s) => s.id == screenshotId);
      
      // Clean up empty containers
      if (updatedState[languageCode]![deviceId]!.isEmpty) {
        updatedState[languageCode]!.remove(deviceId);
      }
      
      if (updatedState[languageCode]!.isEmpty) {
        updatedState.remove(languageCode);
      }
    }
    
    state = AsyncValue.data(updatedState);
    
    // Invalidate the projects stream to refresh the project data
    ref.invalidate(projectsStreamProvider);
  }
}

// Main upload state management
@riverpod
class UploadScreenshots extends _$UploadScreenshots {
  @override
  String build() {
    return 'ready'; // Simple state tracker
  }

  Future<void> uploadFiles({
    required String projectId,
    required List<String> filePaths,
    required String deviceId,
    required String languageCode,
  }) async {
    try {
      state = 'uploading';
      
      // TODO: Implement file upload logic
      // This will be implemented when we create the UploadService
      
      // For now, just simulate upload
      await Future.delayed(const Duration(seconds: 2));
      
      state = 'ready';
    } catch (error) {
      state = 'error';
      rethrow;
    }
  }
}