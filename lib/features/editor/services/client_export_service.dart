import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../projects/models/project_model.dart';
import '../../shared/data/devices_data.dart';
import '../../shared/models/device_model.dart';
import '../../shared/models/screenshot_model.dart';
import '../../shared/services/device_service.dart';
import '../constants/layouts_data.dart';
import '../constants/platform_dimensions.dart';
import '../models/background_models.dart';
import '../models/editor_state.dart';
import '../models/export_models.dart';
import '../models/text_models.dart';
import '../utils/layout_renderer.dart';

class ClientExportService {
  ClientExportService._();

  /// Main export method that exports all screens in the current editor state
  static Future<ExportResult> exportAllScreens({
    required EditorState editorState,
    required ProjectModel project,
    Function(ExportProgress)? onProgress,
  }) async {
    final startTime = DateTime.now();
    final config = ExportConfiguration(
      projectName: project.appName,
      deviceId: editorState.selectedDevice,
      languageCode: editorState.selectedLanguage,
      screenIds: editorState.screens.map((s) => s.id).toList(),
    );

    // Get exportable screens (screens with valid screenshots)
    final exportableScreens = getExportableScreens(editorState, project);

    if (exportableScreens.isEmpty) {
      return ExportResult(
        exportedFiles: [],
        skippedScreens: editorState.screens.map((s) => s.id).toList(),
        errors: [
          'No screens with valid screenshots found for ${config.languageCode} + ${config.deviceId}'
        ],
        finalStatus: ExportStatus.failed,
        startedAt: startTime,
        completedAt: DateTime.now(),
        projectName: config.projectName,
        deviceId: config.deviceId,
        languageCode: config.languageCode,
      );
    }

    // Initialize progress tracking
    onProgress?.call(ExportProgress(
      currentScreen: 0,
      totalScreens: exportableScreens.length,
      currentScreenId: '',
      currentScreenName: 'Initializing export...',
      status: ExportStatus.validating,
    ));

    final List<ExportedFile> exportedFiles = [];
    final List<String> skippedScreens = [];
    final List<String> errors = [];

    try {
      for (int i = 0; i < exportableScreens.length; i++) {
        final screenData = exportableScreens[i];
        final screenConfig = screenData['screen'] as ScreenConfig;
        final screenshot = screenData['screenshot'] as ScreenshotModel;

        // Update progress
        onProgress?.call(ExportProgress(
          currentScreen: i,
          totalScreens: exportableScreens.length,
          currentScreenId: screenConfig.id,
          currentScreenName: 'Screen ${i + 1}',
          status: ExportStatus.processing,
        ));

        try {
          // Get export dimensions for the device
          final exportSize = getExportDimensions(
              config.deviceId, false); // Always portrait for now

          // Export the individual screen
          final imageData = await exportSingleScreen(
            screenConfig: screenConfig,
            screenshot: screenshot,
            exportSize: exportSize,
            deviceId: config.deviceId,
            editorState: editorState,
          );

          // Create exported file
          final filename = config.generateFilename(i, screenConfig.id);
          final exportedFile = ExportedFile(
            filename: filename,
            data: imageData,
            screenId: screenConfig.id,
            screenName: 'Screen ${i + 1}',
            exportedAt: DateTime.now(),
            fileSizeBytes: imageData.length,
          );

          exportedFiles.add(exportedFile);

          // Trigger download immediately for this file
          await _downloadFile(exportedFile);

          // Small delay to prevent browser blocking
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          errors.add('Failed to export screen ${i + 1}: $e');
          skippedScreens.add(screenConfig.id);
        }
      }

      // Final progress update
      onProgress?.call(ExportProgress(
        currentScreen: exportableScreens.length,
        totalScreens: exportableScreens.length,
        currentScreenId: '',
        currentScreenName: 'Export completed',
        status: errors.isEmpty ? ExportStatus.completed : ExportStatus.failed,
      ));

      return ExportResult(
        exportedFiles: exportedFiles,
        skippedScreens: skippedScreens,
        errors: errors,
        finalStatus:
            errors.isEmpty ? ExportStatus.completed : ExportStatus.failed,
        startedAt: startTime,
        completedAt: DateTime.now(),
        projectName: config.projectName,
        deviceId: config.deviceId,
        languageCode: config.languageCode,
      );
    } catch (e) {
      return ExportResult(
        exportedFiles: exportedFiles,
        skippedScreens: editorState.screens.map((s) => s.id).toList(),
        errors: ['Export failed: $e'],
        finalStatus: ExportStatus.failed,
        startedAt: startTime,
        completedAt: DateTime.now(),
        projectName: config.projectName,
        deviceId: config.deviceId,
        languageCode: config.languageCode,
      );
    }
  }

