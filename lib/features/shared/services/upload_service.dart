import 'dart:html' as html;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/screenshot_model.dart';
import 'file_validation_service.dart';

class UploadService {
  final FirebaseStorage _storage;
  final String _basePath = 'projects';

  UploadService(this._storage);

  /// Upload a file to Firebase Storage
  Future<ScreenshotModel> uploadFile({
    required String projectId,
    required html.File file,
    required String deviceId,
    required String languageCode,
    Function(double)? onProgress,
  }) async {
    // Validate file
    final validation = FileValidationService.validateFile(file);
    if (!validation.isValid) {
      throw Exception(validation.errorMessage);
    }

    final screenshotId = const Uuid().v4();
    final fileExtension = FileValidationService.getFileExtension(file.name);
    final filename = '$screenshotId.$fileExtension';
    
    // Create Firebase Storage reference
    final storageRef = _storage.ref().child(
      '$_basePath/$projectId/screenshots/$languageCode/$deviceId/$filename'
    );

    try {
      // Convert file to bytes
      final bytes = await FileValidationService.fileToBytes(file);
      
      // Get image dimensions
      final dimensions = await FileValidationService.getImageDimensions(bytes);

      // Create upload task
      final uploadTask = storageRef.putData(
        bytes,
        SettableMetadata(
          contentType: file.type,
          customMetadata: {
            'originalFilename': file.name,
            'deviceId': deviceId,
            'languageCode': languageCode,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      // Wait for upload to complete
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Create screenshot model
      return ScreenshotModel(
        id: screenshotId,
        filename: filename,
        originalFilename: file.name,
        storageUrl: downloadUrl,
        deviceId: deviceId,
        languageCode: languageCode,
        uploadedAt: DateTime.now(),
        fileSize: file.size,
        dimensions: dimensions,
        // TODO: Generate thumbnail URL if needed
        thumbnailUrl: null,
      );
    } catch (e) {
      // Clean up failed upload
      try {
        await storageRef.delete();
      } catch (_) {
        // Ignore cleanup errors
      }
      throw Exception('Upload failed: $e');
    }
  }

  /// Delete a file from Firebase Storage using the download URL
  Future<void> deleteFileByUrl(String downloadUrl) async {
    try {
      // Use refFromURL which handles the download URL format automatically
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Delete a file from Firebase Storage using storage path
  Future<void> deleteFile(String storagePath) async {
    try {
      await _storage.ref(storagePath).delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Get storage path from URL (deprecated - use deleteFileByUrl instead)
  String getStoragePathFromUrl(String url) {
    // Extract path from Firebase Storage URL
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;

    // Firebase Storage URLs have format: /v0/b/{bucket}/o/{path}
    // We need to decode the path part
    if (pathSegments.length >= 4 && pathSegments[2] == 'o') {
      return Uri.decodeComponent(pathSegments[3]);
    }

    throw Exception('Invalid Firebase Storage URL');
  }

}