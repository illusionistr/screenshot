import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/background_models.dart';

class BackgroundImageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _backgroundImagesCollection = 'background_images';
  static const String _storageFolder = 'background_images';
  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> _allowedExtensions = ['png', 'jpg', 'jpeg', 'webp'];

  Stream<List<BackgroundImage>> getUserBackgroundImages() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_backgroundImagesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BackgroundImage.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  Future<List<BackgroundImage>> getUserBackgroundImagesList() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection(_backgroundImagesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('uploadedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => BackgroundImage.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  }

  Future<BackgroundImage?> uploadBackgroundImage({
    required html.File file,
    Function(double progress)? onProgress,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Validate file
    _validateFile(file);

    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _getFileExtension(file.name);
      final filename = 'background_$timestamp.$extension';
      final storagePath = '$_storageFolder/$userId/$filename';

      // Upload to Firebase Storage
      final storageRef = _storage.ref().child(storagePath);
      final uploadTask = storageRef.putBlob(file);

      // Track progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload completion
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Create background image record
      final backgroundImage = BackgroundImage(
        id: '', // Will be set by Firestore
        url: downloadUrl,
        filename: file.name,
        uploadedAt: DateTime.now(),
        fileSize: file.size,
        userId: userId,
      );

      // Save to Firestore
      final docRef = await _firestore
          .collection(_backgroundImagesCollection)
          .add(backgroundImage.toJson());

      return backgroundImage.copyWith(id: docRef.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBackgroundImage(String imageId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Get image data
      final doc = await _firestore
          .collection(_backgroundImagesCollection)
          .doc(imageId)
          .get();

      if (!doc.exists) {
        throw Exception('Background image not found');
      }

      final imageData = doc.data()!;
      if (imageData['userId'] != userId) {
        throw Exception('Unauthorized to delete this image');
      }

      // Delete from Storage
      final url = imageData['url'] as String;
      final storageRef = _storage.refFromURL(url);
      await storageRef.delete();

      // Delete from Firestore
      await doc.reference.delete();
    } catch (e) {
      rethrow;
    }
  }

  BackgroundImage? getBackgroundImageById(List<BackgroundImage> images, String imageId) {
    try {
      return images.firstWhere((image) => image.id == imageId);
    } catch (e) {
      return null;
    }
  }

  void _validateFile(html.File file) {
    // Check file size
    if (file.size > _maxFileSize) {
      throw Exception('File size exceeds 10MB limit');
    }

    // Check file extension
    final extension = _getFileExtension(file.name).toLowerCase();
    if (!_allowedExtensions.contains(extension)) {
      throw Exception('Only PNG, JPG, JPEG, and WebP files are allowed');
    }
  }

  String _getFileExtension(String filename) {
    final parts = filename.split('.');
    if (parts.length < 2) {
      throw Exception('File must have an extension');
    }
    return parts.last.toLowerCase();
  }

  // Utility methods for file size formatting
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  // Check if user has reached background image limit
  Future<bool> hasReachedImageLimit() async {
    final images = await getUserBackgroundImagesList();
    return images.length >= 50; // Limit to 50 background images per user
  }
}