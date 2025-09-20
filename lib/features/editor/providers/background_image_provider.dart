import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/background_models.dart';
import '../services/background_image_service.dart';

// Upload progress state
class UploadProgress {
  final bool isUploading;
  final double progress;
  final String? fileName;
  final String? error;

  const UploadProgress({
    this.isUploading = false,
    this.progress = 0.0,
    this.fileName,
    this.error,
  });

  UploadProgress copyWith({
    bool? isUploading,
    double? progress,
    String? fileName,
    String? error,
  }) {
    return UploadProgress(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      fileName: fileName ?? this.fileName,
      error: error ?? this.error,
    );
  }
}

// Background image notifier
class BackgroundImageNotifier extends StateNotifier<AsyncValue<List<BackgroundImage>>> {
  final BackgroundImageService _service;
  
  UploadProgress _uploadProgress = const UploadProgress();
  UploadProgress get uploadProgress => _uploadProgress;

  BackgroundImageNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadBackgroundImages();
  }

  void _loadBackgroundImages() {
    _service.getUserBackgroundImages().listen(
      (images) {
        if (mounted) {
          state = AsyncValue.data(images);
        }
      },
      onError: (error) {
        if (mounted) {
          state = AsyncValue.error(error, StackTrace.current);
        }
      },
    );
  }

  Future<BackgroundImage?> uploadBackgroundImage(html.File file) async {
    try {
      // Reset any previous errors
      _updateUploadProgress(const UploadProgress());
      
      // Check if user has reached limit
      final hasReachedLimit = await _service.hasReachedImageLimit();
      if (hasReachedLimit) {
        _updateUploadProgress(const UploadProgress(
          error: 'You have reached the maximum limit of 50 background images',
        ));
        return null;
      }

      // Start upload
      _updateUploadProgress(UploadProgress(
        isUploading: true,
        fileName: file.name,
      ));

      final backgroundImage = await _service.uploadBackgroundImage(
        file: file,
        onProgress: (progress) {
          _updateUploadProgress(_uploadProgress.copyWith(
            progress: progress,
          ));
        },
      );

      // Upload completed successfully
      _updateUploadProgress(const UploadProgress());
      
      return backgroundImage;
    } catch (e) {
      _updateUploadProgress(UploadProgress(
        error: e.toString(),
      ));
      return null;
    }
  }

  Future<void> deleteBackgroundImage(String imageId) async {
    try {
      await _service.deleteBackgroundImage(imageId);
    } catch (e) {
      // Handle error - could show snackbar or update error state
      rethrow;
    }
  }

  BackgroundImage? getImageById(String imageId) {
    return state.whenOrNull(
      data: (images) => _service.getBackgroundImageById(images, imageId),
    );
  }

  void _updateUploadProgress(UploadProgress progress) {
    _uploadProgress = progress;
    // Notify listeners about upload progress change
    // This is a simple approach - in a more complex app you might want a separate provider
  }

  void clearUploadError() {
    if (_uploadProgress.error != null) {
      _updateUploadProgress(_uploadProgress.copyWith(error: null));
    }
  }
}

// Providers
final backgroundImageServiceProvider = Provider<BackgroundImageService>((ref) {
  return BackgroundImageService();
});

final backgroundImageProvider = StateNotifierProvider<BackgroundImageNotifier, AsyncValue<List<BackgroundImage>>>((ref) {
  final service = ref.watch(backgroundImageServiceProvider);
  return BackgroundImageNotifier(service);
});

// Upload progress provider (separate for cleaner state management)
class UploadProgressNotifier extends StateNotifier<UploadProgress> {
  UploadProgressNotifier() : super(const UploadProgress());

  void updateProgress(UploadProgress progress) {
    state = progress;
  }

  void reset() {
    state = const UploadProgress();
  }
}

final uploadProgressProvider = StateNotifierProvider<UploadProgressNotifier, UploadProgress>((ref) {
  return UploadProgressNotifier();
});

// Helper providers for specific use cases
final backgroundImageListProvider = Provider<List<BackgroundImage>>((ref) {
  return ref.watch(backgroundImageProvider).whenOrNull(data: (images) => images) ?? [];
});

final backgroundImageByIdProvider = Provider.family<BackgroundImage?, String>((ref, imageId) {
  final images = ref.watch(backgroundImageListProvider);
  try {
    return images.firstWhere((image) => image.id == imageId);
  } catch (e) {
    return null;
  }
});