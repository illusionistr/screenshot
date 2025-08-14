import 'dart:typed_data';
import 'package:image/image.dart' as img;

import '../../../core/constants/upload_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/firebase_service.dart';
import '../models/screen_model.dart';

class ScreenshotUploadResult {
  final String originalUrl;
  final String thumbnailUrl;
  final int originalSize;
  final int thumbnailSize;

  const ScreenshotUploadResult({
    required this.originalUrl,
    required this.thumbnailUrl,
    required this.originalSize,
    required this.thumbnailSize,
  });
}

class ScreenshotValidationResult {
  final bool isValid;
  final String? error;
  final String? detectedMimeType;
  final int? fileSize;

  const ScreenshotValidationResult({
    required this.isValid,
    this.error,
    this.detectedMimeType,
    this.fileSize,
  });
}

class ScreenshotManager {
  final StorageService _storageService;
  final FirebaseService _firebaseService;

  ScreenshotManager({
    required StorageService storageService,
    required FirebaseService firebaseService,
  })  : _storageService = storageService,
        _firebaseService = firebaseService;

  /// Validates file before upload
  ScreenshotValidationResult validateFile({
    required Uint8List fileBytes,
    required String fileName,
    String? mimeType,
  }) {
    // Check file size
    if (fileBytes.length > UploadConstants.maxFileSizeBytes) {
      return ScreenshotValidationResult(
        isValid: false,
        error: UploadConstants.errorFileTooLarge,
        fileSize: fileBytes.length,
      );
    }

    // Extract and validate file extension
    final extension = fileName.toLowerCase().split('.').last;
    if (!UploadConstants.allowedExtensions.contains(extension)) {
      return ScreenshotValidationResult(
        isValid: false,
        error: UploadConstants.errorInvalidFormat,
        fileSize: fileBytes.length,
      );
    }

    // Validate MIME type if provided
    if (mimeType != null && !UploadConstants.allowedMimeTypes.contains(mimeType.toLowerCase())) {
      return ScreenshotValidationResult(
        isValid: false,
        error: UploadConstants.errorInvalidFormat,
        detectedMimeType: mimeType,
        fileSize: fileBytes.length,
      );
    }

    // Try to decode image to ensure it's valid
    try {
      final image = img.decodeImage(fileBytes);
      if (image == null) {
        return ScreenshotValidationResult(
          isValid: false,
          error: 'Invalid image file',
          fileSize: fileBytes.length,
        );
      }
    } catch (e) {
      return ScreenshotValidationResult(
        isValid: false,
        error: 'Failed to process image: ${e.toString()}',
        fileSize: fileBytes.length,
      );
    }

    return ScreenshotValidationResult(
      isValid: true,
      detectedMimeType: mimeType,
      fileSize: fileBytes.length,
    );
  }

