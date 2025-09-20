import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../../shared/models/device_model.dart';
import '../../shared/models/screenshot_model.dart';
import '../../shared/providers/upload_provider.dart';
import '../../shared/widgets/drag_drop_upload_zone.dart';
import '../../shared/widgets/upload_progress_indicator.dart';
import '../../shared/widgets/upload_grid_view.dart';
import '../providers/upload_provider.dart' as project_providers;

class ScreenshotUploadSection extends ConsumerStatefulWidget {
  final String projectId;
  final DeviceModel device;
  final String selectedLanguage;
  final List<ScreenshotModel> screenshots;

  const ScreenshotUploadSection({
    super.key,
    required this.projectId,
    required this.device,
    required this.selectedLanguage,
    required this.screenshots,
  });

  @override
  ConsumerState<ScreenshotUploadSection> createState() =>
      _ScreenshotUploadSectionState();
}

class _ScreenshotUploadSectionState
    extends ConsumerState<ScreenshotUploadSection> {
  
  @override
  Widget build(BuildContext context) {
    final uploadProgress = ref.watch(uploadProgressNotifierProvider);
    final isUploading = uploadProgress.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 24.0),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Header
            Row(
              children: [
                Text(
                  widget.device.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.device.screenWidth} × ${widget.device.screenHeight}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Upload Area
            DragDropUploadZone(
              onFilesDropped: _handleFiles,
              enabled: !isUploading,
              height: 200,
              title: isUploading ? 'Uploading...' : null,
            ),

            // Upload Progress
            if (uploadProgress.isNotEmpty) ...[
              const SizedBox(height: 16),
              UploadProgressList(
                progressList: uploadProgress.values.toList(),
                onCancel: (fileId) => ref.read(uploadProgressNotifierProvider.notifier).removeProgress(fileId),
                showOverallProgress: false,
                maxHeight: 200,
                padding: EdgeInsets.zero,
              ),
            ],

            // Screenshots Grid
            if (widget.screenshots.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '${widget.screenshots.length} screenshot(s) uploaded',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              UploadGridView(
                screenshots: widget.screenshots,
                onScreenshotDelete: _deleteScreenshot,
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.6,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                showEmptyState: false,
              ),
            ],
          ],
        ),
      ),
    );
  }


  void _handleFiles(List<html.File> files) async {
    final coordinator = ref.read(uploadCoordinatorProvider.notifier);
    final queueNotifier = ref.read(uploadQueueNotifierProvider.notifier);
    
    // Add files to queue
    queueNotifier.addFiles(files, widget.device.id, widget.selectedLanguage);
    
    // Get upload files from queue
    final queue = ref.read(uploadQueueNotifierProvider);
    final uploadFiles = queue
        .where((file) => files.any((f) => f.name == file.file.name))
        .toList();
    
    // Start upload
    await coordinator.uploadFiles(
      projectId: widget.projectId,
      files: uploadFiles,
      onComplete: (result) async {
        if (result.isSuccess && result.screenshot != null) {
          // Add to project screenshots
          final screenshotsNotifier = ref.read(project_providers.projectScreenshotsProvider(widget.projectId).notifier);
          await screenshotsNotifier.addScreenshot(result.screenshot!);
          
          // Remove from queue
          queueNotifier.removeFile(result.fileId);
          
          // Remove from progress after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            ref.read(uploadProgressNotifierProvider.notifier).removeProgress(result.fileId);
          });
        } else if (result.hasError) {
          // Show error snackbar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload failed: ${result.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          
          // Remove from progress after delay
          Future.delayed(const Duration(seconds: 3), () {
            ref.read(uploadProgressNotifierProvider.notifier).removeProgress(result.fileId);
          });
        }
      },
    );
  }

  void _deleteScreenshot(ScreenshotModel screenshot) async {
    try {
      final uploadService = ref.read(uploadServiceProvider);
      final screenshotsNotifier = ref.read(project_providers.projectScreenshotsProvider(widget.projectId).notifier);

      // Delete from Firebase Storage
      final storagePath = uploadService.getStoragePathFromUrl(screenshot.storageUrl);
      await uploadService.deleteFile(storagePath);

      // Remove from state
      await screenshotsNotifier.removeScreenshot(
        screenshot.id,
        screenshot.languageCode,
        screenshot.deviceId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screenshot deleted')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete screenshot: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}