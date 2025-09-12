import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../projects/models/project_model.dart';
import '../../shared/models/screenshot_model.dart';
import '../constants/platform_dimensions.dart';
import '../services/platform_detection_service.dart';
import 'export_saver.dart';
import '../widgets/export/export_screen_view.dart';

class ExportJob {
  final String deviceId;
  final String languageCode;
  final int screenIndex; // 0-based
  final bool isLandscape;
  final String layoutId;
  final String frameVariant;
  final ScreenshotModel? screenshot;
  final dynamic background; // ScreenBackground, typed in widget
  final dynamic textConfig; // ScreenTextConfig, typed in widget
  final Map<String, dynamic>? customSettings; // per-screen overrides

  ExportJob({
    required this.deviceId,
    required this.languageCode,
    required this.screenIndex,
    required this.isLandscape,
    required this.layoutId,
    required this.frameVariant,
    required this.screenshot,
    required this.background,
    required this.textConfig,
    this.customSettings,
  });
}

typedef ProgressCallback = void Function(int completed, int total, String label);

class BatchExportService {
  BatchExportService._();

  static Future<void> exportJobsToZip({
    required BuildContext context,
    required ProjectModel project,
    required List<ExportJob> jobs,
    ProgressCallback? onProgress,
    String? zipFilename,
    bool structureInFolders = true,
  }) async {
    if (jobs.isEmpty) return;

    final archive = Archive();
    int completed = 0;

    for (final job in jobs) {
      onProgress?.call(completed, jobs.length, _labelFor(job));
      try {
        final bytes = await _captureJob(context, job);
        final filename = _buildFilename(project.appName, job);
        final path = structureInFolders
            ? _buildFolderPath(project.appName, job, filename)
            : filename;
        archive.addFile(ArchiveFile(path, bytes.length, bytes));
      } catch (_) {
        // Skip failures; optionally could add a text report later
      }
      completed += 1;
      onProgress?.call(completed, jobs.length, _labelFor(job));
    }

    final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive)!);
    exportSaver.saveBytes(zipBytes, zipFilename ?? _defaultZipName(project.appName));
  }

  static String _sanitize(String s) => s.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  static String _defaultZipName(String projectName) => '${_sanitize(projectName)}_export.zip';

  static String _buildFilename(String projectName, ExportJob job) {
    final proj = _sanitize(projectName);
    return '${proj}_${job.deviceId}_${job.languageCode}_screen${job.screenIndex + 1}.png';
  }

  static String _buildFolderPath(String projectName, ExportJob job, String filename) {
    final proj = _sanitize(projectName);
    return '$proj/${job.deviceId}/${job.languageCode}/$filename';
  }

  static String _labelFor(ExportJob job) =>
      '${job.deviceId} • ${job.languageCode} • #${job.screenIndex + 1}';

  static Future<Uint8List> _captureJob(BuildContext context, ExportJob job) async {
    // Prepare required output size (platform compliant)
    final dims = PlatformDetectionService.getPlatformContainerDimensions(
      job.deviceId,
      isLandscape: job.isLandscape,
    );

    // Build an off-screen export view with same rendering stack
    final repaintKey = GlobalKey();
    final logicalSize = _calculateLogicalSize(job.deviceId, job.isLandscape);

    // Prefetch images if any
    await _prefetchIfAny(context, job);

    final overlay = Overlay.of(context, rootOverlay: true);
    if (overlay == null) throw Exception('No overlay found for export');

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -logicalSize.width - 200,
        top: -logicalSize.height - 200,
        child: RepaintBoundary(
          key: repaintKey,
          child: SizedBox(
            width: logicalSize.width,
            height: logicalSize.height,
            child: Material(
              type: MaterialType.transparency,
              child: ExportScreenView(
                deviceId: job.deviceId,
                isLandscape: job.isLandscape,
                background: job.background,
                textConfig: job.textConfig,
                assignedScreenshot: job.screenshot,
                layoutId: job.layoutId,
                frameVariant: job.frameVariant,
                customSettings: job.customSettings,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    // Wait for layout/paint
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 16));

    // Scale to target pixel size (based on height)
    final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final pixelRatio = dims.height / boundary.size.height;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    entry.remove();
    return byteData!.buffer.asUint8List();
  }

  static Size _calculateLogicalSize(String deviceId, bool isLandscape) {
    final dims = PlatformDetectionService.getDimensionsForDevice(deviceId, isLandscape: isLandscape);
    const logicalHeight = 700.0; // Matches PlatformDimensionCalculator.containerHeight
    final width = dims.getWidthForHeight(logicalHeight);
    return Size(width, logicalHeight);
  }

  static Future<void> _prefetchIfAny(BuildContext context, ExportJob job) async {
    final futures = <Future<void>>[];

    final screenshotUrl = job.screenshot?.storageUrl;
    if (screenshotUrl != null && screenshotUrl.isNotEmpty) {
      futures.add(precacheImage(NetworkImage(screenshotUrl), context));
    }

    // Background image support if present
    final bg = job.background;
    try {
      final imageUrl = bg?.imageUrl as String?; // Background may be ScreenBackground
      if (imageUrl != null && imageUrl.isNotEmpty) {
        futures.add(precacheImage(NetworkImage(imageUrl), context));
      }
    } catch (_) {}

    if (futures.isNotEmpty) {
      await Future.wait(futures.map((f) => f.timeout(const Duration(seconds: 10))),
          eagerError: false, cleanUp: (_) {});
    }
  }
}

