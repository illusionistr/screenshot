import 'dart:html' as html;
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../shared/models/screenshot_model.dart';

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
    // Validate file type
    if (!_isValidFileType(file.type)) {
      throw Exception('Invalid file type. Only PNG, JPG, and JPEG files are allowed.');
    }

    // Validate file size (10MB limit)
    const maxSize = 10 * 1024 * 1024; // 10MB in bytes
    if (file.size > maxSize) {
      throw Exception('File size too large. Maximum size is 10MB.');
    }

    final screenshotId = const Uuid().v4();
    final fileExtension = _getFileExtension(file.name);
    final filename = '$screenshotId.$fileExtension';
    
    // Create Firebase Storage reference
    final storageRef = _storage.ref().child(
      '$_basePath/$projectId/screenshots/$languageCode/$deviceId/$filename'
    );

    try {
      // Convert file to bytes
      final bytes = await _fileToBytes(file);
      
      // Get image dimensions
      final dimensions = await _getImageDimensions(bytes);

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

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String storagePath) async {
    try {
      await _storage.ref(storagePath).delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Get storage path from URL
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

  /// Validate file type
  bool _isValidFileType(String? mimeType) {
    if (mimeType == null) return false;
    
    const allowedTypes = [
      'image/png',
      'image/jpeg',
      'image/jpg',
    ];
    
    return allowedTypes.contains(mimeType.toLowerCase());
  }

  /// Get file extension from filename
  String _getFileExtension(String filename) {
    final parts = filename.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return 'png'; // Default extension
  }

  /// Convert HTML File to Uint8List
  Future<Uint8List> _fileToBytes(html.File file) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    
    await reader.onLoad.first;
    
    return Uint8List.fromList(reader.result as List<int>);
  }

  /// Get image dimensions from bytes
  Future<Dimensions> _getImageDimensions(Uint8List bytes) async {
    // Create a temporary image element to get dimensions
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrl(blob);
    
    try {
      final image = html.ImageElement();
      image.src = url;
      
      // Wait for image to load
      await image.onLoad.first;
      
      return Dimensions(
        width: image.naturalWidth,
        height: image.naturalHeight,
      );
    } finally {
      html.Url.revokeObjectUrl(url);
    }
  }
}