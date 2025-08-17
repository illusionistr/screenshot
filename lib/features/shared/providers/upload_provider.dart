import 'dart:html' as html;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../providers/app_providers.dart';
import '../models/screenshot_model.dart';
import '../models/upload_state_model.dart';
import '../services/upload_service.dart';

part 'upload_provider.g.dart';

// Upload progress state manager
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

  List<UploadProgress> get allProgress => state.values.toList();
  
  List<UploadProgress> get activeUploads => 
      state.values.where((p) => p.isInProgress).toList();
  
  List<UploadProgress> get completedUploads => 
      state.values.where((p) => p.isCompleted && !p.hasError).toList();
  
  List<UploadProgress> get failedUploads => 
      state.values.where((p) => p.hasError).toList();
  
  bool get hasActiveUploads => activeUploads.isNotEmpty;
  bool get hasFailedUploads => failedUploads.isNotEmpty;
  
  double get overallProgress {
    if (state.isEmpty) return 0.0;
    
    final totalProgress = state.values.fold<double>(
      0.0, 
      (sum, progress) => sum + progress.progress,
    );
    
    return totalProgress / state.length;
  }
}

// Upload queue manager
@riverpod
class UploadQueueNotifier extends _$UploadQueueNotifier {
  @override
  List<UploadFile> build() {
    return [];
  }

  void addFiles(List<html.File> files, String deviceId, String languageCode) {
    final newFiles = files.map((file) {
      return UploadFile(
        id: const Uuid().v4(),
        file: file,
        deviceId: deviceId,
        languageCode: languageCode,
        addedAt: DateTime.now(),
      );
    }).toList();

    state = [...state, ...newFiles];
  }

  void removeFile(String fileId) {
    state = state.where((file) => file.id != fileId).toList();
  }

  void clearQueue() {
    state = [];
  }

  UploadFile? getFile(String fileId) {
    try {
      return state.firstWhere((file) => file.id == fileId);
    } catch (e) {
      return null;
    }
  }
}

// Main upload coordinator
@riverpod
class UploadCoordinator extends _$UploadCoordinator {
  UploadService get _uploadService => ref.read(uploadServiceProvider);
  
  @override
  AsyncValue<List<UploadResult>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> uploadFiles({
    required String projectId,
    required List<UploadFile> files,
    Function(UploadProgress)? onProgress,
    Function(UploadResult)? onComplete,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final results = <UploadResult>[];
      final progressNotifier = ref.read(uploadProgressNotifierProvider.notifier);

      for (final uploadFile in files) {
        try {
          // Initialize progress
          progressNotifier.updateProgress(
            uploadFile.id,
            UploadProgress(
              fileId: uploadFile.id,
              filename: uploadFile.file.name,
              progress: 0.0,
              fileSize: uploadFile.file.size,
            ),
          );

          // Upload file
          final screenshot = await _uploadService.uploadFile(
            projectId: projectId,
            file: uploadFile.file,
            deviceId: uploadFile.deviceId,
            languageCode: uploadFile.languageCode,
            onProgress: (progress) {
              progressNotifier.updateProgress(
                uploadFile.id,
                UploadProgress(
                  fileId: uploadFile.id,
                  filename: uploadFile.file.name,
                  progress: progress,
                  fileSize: uploadFile.file.size,
                ),
              );
              onProgress?.call(UploadProgress(
                fileId: uploadFile.id,
                filename: uploadFile.file.name,
                progress: progress,
                fileSize: uploadFile.file.size,
              ));
            },
          );

          // Mark as completed
          final successProgress = UploadProgress(
            fileId: uploadFile.id,
            filename: uploadFile.file.name,
            progress: 1.0,
            isCompleted: true,
            fileSize: uploadFile.file.size,
          );
          
          progressNotifier.updateProgress(uploadFile.id, successProgress);

          final result = UploadResult(
            fileId: uploadFile.id,
            screenshot: screenshot,
            completedAt: DateTime.now(),
          );
          
          results.add(result);
          onComplete?.call(result);

        } catch (e) {
          // Mark as failed
          final errorProgress = UploadProgress(
            fileId: uploadFile.id,
            filename: uploadFile.file.name,
            progress: 0.0,
            isCompleted: true,
            errorMessage: e.toString(),
            fileSize: uploadFile.file.size,
          );
          
          progressNotifier.updateProgress(uploadFile.id, errorProgress);

          final result = UploadResult(
            fileId: uploadFile.id,
            errorMessage: e.toString(),
            completedAt: DateTime.now(),
          );
          
          results.add(result);
          onComplete?.call(result);
        }
      }

      state = AsyncValue.data(results);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> uploadSingleFile({
    required String projectId,
    required html.File file,
    required String deviceId,
    required String languageCode,
    Function(UploadProgress)? onProgress,
    Function(UploadResult)? onComplete,
  }) async {
    final uploadFile = UploadFile(
      id: const Uuid().v4(),
      file: file,
      deviceId: deviceId,
      languageCode: languageCode,
      addedAt: DateTime.now(),
    );

    await uploadFiles(
      projectId: projectId,
      files: [uploadFile],
      onProgress: onProgress,
      onComplete: onComplete,
    );
  }

  void clearResults() {
    state = const AsyncValue.data([]);
  }
}