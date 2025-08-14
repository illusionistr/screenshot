
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

  /// Test storage connectivity
  Future<bool> testStorageConnection() async {
    try {
      if (kDebugMode) {
        print('🔍 Testing Firebase Storage connection...');
        print('📁 Storage bucket: ${_storage.bucket}');
      }
      
      // Try to get the root reference
      final ref = _storage.ref();
      await ref.listAll();
      
      if (kDebugMode) {
        print('✅ Firebase Storage connection successful');
      }
      return true;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Storage connection failed: ${e.code} - ${e.message}');
        _logStorageError('Connection Test', e);
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Storage connection error: $e');
      }
      return false;
    }
  }

  /// Log detailed storage errors for debugging
  void _logStorageError(String operation, FirebaseException e) {
    if (kDebugMode) {
      print('🚨 Firebase Storage Error - $operation:');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');
      print('   Plugin: ${e.plugin}');
      
      // Common error codes and solutions
      switch (e.code) {
        case 'storage/unknown':
          print('💡 Solution: Firebase Storage may not be initialized. Enable it in Firebase Console.');
          break;
        case 'storage/unauthorized':
          print('💡 Solution: Check storage rules or user authentication.');
          break;
        case 'storage/quota-exceeded':
          print('💡 Solution: Storage quota exceeded. Upgrade Firebase plan.');
          break;
        case 'storage/invalid-argument':
          print('💡 Solution: Check file path and metadata.');
          break;
        default:
          print('💡 Check Firebase Console and storage rules.');
      }
    }
  }

  /// Upload bytes and return download URL (backward compatibility)
  Future<String> uploadBytes({
    required String path,
    required Uint8List data,
    String contentType = 'application/octet-stream',
  }) async {
    try {
      if (kDebugMode) {
        print('📤 Starting upload to: $path');
        print('   Size: ${data.length} bytes');
        print('   Content-Type: $contentType');
        final currentUser = FirebaseAuth.instance.currentUser;
        print('   🔐 Auth Status: ${currentUser != null ? "AUTHENTICATED" : "NOT AUTHENTICATED"}');
        if (currentUser != null) {
          print('   👤 User ID: ${currentUser.uid}');
          print('   📧 Email: ${currentUser.email ?? "No email"}');
        } else {
          print('   ❌ No authenticated user found!');
          print('   💡 This will cause unauthorized errors with secure rules');
        }
      }
      
      final ref = _storage.ref().child(path);
      final task = await ref.putData(
        data,
        SettableMetadata(contentType: contentType),
      );
      
      final downloadUrl = await task.ref.getDownloadURL();
      
      if (kDebugMode) {
        print('✅ Upload successful: ${task.ref.fullPath}');
        print('   Download URL: $downloadUrl');
      }
      
      return downloadUrl;
    } on FirebaseException catch (e) {
      _logStorageError('Upload', e);
      rethrow;
    }
  }

  /// Enhanced upload with detailed result
  Future<StorageUploadResult> uploadBytesDetailed({
    required String path,
    required Uint8List data,
    String contentType = 'application/octet-stream',
    Map<String, String>? customMetadata,
  }) async {
    try {
      if (kDebugMode) {
        print('📤 Detailed upload to: $path');
        print('   Size: ${data.length} bytes');
        print('   Content-Type: $contentType');
        if (customMetadata != null) {
          print('   Metadata: $customMetadata');
        }
      }
      
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: customMetadata,
      );
      
      final task = await ref.putData(data, metadata);
      final downloadUrl = await task.ref.getDownloadURL();
      
      if (kDebugMode) {
        print('✅ Detailed upload successful: ${task.ref.fullPath}');
      }
      
      return StorageUploadResult(
        downloadUrl: downloadUrl,
        fullPath: task.ref.fullPath,
        size: data.length,
        contentType: contentType,
      );
    } on FirebaseException catch (e) {
      _logStorageError('Detailed Upload', e);
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


