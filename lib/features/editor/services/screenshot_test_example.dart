// Example usage of the ScreenshotManager service
// This file demonstrates how to use the screenshot upload and management system

import 'dart:typed_data';
import '../../../config/dependency_injection.dart';
import 'screenshot_manager.dart';
import '../models/screen_model.dart';
import '../models/screen_settings.dart';

/// Example class showing how to use ScreenshotManager
class ScreenshotTestExample {
  final ScreenshotManager _screenshotManager = serviceLocator<ScreenshotManager>();

  /// Example: Validate and upload a screenshot file
  Future<void> exampleUploadScreenshot({
    required Uint8List fileBytes,
    required String fileName,
    required String projectId,
    required String screenId,
    required String device,
  }) async {
    try {
      // Step 1: Validate the file
      final validation = _screenshotManager.validateFile(
        fileBytes: fileBytes,
        fileName: fileName,
        mimeType: 'image/png',
      );

      if (!validation.isValid) {
        print('Validation failed: ${validation.error}');
        return;
      }

      print('File validated successfully: ${validation.fileSize} bytes');

      // Step 2: Upload with dual storage strategy
      final result = await _screenshotManager.uploadScreenshot(
        projectId: projectId,
        screenId: screenId,
        device: device,
        fileBytes: fileBytes,
        fileName: fileName,
        mimeType: 'image/png',
      );

      print('Upload successful!');
      print('Original URL: ${result.originalUrl}');
      print('Thumbnail URL: ${result.thumbnailUrl}');
      print('Original size: ${result.originalSize} bytes');
      print('Thumbnail size: ${result.thumbnailSize} bytes');

      // Step 3: Auto-apply to all devices
      await _screenshotManager.autoApplyScreenshot(
        screenId: screenId,
        devices: ['Galaxy S8', 'Pixel 3', 'iPhone 14 Pro'],
        uploadedDevice: device,
        uploadResult: result,
      );

      print('Screenshot auto-applied to all devices');
    } catch (e) {
      print('Upload failed: $e');
    }
  }

  /// Example: Retrieve screenshot with hierarchical fallback
  void exampleGetScreenshot() {
    // Create a mock screen model for testing
    final mockScreen = ScreenModel(
      id: 'screen1',
      projectId: 'project1',
      userId: 'user1',
      order: 0,
      screenshots: {
        'Galaxy S8': 'https://storage.googleapis.com/screenshots/thumbnails/galaxy_s8_thumb.jpg',
        'Pixel 3_en_US': 'https://storage.googleapis.com/screenshots/thumbnails/pixel_3_en_us_thumb.jpg',
        'iPhone 14 Pro': 'https://storage.googleapis.com/screenshots/thumbnails/iphone_14_pro_thumb.jpg',
      },
      annotations: {'en_US': 'Welcome screen'},
      settings: ScreenSettings.fromMap(const {}),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Test hierarchical resolution
    print('\n--- Hierarchical Screenshot Resolution Test ---');
    
    // Case 1: Device + Language specific (highest priority)
    var url = _screenshotManager.getScreenshotUrl(
      screen: mockScreen,
      device: 'Pixel 3',
      languageCode: 'en_US',
      useThumbnail: true,
    );
    print('Pixel 3 + en_US: $url');

    // Case 2: Device default (fallback)
    url = _screenshotManager.getScreenshotUrl(
      screen: mockScreen,
      device: 'Galaxy S8',
      languageCode: 'fr_FR', // Not available, should fallback to device default
      useThumbnail: true,
    );
    print('Galaxy S8 + fr_FR (fallback to device): $url');

    // Case 3: Global default (fallback)
    url = _screenshotManager.getScreenshotUrl(
      screen: mockScreen,
      device: 'OnePlus 6', // Not available, should use global default
      languageCode: 'de_DE',
      useThumbnail: true,
    );
    print('OnePlus 6 + de_DE (fallback to global): $url');
  }

  /// Example: File validation
  void exampleFileValidation() {
    print('\n--- File Validation Examples ---');

    // Mock file data
    final validPngBytes = Uint8List.fromList([137, 80, 78, 71]); // PNG header
    final tooLargeBytes = Uint8List(2 * 1024 * 1024); // 2MB

    // Test valid file
    var validation = _screenshotManager.validateFile(
      fileBytes: validPngBytes,
      fileName: 'screenshot.png',
      mimeType: 'image/png',
    );
    print('Valid PNG: ${validation.isValid}');

    // Test file too large
    validation = _screenshotManager.validateFile(
      fileBytes: tooLargeBytes,
      fileName: 'large.png',
      mimeType: 'image/png',
    );
    print('Too large file: ${validation.isValid}, Error: ${validation.error}');

    // Test invalid extension
    validation = _screenshotManager.validateFile(
      fileBytes: validPngBytes,
      fileName: 'screenshot.gif',
      mimeType: 'image/gif',
    );
    print('Invalid extension: ${validation.isValid}, Error: ${validation.error}');
  }
}