  /// Export a single screen to PNG format at high resolution
  static Future<Uint8List> exportSingleScreen({
    required ScreenConfig screenConfig,
    required ScreenshotModel screenshot,
    required Size exportSize,
    required String deviceId,
    required EditorState editorState,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder, Rect.fromLTWH(0, 0, exportSize.width, exportSize.height));

    // Set high quality rendering - paint not used directly but ensures canvas quality
    Paint()
      ..filterQuality = ui.FilterQuality.high
      ..isAntiAlias = true;

    // 1. Draw background
    await _drawBackground(canvas, screenConfig.background, exportSize);

    // 2. Draw device frame with screenshot using layout-aware positioning
    await _drawLayoutAwareDeviceFrame(
        canvas, screenshot, deviceId, exportSize, screenConfig, editorState);

    // 3. Draw text overlays using layout-aware positioning
    await _drawLayoutAwareTextOverlays(
        canvas, screenConfig.textConfig, exportSize, screenConfig, editorState);

    // Convert to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(
        exportSize.width.toInt(), exportSize.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    picture.dispose();
    img.dispose();

    return byteData!.buffer.asUint8List();
  }

  /// Get all screens that can be exported (have valid screenshots)
  static List<Map<String, dynamic>> getExportableScreens(
      EditorState editorState, ProjectModel project) {
    final exportableScreens = <Map<String, dynamic>>[];

    for (final screen in editorState.screens) {
      if (screen.assignedScreenshotId != null) {
        // Find the actual screenshot in the project
        final screenshots = project.getScreenshotsForDevice(
            editorState.selectedDevice, editorState.selectedLanguage);

        ScreenshotModel? screenshot;
        try {
          screenshot = screenshots.firstWhere(
            (s) => s.id == screen.assignedScreenshotId,
          );
        } catch (e) {
          screenshot = null;
        }

        if (screenshot != null) {
          exportableScreens.add({
            'screen': screen,
            'screenshot': screenshot,
          });
        }
      }
    }

    return exportableScreens;
  }

  /// Get export dimensions based on device and orientation
  static Size getExportDimensions(String deviceId, bool isLandscape) {
    final device = DevicesData.getDeviceById(deviceId);
    if (device == null) {
      // Default to iPhone dimensions
      return const Size(1290, 2796);
    }

    final dimensions = PlatformDimensions.getDimensionsForDevice(device,
        isLandscape: isLandscape);
    return Size(dimensions.width.toDouble(), dimensions.height.toDouble());
  }

