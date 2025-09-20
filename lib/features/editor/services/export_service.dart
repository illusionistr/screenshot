import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../constants/platform_dimensions.dart';
import '../services/platform_detection_service.dart';
import 'export_saver.dart';

class ExportService {
  ExportService._();

  /// Captures the widget referenced by [repaintBoundaryKey] and downloads a PNG.
  ///
  /// - Scales the capture to App Store / Play Store compliant output resolution
  ///   using [PlatformDimensions] for the given [deviceId] and [isLandscape].
  /// - On Web, triggers a browser download via an anchor element.
  static Future<void> exportScreenAsPng({
    required GlobalKey repaintBoundaryKey,
    required String deviceId,
    bool isLandscape = false,
    String filename = 'screenshot.png',
  }) async {
    final ctx = repaintBoundaryKey.currentContext;
    if (ctx == null) {
      throw Exception('Export failed: widget context is not available');
    }

    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw Exception('Export failed: no RepaintBoundary found');
    }

    // Desired output dimensions per platform requirements
    final dims = PlatformDetectionService.getPlatformContainerDimensions(
      deviceId,
      isLandscape: isLandscape,
    );

    // Current logical size on screen
    final logicalSize = renderObject.size;
    if (logicalSize.height == 0 || logicalSize.width == 0) {
      throw Exception('Export failed: target size is zero');
    }

    // Compute scale so the exported image matches desired pixels (based on height)
    final double pixelRatio = dims.height / logicalSize.height;

    // Capture image at scaled resolution
    final ui.Image image = await renderObject.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (byteData == null) {
      throw Exception('Export failed: could not encode image');
    }

    final bytes = byteData.buffer.asUint8List();
    exportSaver.saveBytes(bytes, filename);
  }
}