  /// Creates a compressed thumbnail version of the image
  Future<Uint8List> createThumbnail(Uint8List originalBytes) async {
    try {
      final image = img.decodeImage(originalBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Start with medium quality
      int quality = UploadConstants.jpegQualityMedium;
      Uint8List? compressedBytes;

      // Try different quality levels to get within target size
      while (quality >= UploadConstants.jpegQualityLow) {
        compressedBytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
        
        if (compressedBytes.length <= UploadConstants.thumbnailTargetSizeBytes) {
          break;
        }
        
        quality -= 10;
      }

      // If still too large, try resizing the image
      if (compressedBytes != null && compressedBytes.length > UploadConstants.thumbnailMaxSizeBytes) {
        final scaleFactor = 0.8;
        final newWidth = (image.width * scaleFactor).round();
        final newHeight = (image.height * scaleFactor).round();
        
        final resized = img.copyResize(image, width: newWidth, height: newHeight);
        compressedBytes = Uint8List.fromList(img.encodeJpg(resized, quality: UploadConstants.jpegQualityMedium));
      }

      return compressedBytes ?? Uint8List.fromList(img.encodeJpg(image, quality: UploadConstants.jpegQualityLow));
    } catch (e) {
      throw Exception('${UploadConstants.errorCompressionFailed}: ${e.toString()}');
    }
  }

  /// Uploads screenshot with both original and thumbnail versions
  Future<ScreenshotUploadResult> uploadScreenshot({
    required String projectId,
    required String screenId,
    required String device,
    required Uint8List fileBytes,
    required String fileName,
    String? mimeType,
  }) async {
    try {
      // Validate file first
      final validation = validateFile(
        fileBytes: fileBytes,
        fileName: fileName,
        mimeType: mimeType,
      );

      if (!validation.isValid) {
        throw Exception(validation.error ?? UploadConstants.errorInvalidFormat);
      }

      // Generate file paths
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName.toLowerCase().split('.').last;
      final baseFileName = '${screenId}_${device}_$timestamp';
      
      final originalPath = '${UploadConstants.screenshotsBasePath}/$projectId/${UploadConstants.originalsSubpath}/$baseFileName${UploadConstants.originalSuffix}.$extension';
      final thumbnailPath = '${UploadConstants.screenshotsBasePath}/$projectId/${UploadConstants.thumbnailsSubpath}/$baseFileName${UploadConstants.thumbnailSuffix}.jpg';

      // Create thumbnail
      final thumbnailBytes = await createThumbnail(fileBytes);

      // Upload both versions
      final originalUrl = await _storageService.uploadBytes(
        path: originalPath,
        data: fileBytes,
        contentType: mimeType ?? 'image/$extension',
      );

      final thumbnailUrl = await _storageService.uploadBytes(
        path: thumbnailPath,
        data: thumbnailBytes,
        contentType: 'image/jpeg',
      );

      return ScreenshotUploadResult(
        originalUrl: originalUrl,
        thumbnailUrl: thumbnailUrl,
        originalSize: fileBytes.length,
        thumbnailSize: thumbnailBytes.length,
      );
    } catch (e) {
      throw Exception('${UploadConstants.errorUploadFailed}: ${e.toString()}');
    }
  }

  /// Gets screenshot URL with hierarchical fallback resolution
  /// Priority: device+language specific → device default → global default
  String? getScreenshotUrl({
    required ScreenModel screen,
    required String device,
    String? languageCode,
    bool useThumbnail = true,
  }) {
    final screenshots = screen.screenshots;
    
    if (screenshots.isEmpty) {
      return null;
    }

    // Try device+language specific first (if language provided)
    if (languageCode != null) {
      final deviceLangKey = '${device}_$languageCode';
      if (screenshots.containsKey(deviceLangKey)) {
        return _getUrlVariant(screenshots[deviceLangKey]!, useThumbnail);
      }
    }

    // Try device default
    if (screenshots.containsKey(device)) {
      return _getUrlVariant(screenshots[device]!, useThumbnail);
    }

    // Try global default (first available screenshot)
    final globalDefault = screenshots.values.first;
    return _getUrlVariant(globalDefault, useThumbnail);
  }

  /// Helper to get thumbnail or original URL variant
  String _getUrlVariant(String url, bool useThumbnail) {
    if (!useThumbnail) {
      return url;
    }

    // If it's a thumbnail URL, return as-is
    if (url.contains(UploadConstants.thumbnailsSubpath) && url.contains(UploadConstants.thumbnailSuffix)) {
      return url;
    }

    // Try to convert original URL to thumbnail URL
    if (url.contains(UploadConstants.originalsSubpath) && url.contains(UploadConstants.originalSuffix)) {
      return url
          .replaceAll(UploadConstants.originalsSubpath, UploadConstants.thumbnailsSubpath)
          .replaceAll(UploadConstants.originalSuffix, UploadConstants.thumbnailSuffix)
          .replaceAll(RegExp(r'\.(png|jpg|jpeg)$'), '.jpg');
    }

    // Fallback to original URL
    return url;
  }

  /// Auto-applies screenshot to all devices in the project
  Future<void> autoApplyScreenshot({
    required String screenId,
    required List<String> devices,
    required String uploadedDevice,
    required ScreenshotUploadResult uploadResult,
  }) async {
    try {
      final Map<String, String> newScreenshots = {};

      // Apply to all devices (thumbnail URLs for UI display)
      for (final device in devices) {
        newScreenshots[device] = uploadResult.thumbnailUrl;
      }

      // Update the screen's screenshots map
      await _firebaseService.updateDocument(
        collectionPath: 'screens',
        documentId: screenId,
        data: {
          'screenshots': newScreenshots,
          'updatedAt': DateTime.now(),
        },
      );
    } catch (e) {
      throw Exception('Failed to auto-apply screenshot: ${e.toString()}');
    }
  }

  /// Updates screenshot for specific device/language combination
  Future<void> updateScreenshotForDevice({
    required String screenId,
    required String device,
    required String screenshotUrl,
    String? languageCode,
  }) async {
    try {
      final key = languageCode != null ? '${device}_$languageCode' : device;
      
      await _firebaseService.updateDocument(
        collectionPath: 'screens',
        documentId: screenId,
        data: {
          'screenshots.$key': screenshotUrl,
          'updatedAt': DateTime.now(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update screenshot: ${e.toString()}');
    }
  }
}