import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/screenshot_model.dart';
import '../../shared/providers/upload_provider.dart';
import '../../shared/widgets/drag_drop_upload_zone.dart';
import '../../shared/widgets/upload_progress_indicator.dart';
import '../../shared/widgets/upload_grid_view.dart';

class EditorUploadPanel extends ConsumerStatefulWidget {
  final String projectId;
  final String deviceId;
  final String languageCode;
  final List<ScreenshotModel> screenshots;
  final Function(ScreenshotModel)? onScreenshotAdded;
  final Function(ScreenshotModel)? onScreenshotDeleted;
  final Function(ScreenshotModel)? onScreenshotSelected;
  final ScreenshotModel? selectedScreenshot;

  const EditorUploadPanel({
    super.key,
    required this.projectId,
    required this.deviceId,
    required this.languageCode,
    required this.screenshots,
    this.onScreenshotAdded,
    this.onScreenshotDeleted,
    this.onScreenshotSelected,
    this.selectedScreenshot,
  });

  @override
  ConsumerState<EditorUploadPanel> createState() => _EditorUploadPanelState();
}

class _EditorUploadPanelState extends ConsumerState<EditorUploadPanel> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final uploadProgress = ref.watch(uploadProgressNotifierProvider);
    final hasActiveUploads = uploadProgress.values.any((p) => p.isInProgress);

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, hasActiveUploads),
          
          // Collapsible content
          if (_isExpanded) ...[
            const Divider(height: 1),
            
            // Upload zone (when no screenshots or always available)
            if (widget.screenshots.isEmpty || hasActiveUploads) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: DragDropUploadZone(
                  onFilesDropped: _handleFiles,
                  enabled: !hasActiveUploads,
                  height: widget.screenshots.isEmpty ? 200 : 120,
                  title: hasActiveUploads 
                      ? 'Uploading...' 
                      : widget.screenshots.isEmpty
                          ? 'Add screenshots to start editing'
                          : 'Add more screenshots',
                  subtitle: widget.screenshots.isEmpty 
                      ? 'Drop screenshot files here or click to browse'
                      : null,
                ),
              ),
            ],

            // Upload progress
            if (uploadProgress.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: UploadProgressList(
                  progressList: uploadProgress.values.toList(),
                  onCancel: (fileId) => 
                      ref.read(uploadProgressNotifierProvider.notifier).removeProgress(fileId),
                  showOverallProgress: false,
                  maxHeight: 150,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],

            // Screenshots grid
            if (widget.screenshots.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.screenshots.isEmpty && !hasActiveUploads) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.screenshots.length} screenshots',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          TextButton.icon(
                            onPressed: () => _showUploadDialog(context),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add more'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    ResponsiveUploadGridView(
                      screenshots: widget.screenshots,
                      onScreenshotTap: widget.onScreenshotSelected,
                      onScreenshotDelete: widget.onScreenshotDeleted,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 0.75,
                      showEmptyState: false,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool hasActiveUploads) {
    return ListTile(
      leading: Icon(
        hasActiveUploads ? Icons.cloud_upload : Icons.image_outlined,
        color: hasActiveUploads ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        hasActiveUploads ? 'Uploading screenshots...' : 'Screenshots',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${widget.deviceId} • ${widget.languageCode.toUpperCase()}',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: IconButton(
        icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
        onPressed: () => setState(() => _isExpanded = !_isExpanded),
        tooltip: _isExpanded ? 'Collapse' : 'Expand',
      ),
    );
  }

  void _handleFiles(List<html.File> files) async {
    final coordinator = ref.read(uploadCoordinatorProvider.notifier);
    final queueNotifier = ref.read(uploadQueueNotifierProvider.notifier);
    
    // Add files to queue
    queueNotifier.addFiles(files, widget.deviceId, widget.languageCode);
    
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
          // Notify parent of new screenshot
          widget.onScreenshotAdded?.call(result.screenshot!);
          
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

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Screenshots'),
        content: SizedBox(
          width: 400,
          height: 200,
          child: DragDropUploadZone(
            onFilesDropped: (files) {
              Navigator.of(context).pop();
              _handleFiles(files);
            },
            title: 'Drop files here',
            subtitle: 'or click to browse',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}