import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../../shared/models/device_model.dart';
import '../../shared/models/screenshot_model.dart';
import '../providers/upload_provider.dart';
import 'screenshot_thumbnail.dart';

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
  bool _isDragOver = false;

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
            GestureDetector(
              onTap: isUploading ? null : _pickFiles,
              child: DragTarget<List<html.File>>(
                onWillAccept: (_) => !isUploading,
                onAccept: (files) => _handleFiles(files),
                onMove: (_) => setState(() => _isDragOver = true),
                onLeave: (_) => setState(() => _isDragOver = false),
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isDragOver
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: _isDragOver ? 2 : 1,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: _isDragOver
                          ? Theme.of(context).primaryColor.withOpacity(0.05)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isUploading
                              ? Icons.upload_file
                              : Icons.cloud_upload_outlined,
                          size: 48,
                          color: isUploading
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isUploading
                              ? 'Uploading...'
                              : 'Drag & drop screenshots here',
                          style: TextStyle(
                            fontSize: 16,
                            color: isUploading
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                        ),
                        if (!isUploading) ...[
                          const SizedBox(height: 4),
                          const Text(
                            'or click to browse files',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'PNG, JPG, JPEG • Max 10MB',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Upload Progress
            if (uploadProgress.isNotEmpty) ...[
              const SizedBox(height: 16),
              Column(
                children: uploadProgress.entries.map((entry) {
                  final progress = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                progress.filename,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${(progress.progress * 100).toInt()}%',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress.progress,
                          backgroundColor: Colors.grey[200],
                        ),
                        if (progress.errorMessage != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            progress.errorMessage!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.6,
                ),
                itemCount: widget.screenshots.length,
                itemBuilder: (context, index) {
                  final screenshot = widget.screenshots[index];
                  return ScreenshotThumbnail(
                    screenshot: screenshot,
                    onDelete: () => _deleteScreenshot(screenshot),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _pickFiles() async {
    final input = html.FileUploadInputElement()..accept = 'image/*'..multiple = true;
    input.click();

    input.onChange.listen((e) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        _handleFiles(files);
      }
    });
  }

  void _handleFiles(List<html.File> files) async {
    final uploadService = ref.read(uploadServiceProvider);
    final progressNotifier = ref.read(uploadProgressNotifierProvider.notifier);
    final screenshotsNotifier = ref.read(projectScreenshotsProvider(widget.projectId).notifier);

    for (final file in files) {
      final fileId = '${widget.device.id}_${file.name}_${DateTime.now().millisecondsSinceEpoch}';
      
      try {
        // Initialize progress
        progressNotifier.updateProgress(
          fileId,
          UploadProgress(filename: file.name, progress: 0.0),
        );

        // Upload file
        final screenshot = await uploadService.uploadFile(
          projectId: widget.projectId,
          file: file,
          deviceId: widget.device.id,
          languageCode: widget.selectedLanguage,
          onProgress: (progress) {
            progressNotifier.updateProgress(
              fileId,
              UploadProgress(filename: file.name, progress: progress),
            );
          },
        );

        // Mark as completed
        progressNotifier.updateProgress(
          fileId,
          UploadProgress(filename: file.name, progress: 1.0, isCompleted: true),
        );

        // Add to screenshots
        await screenshotsNotifier.addScreenshot(screenshot);

        // Remove from progress after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          progressNotifier.removeProgress(fileId);
        });

      } catch (error) {
        // Mark as error
        progressNotifier.updateProgress(
          fileId,
          UploadProgress(
            filename: file.name,
            progress: 0.0,
            errorMessage: error.toString(),
          ),
        );

        // Show error snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload ${file.name}: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }

        // Remove from progress after delay
        Future.delayed(const Duration(seconds: 3), () {
          progressNotifier.removeProgress(fileId);
        });
      }
    }
  }

  void _deleteScreenshot(ScreenshotModel screenshot) async {
    try {
      final uploadService = ref.read(uploadServiceProvider);
      final screenshotsNotifier = ref.read(projectScreenshotsProvider(widget.projectId).notifier);

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