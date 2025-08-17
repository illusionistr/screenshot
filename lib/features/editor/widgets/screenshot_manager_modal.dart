import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/screenshot_model.dart';
import '../../shared/models/upload_state_model.dart';
import '../../shared/providers/upload_provider.dart';
import '../../shared/widgets/drag_drop_upload_zone.dart';
import '../../shared/widgets/upload_progress_indicator.dart';
import '../../shared/widgets/upload_grid_view.dart';

class ScreenshotManagerModal extends ConsumerStatefulWidget {
  final String projectId;
  final String deviceId;
  final String languageCode;
  final Map<String, Map<String, List<ScreenshotModel>>> allScreenshots;
  final Function(ScreenshotModel)? onScreenshotAdded;
  final Function(ScreenshotModel)? onScreenshotDeleted;
  final Function(ScreenshotModel)? onScreenshotSelected;

  const ScreenshotManagerModal({
    super.key,
    required this.projectId,
    required this.deviceId,
    required this.languageCode,
    required this.allScreenshots,
    this.onScreenshotAdded,
    this.onScreenshotDeleted,
    this.onScreenshotSelected,
  });

  @override
  ConsumerState<ScreenshotManagerModal> createState() => _ScreenshotManagerModalState();
}

class _ScreenshotManagerModalState extends ConsumerState<ScreenshotManagerModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentScreenshots = widget.allScreenshots[widget.languageCode]?[widget.deviceId] ?? [];
    final uploadProgress = ref.watch(uploadProgressNotifierProvider);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(
          maxWidth: 1000,
          maxHeight: 700,
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Upload New', icon: Icon(Icons.cloud_upload)),
                Tab(text: 'Browse All', icon: Icon(Icons.photo_library)),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Upload tab
                  _buildUploadTab(context, currentScreenshots, uploadProgress),
                  
                  // Browse tab
                  _buildBrowseTab(context),
                ],
              ),
            ),

            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.image_outlined,
            size: 28,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Screenshot Manager',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.deviceId} • ${widget.languageCode.toUpperCase()}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildUploadTab(
    BuildContext context,
    List<ScreenshotModel> currentScreenshots,
    Map<String, dynamic> uploadProgress,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload zone
          DragDropUploadZone(
            onFilesDropped: _handleFiles,
            enabled: uploadProgress.isEmpty,
            height: 200,
            title: uploadProgress.isNotEmpty ? 'Uploading...' : 'Add new screenshots',
            subtitle: 'Drop screenshot files here or click to browse',
          ),

          // Upload progress
          if (uploadProgress.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Upload Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            UploadProgressList(
              progressList: uploadProgress.values.map((e) => e as UploadProgress).toList(),
              onCancel: (fileId) => 
                  ref.read(uploadProgressNotifierProvider.notifier).removeProgress(fileId),
              maxHeight: 200,
              padding: EdgeInsets.zero,
            ),
          ],

          // Current screenshots preview
          if (currentScreenshots.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Current Screenshots (${currentScreenshots.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ResponsiveUploadGridView(
                screenshots: currentScreenshots,
                onScreenshotTap: (screenshot) {
                  widget.onScreenshotSelected?.call(screenshot);
                  Navigator.of(context).pop();
                },
                onScreenshotDelete: widget.onScreenshotDeleted,
                childAspectRatio: 0.75,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBrowseTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Screenshots',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse screenshots organized by language and device',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: GroupedUploadGridView(
              screenshotsByLanguageAndDevice: widget.allScreenshots,
              onScreenshotTap: (screenshot) {
                widget.onScreenshotSelected?.call(screenshot);
                Navigator.of(context).pop();
              },
              onScreenshotDelete: widget.onScreenshotDeleted,
              childAspectRatio: 0.75,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Statistics
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatisticsText(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(0),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Screenshots'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatisticsText() {
    int totalScreenshots = 0;
    int totalLanguages = widget.allScreenshots.keys.length;
    int totalDevices = 0;

    for (final languageScreenshots in widget.allScreenshots.values) {
      for (final deviceScreenshots in languageScreenshots.values) {
        totalScreenshots += deviceScreenshots.length;
      }
      if (languageScreenshots.keys.length > totalDevices) {
        totalDevices = languageScreenshots.keys.length;
      }
    }

    return '$totalScreenshots screenshots • $totalLanguages languages • $totalDevices devices';
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
}