  /// Download a file using browser download API
  static Future<void> _downloadFile(ExportedFile file) async {
    final blob = html.Blob([file.data]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute('download', file.filename)
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  /// Draw background on canvas at export resolution
  static Future<void> _drawBackground(
      Canvas canvas, ScreenBackground background, Size size) async {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    switch (background.type) {
      case BackgroundType.solid:
        final paint = Paint()
          ..color = background.solidColor ?? Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawRect(rect, paint);
        break;

      case BackgroundType.gradient:
        if (background.gradient != null) {
          final paint = Paint()
            ..shader = background.gradient!.createShader(rect)
            ..style = PaintingStyle.fill;
          canvas.drawRect(rect, paint);
        } else {
          final paint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
          canvas.drawRect(rect, paint);
        }
        break;

      case BackgroundType.image:
        if (background.imageUrl != null) {
          try {
            // Load background image and draw it
            // For now, fall back to solid color as image loading is complex in this context
            final paint = Paint()
              ..color = Colors.grey.shade300
              ..style = PaintingStyle.fill;
            canvas.drawRect(rect, paint);
          } catch (e) {
            // Fallback to white background
            final paint = Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill;
            canvas.drawRect(rect, paint);
          }
        } else {
          final paint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
          canvas.drawRect(rect, paint);
        }
        break;
    }
  }

  /// Draw device frame with screenshot positioned correctly based on device specifications
  static Future<void> _drawDeviceFrameWithScreenshot(Canvas canvas,
      ScreenshotModel screenshot, String deviceId, Size exportSize) async {
    final device = DeviceService.getDeviceById(deviceId);
    final frameVariant = await DeviceService.getDefaultFrameVariant(deviceId);

    if (device == null) {
      await _drawGenericFrameWithScreenshot(canvas, screenshot, exportSize);
      return;
    }

    // Try to use real device frame if available
    if (frameVariant != null &&
        !frameVariant.isGeneric &&
        frameVariant.assetPath != null) {
      await _drawRealDeviceFrame(
          canvas, screenshot, device, frameVariant.assetPath!, exportSize);
    } else {
      // Fallback to generic frame that matches FrameRenderer.renderGenericFrame
      await _drawGenericFrameWithScreenshot(canvas, screenshot, exportSize);
    }
  }

  /// Draw real device frame using PNG asset with proper screenshot positioning
  static Future<void> _drawRealDeviceFrame(
      Canvas canvas,
      ScreenshotModel screenshot,
      DeviceModel device,
      String assetPath,
      Size exportSize) async {
    try {
      // Load device frame asset
      final frameImage = await _loadImageFromAsset(assetPath);
      print('Frame image: $frameImage');
      if (frameImage != null) {
        // Calculate scaling factor to fit frame to export size
        final frameAspectRatio = frameImage.width / frameImage.height;
        final exportAspectRatio = exportSize.width / exportSize.height;

        double scaledFrameWidth, scaledFrameHeight;
        double frameOffsetX = 0, frameOffsetY = 0;

        if (frameAspectRatio > exportAspectRatio) {
          // Frame is wider, fit to width
          scaledFrameWidth = exportSize.width;
          scaledFrameHeight = exportSize.width / frameAspectRatio;
          frameOffsetY = (exportSize.height - scaledFrameHeight) / 2;
        } else {
          // Frame is taller, fit to height
          scaledFrameHeight = exportSize.height;
          scaledFrameWidth = exportSize.height * frameAspectRatio;
          frameOffsetX = (exportSize.width - scaledFrameWidth) / 2;
        }

        // Calculate scale factor for positioning
        final scaleFactorX = scaledFrameWidth / device.frameWidth;
        final scaleFactorY = scaledFrameHeight / device.frameHeight;

        // Draw the device frame
        final frameRect = Rect.fromLTWH(
            frameOffsetX, frameOffsetY, scaledFrameWidth, scaledFrameHeight);
        final frameSrcRect = Rect.fromLTWH(
            0, 0, frameImage.width.toDouble(), frameImage.height.toDouble());
        canvas.drawImageRect(frameImage, frameSrcRect, frameRect,
            Paint()..filterQuality = ui.FilterQuality.high);

        // Now draw the screenshot in the correct position
        final screenshotImage =
            await _loadImageFromNetwork(screenshot.storageUrl);
        if (screenshotImage != null) {
          // Calculate screenshot position based on device screen area
          final screenLeft =
              frameOffsetX + (device.screenPosition.dx * scaleFactorX);
          final screenTop =
              frameOffsetY + (device.screenPosition.dy * scaleFactorY);
          final screenWidth = device.screenWidth * scaleFactorX;
          final screenHeight = device.screenHeight * scaleFactorY;

          final screenRect =
              Rect.fromLTWH(screenLeft, screenTop, screenWidth, screenHeight);
          final screenshotSrcRect = Rect.fromLTWH(
              0,
              0,
              screenshotImage.width.toDouble(),
              screenshotImage.height.toDouble());

          // Clip to screen area with rounded corners
          canvas.save();
          canvas.clipRRect(
              RRect.fromRectAndRadius(screenRect, const Radius.circular(8.0)));
          canvas.drawImageRect(screenshotImage, screenshotSrcRect, screenRect,
              Paint()..filterQuality = ui.FilterQuality.high);
          canvas.restore();
        }

        return;
      }
    } catch (e) {
      print('Failed to load device frame asset: $e');
    }

    // Fallback to generic frame if asset loading fails
    await _drawGenericFrameWithScreenshot(canvas, screenshot, exportSize);
  }

  /// Draw generic frame that matches the FrameRenderer.renderGenericFrame design
  static Future<void> _drawGenericFrameWithScreenshot(
      Canvas canvas, ScreenshotModel screenshot, Size exportSize) async {
    // Generic frame uses 50% width and 60% height with centered positioning
    // This matches FrameRenderer.renderGenericFrame exactly
    final frameWidth = exportSize.width * 0.5;
    final frameHeight = exportSize.height * 0.6;
    final frameLeft = (exportSize.width - frameWidth) / 2;
    final frameTop = exportSize.height *
        0.15; // 15% from top for title space + 60% frame + remainder for balance

    // Draw frame background
    const borderRadius = 20.0;
    const borderWidth = 2.0;
    final frameRect =
        Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight);

    // Draw shadow first
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          frameRect.translate(0, 2), const Radius.circular(borderRadius)),
      shadowPaint,
    );

