import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageUploadResult {
  final String downloadUrl;
  final String fullPath;
  final int size;
  final String? contentType;

  const StorageUploadResult({
    required this.downloadUrl,
    required this.fullPath,
    required this.size,
    this.contentType,
  });
}

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload bytes and return download URL (backward compatibility)
  Future<String> uploadBytes({
    required String path,
    required Uint8List data,
    String contentType = 'application/octet-stream',
  }) async {
    final ref = _storage.ref().child(path);
    final task = await ref.putData(
      data,
      SettableMetadata(contentType: contentType),
    );
    return task.ref.getDownloadURL();
  }

  /// Enhanced upload with detailed result
  Future<StorageUploadResult> uploadBytesDetailed({
    required String path,
    required Uint8List data,
    String contentType = 'application/octet-stream',
    Map<String, String>? customMetadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: customMetadata,
      );
      
      final task = await ref.putData(data, metadata);
      final downloadUrl = await task.ref.getDownloadURL();
      
      return StorageUploadResult(
        downloadUrl: downloadUrl,
        fullPath: task.ref.fullPath,
        size: data.length,
        contentType: contentType,
      );
    } on FirebaseException catch (e) {
      throw Exception('Storage upload failed: ${e.message}');
    }
  }

  /// Upload multiple files concurrently
  Future<List<StorageUploadResult>> uploadMultiple({
    required List<UploadTask> tasks,
  }) async {
    try {
      final futures = tasks.map((task) async {
        final result = await task;
        final downloadUrl = await result.ref.getDownloadURL();
        
        return StorageUploadResult(
          downloadUrl: downloadUrl,
          fullPath: result.ref.fullPath,
          size: result.totalBytes,
          contentType: result.metadata?.contentType,
        );
      });

      return await Future.wait(futures);
    } on FirebaseException catch (e) {
      throw Exception('Batch upload failed: ${e.message}');
    }
  }

  /// Create upload task for batch operations
  UploadTask createUploadTask({
    required String path,
    required Uint8List data,
    String contentType = 'application/octet-stream',
    Map<String, String>? customMetadata,
  }) {
    final ref = _storage.ref().child(path);
    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: customMetadata,
    );
    
    return ref.putData(data, metadata);
  }

  /// Delete file from storage
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        throw Exception('Failed to delete file: ${e.message}');
      }
      // Ignore if file doesn't exist
    }
  }

  /// Get file metadata
  Future<FullMetadata?> getFileMetadata(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getMetadata();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return null;
      }
      throw Exception('Failed to get file metadata: ${e.message}');
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String path) async {
    final metadata = await getFileMetadata(path);
    return metadata != null;
  }

  /// Get download URL for existing file
  Future<String?> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return null;
      }
      throw Exception('Failed to get download URL: ${e.message}');
    }
  }
}