    // Draw white background
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(borderRadius)),
      backgroundPaint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(borderRadius)),
      borderPaint,
    );

    // Content area (inside border)
    const innerRadius = 18.0; // Slightly smaller radius for content
    final contentLeft = frameLeft + borderWidth;
    final contentTop = frameTop + borderWidth;
    final contentWidth = frameWidth - (borderWidth * 2);
    final contentHeight = frameHeight - (borderWidth * 2);
    final contentRect =
        Rect.fromLTWH(contentLeft, contentTop, contentWidth, contentHeight);

    // Draw screenshot inside content area
    try {
      final screenshotImage =
          await _loadImageFromNetwork(screenshot.storageUrl);
      if (screenshotImage != null) {
        canvas.save();
        canvas.clipRRect(RRect.fromRectAndRadius(
            contentRect, const Radius.circular(innerRadius)));

        // Scale screenshot to fit content area while maintaining aspect ratio
        final imageWidth = screenshotImage.width.toDouble();
        final imageHeight = screenshotImage.height.toDouble();
        final contentAspectRatio = contentWidth / contentHeight;
        final imageAspectRatio = imageWidth / imageHeight;

        double drawWidth, drawHeight;
        double drawX, drawY;

        if (imageAspectRatio > contentAspectRatio) {
          // Image is wider, fit to width
          drawWidth = contentWidth;
          drawHeight = contentWidth / imageAspectRatio;
          drawX = contentLeft;
          drawY = contentTop + (contentHeight - drawHeight) / 2;
        } else {
          // Image is taller, fit to height
          drawHeight = contentHeight;
          drawWidth = contentHeight * imageAspectRatio;
          drawX = contentLeft + (contentWidth - drawWidth) / 2;
          drawY = contentTop;
        }

        final srcRect = Rect.fromLTWH(0, 0, imageWidth, imageHeight);
        final dstRect = Rect.fromLTWH(drawX, drawY, drawWidth, drawHeight);

        canvas.drawImageRect(screenshotImage, srcRect, dstRect,
            Paint()..filterQuality = ui.FilterQuality.high);
        canvas.restore();
        return;
      }
    } catch (e) {
      print('Failed to load screenshot for export: $e');
    }

    // Fallback: Draw placeholder when screenshot fails to load
    final placeholderPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(contentRect, const Radius.circular(innerRadius)),
      placeholderPaint,
    );

    // Draw placeholder text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Screenshot',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        contentLeft + (contentWidth - textPainter.width) / 2,
        contentTop + (contentHeight - textPainter.height) / 2,
      ),
    );
    textPainter.dispose();
  }

  /// Draw text overlays at export resolution
  static Future<void> _drawTextOverlays(
      Canvas canvas, ScreenTextConfig textConfig, Size exportSize) async {
    for (final element in textConfig.visibleElements) {
      final position = _getTextPosition(element.type, exportSize);

      // Scale font size for export resolution (assuming preview is ~800px height, export is ~2796px)
      final scaleFactor = exportSize.height / 800;
      final exportFontSize = element.fontSize * scaleFactor;

      final textPainter = TextPainter(
        text: TextSpan(
          text: element.content,
          style: TextStyle(
            fontFamily: element.fontFamily,
            fontSize: exportFontSize.clamp(
                16.0, 200.0), // Reasonable bounds for export
            fontWeight: element.fontWeight,
            color: element.color,
            height: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: element.textAlign,
        maxLines: element.type == TextFieldType.title ? 3 : 2,
      );

      textPainter.layout(maxWidth: position.width);

      // Calculate position based on text alignment
      double textX = position.left;
      if (element.textAlign == TextAlign.center) {
        textX = position.left + (position.width - textPainter.width) / 2;
      } else if (element.textAlign == TextAlign.right) {
        textX = position.left + position.width - textPainter.width;
      }

      textPainter.paint(canvas, Offset(textX, position.top));
      textPainter.dispose();
    }
  }

  /// Load image from Flutter asset bundle
  static Future<ui.Image?> _loadImageFromAsset(String assetPath) async {
    try {
      // Load asset as byte data
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      // Decode image
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      codec.dispose();

      return frame.image;
    } catch (e) {
      print('Error loading asset image: $e');
      return null;
    }
  }

  /// Get text position for export resolution
  static Rect _getTextPosition(TextFieldType type, Size exportSize) {
    const padding = 32.0; // Double the preview padding for high-res

    switch (type) {
      case TextFieldType.title:
        return Rect.fromLTWH(
          padding,
          exportSize.height * 0.05, // 5% from top
          exportSize.width - (padding * 2),
          exportSize.height * 0.15, // 15% height for title area
        );
      case TextFieldType.subtitle:
        return Rect.fromLTWH(
          padding,
          exportSize.height * 0.80, // 80% from top
          exportSize.width - (padding * 2),
          exportSize.height * 0.15, // 15% height for subtitle area
        );
    }
  }

  /// Load image from network URL for canvas drawing
  static Future<ui.Image?> _loadImageFromNetwork(String url) async {
    try {
      final request = await html.HttpRequest.request(
        url,
        responseType: 'blob',
        method: 'GET',
      );

      if (request.status == 200) {
        final blob = request.response as html.Blob;
        final reader = html.FileReader();

        // Use a completer to wait for file reading to complete
        final completer = Completer<Uint8List>();
        reader.onLoad.listen((event) {
          final arrayBuffer = reader.result as List<int>;
          completer.complete(Uint8List.fromList(arrayBuffer));
        });
        reader.onError.listen((event) {
          completer.completeError('Failed to read image data');
        });
        reader.readAsArrayBuffer(blob);

        final imageBytes = await completer.future;
        final codec = await ui.instantiateImageCodec(imageBytes);
        final frame = await codec.getNextFrame();
        codec.dispose();

        return frame.image;
      }
    } catch (e) {
      print('Error loading image from network: $e');
    }

    return null;
  }

  /// Draw device frame with screenshot using layout-aware positioning
  static Future<void> _drawLayoutAwareDeviceFrame(
    Canvas canvas,
    ScreenshotModel screenshot,
    String deviceId,
    Size exportSize,
    ScreenConfig screenConfig,
    EditorState editorState,
  ) async {
    // Get the layout configuration for this screen
    final layoutId = screenConfig.layoutId ?? editorState.selectedLayoutId;
    final frameVariant = editorState.selectedFrameVariant;

    // Import layout utilities
    final layout = LayoutsData.getLayoutById(layoutId);
    if (layout == null) {
      // Fallback to regular frame rendering if layout not found
      await _drawDeviceFrameWithScreenshot(
          canvas, screenshot, deviceId, exportSize);
      return;
    }

    final config = layout.config;

    // Calculate device frame position and size based on layout
    final devicePosition =
        LayoutRenderer.calculateDevicePosition(config, exportSize);
    final deviceSize = LayoutRenderer.calculateDeviceSize(config, exportSize);

    // Draw the device frame with rotation
    final deviceRect = Rect.fromLTWH(
      devicePosition.dx - deviceSize.width / 2,
      devicePosition.dy - deviceSize.height / 2,
      deviceSize.width,
      deviceSize.height,
    );

    // Apply rotation transformation
    canvas.save();
    canvas.translate(devicePosition.dx, devicePosition.dy);
    canvas.rotate(
        config.deviceRotation * 3.14159 / 180); // Convert degrees to radians
    canvas.translate(-devicePosition.dx, -devicePosition.dy);

    // Draw device frame based on variant
    if (frameVariant == 'real' ||
        frameVariant == 'clay' ||
        frameVariant == 'matte') {
      // Use the existing frame rendering logic but with calculated position
      await _drawRealDeviceFrame(
        canvas,
        screenshot,
        DeviceService.getDeviceById(deviceId)!,
        'assets/frames/${frameVariant}_frame.png', // Adjust path as needed
        exportSize,
      );
    } else {
      // Draw generic frame with calculated position
      await _drawGenericFrameWithScreenshot(
        canvas,
        screenshot,
        exportSize,
      );
    }

    canvas.restore();
  }

  /// Draw text overlays using layout-aware positioning
  static Future<void> _drawLayoutAwareTextOverlays(
    Canvas canvas,
    ScreenTextConfig textConfig,
    Size exportSize,
    ScreenConfig screenConfig,
    EditorState editorState,
  ) async {
    // Get the layout configuration for this screen
    final layoutId = screenConfig.layoutId ?? editorState.selectedLayoutId;

    final layout = LayoutsData.getLayoutById(layoutId);
    if (layout == null) {
      // Fallback to regular text rendering if layout not found
      await _drawTextOverlays(canvas, textConfig, exportSize);
      return;
    }

    final config = layout.config;

    // Calculate device position and size once for both title and subtitle
    final devicePosition =
        LayoutRenderer.calculateDevicePosition(config, exportSize);
    final deviceSize = LayoutRenderer.calculateDeviceSize(config, exportSize);

    // Draw title text based on layout position
    final titleElement = textConfig.getElement(TextFieldType.title);
    if (titleElement != null && titleElement.content.isNotEmpty) {
      final titlePosition = LayoutRenderer.calculateTextPosition(
        config.titlePosition,
        config,
        exportSize,
        deviceSize,
        devicePosition,
      );
      await _drawLayoutAwareTextElement(
        canvas,
        titleElement,
        titlePosition,
        exportSize,
      );
    }

    // Draw subtitle text based on layout position
    final subtitleElement = textConfig.getElement(TextFieldType.subtitle);
    if (subtitleElement != null && subtitleElement.content.isNotEmpty) {
      final subtitlePosition = LayoutRenderer.calculateTextPosition(
        config.subtitlePosition,
        config,
        exportSize,
        deviceSize,
        devicePosition,
      );
      await _drawLayoutAwareTextElement(
        canvas,
        subtitleElement,
        subtitlePosition,
        exportSize,
      );
    }
  }

  /// Draw a single text element with layout-aware positioning
  static Future<void> _drawLayoutAwareTextElement(
    Canvas canvas,
    TextElement element,
    Offset position,
    Size exportSize,
  ) async {
    // Scale font size for export resolution (assuming preview is ~800px height, export is ~2796px)
    final scaleFactor = exportSize.height / 800;
    final exportFontSize = element.fontSize * scaleFactor;

    final textPainter = TextPainter(
      text: TextSpan(
        text: element.content,
        style: TextStyle(
          fontFamily: element.fontFamily,
          fontSize:
              exportFontSize.clamp(16.0, 200.0), // Reasonable bounds for export
          fontWeight: element.fontWeight,
          color: element.color,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: element.textAlign,
      maxLines: element.type == TextFieldType.title ? 3 : 2,
    );

    // Use a reasonable max width for text layout
    textPainter.layout(maxWidth: exportSize.width * 0.8);

    // Calculate position based on text alignment
    double textX = position.dx;
    if (element.textAlign == TextAlign.center) {
      textX = position.dx - textPainter.width / 2;
    } else if (element.textAlign == TextAlign.right) {
      textX = position.dx - textPainter.width;
    }

    textPainter.paint(canvas, Offset(textX, position.dy));
    textPainter.dispose();
  }
}
