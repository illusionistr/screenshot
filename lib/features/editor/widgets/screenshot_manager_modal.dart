import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/models/project_model.dart';
import '../../shared/models/device_model.dart';
import '../../shared/models/screenshot_model.dart';
import '../../shared/models/upload_state_model.dart';
import '../../shared/providers/upload_provider.dart';
import '../../shared/widgets/drag_drop_upload_zone.dart';
import '../../shared/widgets/upload_progress_indicator.dart';
import '../../shared/widgets/upload_grid_view.dart';
import '../models/editor_state.dart';
import '../providers/editor_provider.dart';

class ScreenshotManagerModal extends ConsumerStatefulWidget {
  const ScreenshotManagerModal({
    super.key,
    required this.project,
    this.onClose,
  });

  final ProjectModel project;
  final VoidCallback? onClose;

  @override
  ConsumerState<ScreenshotManagerModal> createState() => _ScreenshotManagerModalState();
}

class _ScreenshotManagerModalState extends ConsumerState<ScreenshotManagerModal> {
  String? selectedDeviceId;
  String? selectedLanguageCode;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with first available device and language
    final editorState = ref.read(editorProviderFamily(widget.project));
    selectedDeviceId = editorState.availableDevices.isNotEmpty 
        ? editorState.availableDevices.first.id 
        : null;
    selectedLanguageCode = editorState.availableLanguages.isNotEmpty 
        ? editorState.availableLanguages.first 
        : 'en';
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProviderFamily(widget.project));
    final uploadProgress = ref.watch(uploadProgressNotifierProvider);
    final uploadQueue = ref.watch(uploadQueueNotifierProvider);
    final uploadCoordinator = ref.watch(uploadCoordinatorProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Modal Header
            _buildModalHeader(context),
            
            // Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Device and Language Selectors
                    _buildSelectors(editorState),
                    
                    const SizedBox(height: 24),
                    
                    // Upload Progress (if any uploads in progress)
                    if (uploadProgress.isNotEmpty) ...[
                      _buildUploadProgress(uploadProgress),
                      const SizedBox(height: 24),
                    ],
                    
                    // Drag & Drop Upload Zone
                    Expanded(
                      flex: 2,
                      child: DragDropUploadZone(
                        onFilesDropped: _handleFilesDropped,
                        onTap: _handleTapToSelect,
                        enabled: !_isUploading && 
                                selectedDeviceId != null && 
                                selectedLanguageCode != null,
                        title: _getUploadZoneTitle(),
                        subtitle: _getUploadZoneSubtitle(),
                        height: double.infinity,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Existing Screenshots Grid
                    Expanded(
                      flex: 3,
                      child: _buildExistingScreenshots(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Modal Footer
            _buildModalFooter(uploadProgress),
          ],
        ),
      ),
    );
  }

  Widget _buildModalHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.photo_library,
            color: Color(0xFFE91E63),
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Manage App Screenshots',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(
              Icons.close,
              color: Color(0xFF6C757D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectors(EditorState editorState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Device Selector
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Target Device',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF495057),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE1E5E9)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedDeviceId,
                          isExpanded: true,
                          hint: const Text('Select device'),
                          items: editorState.availableDevices
                              .map((device) => DropdownMenuItem(
                                    value: device.id,
                                    child: Text(device.name),
                                  ))
                              .toList(),
                          onChanged: _isUploading 
                              ? null 
                              : (value) {
                                  setState(() {
                                    selectedDeviceId = value;
                                  });
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Language Selector
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Language',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF495057),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE1E5E9)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedLanguageCode,
                          isExpanded: true,
                          hint: const Text('Select language'),
                          items: editorState.availableLanguages
                              .map((languageCode) => DropdownMenuItem(
                                    value: languageCode,
                                    child: Text(_formatLanguageDisplay(languageCode)),
                                  ))
                              .toList(),
                          onChanged: _isUploading 
                              ? null 
                              : (value) {
                                  setState(() {
                                    selectedLanguageCode = value;
                                  });
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress(Map<String, UploadProgress> uploadProgress) {
    final activeUploads = uploadProgress.values
        .where((p) => p.isInProgress)
        .toList();
    
    if (activeUploads.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_upload,
                color: Color(0xFFE91E63),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Uploading ${activeUploads.length} file${activeUploads.length > 1 ? 's' : ''}...',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...activeUploads.map((progress) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: UploadProgressIndicator(progress: progress),
              )),
        ],
      ),
    );
  }


  Widget _buildExistingScreenshots() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE1E5E9)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF6C757D),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Existing Screenshots',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.project.getTotalScreenshotCount()} screenshots',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C757D),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.project.hasScreenshots()
                ? UploadGridView(
                    screenshots: widget.project.getAllScreenshots(),
                    onScreenshotTap: _handleScreenshotTap,
                    onScreenshotDelete: _handleScreenshotDelete,
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 48,
                          color: Color(0xFFE1E5E9),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No screenshots uploaded yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6C757D),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Upload your first screenshot above',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalFooter(Map<String, UploadProgress> uploadProgress) {
    final hasActiveUploads = uploadProgress.values.any((p) => p.isInProgress);
    final hasFailedUploads = uploadProgress.values.any((p) => p.hasError);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(color: Color(0xFFE1E5E9)),
        ),
      ),
      child: Row(
        children: [
          // Upload status info
          if (hasActiveUploads)
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text(
                  'Uploading files...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C757D),
                  ),
                ),
              ],
            )
          else if (hasFailedUploads)
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${uploadProgress.values.where((p) => p.hasError).length} failed',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              ],
            )
          else
            Text(
              '${widget.project.getTotalScreenshotCount()} total screenshots',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6C757D),
              ),
            ),

          const Spacer(),

          // Action buttons
          if (hasFailedUploads) ...[
            TextButton(
              onPressed: _retryFailedUploads,
              child: const Text('Retry Failed'),
            ),
            const SizedBox(width: 12),
          ],
          
          TextButton(
            onPressed: widget.onClose,
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _handleFilesDropped(List<html.File> files) {
    _handleFiles(files);
  }

  void _handleTapToSelect() {
    // Trigger file selection dialog
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = true;
    
    input.click();
    
    input.onChange.listen((event) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        _handleFiles(files);
      }
    });
  }

  void _handleFiles(List<html.File> files) {
    if (selectedDeviceId == null || selectedLanguageCode == null) {
      _showSnackBar('Please select device and language first', isError: true);
      return;
    }

    if (files.isEmpty) return;

    // Add files to upload queue
    ref.read(uploadQueueNotifierProvider.notifier)
        .addFiles(files, selectedDeviceId!, selectedLanguageCode!);

    // Start upload process
    _startUpload(files);
  }

  void _startUpload(List<html.File> files) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final uploadFiles = files.map((file) => UploadFile(
        id: DateTime.now().millisecondsSinceEpoch.toString() + file.name,
        file: file,
        deviceId: selectedDeviceId!,
        languageCode: selectedLanguageCode!,
        addedAt: DateTime.now(),
      )).toList();

      await ref.read(uploadCoordinatorProvider.notifier).uploadFiles(
        projectId: widget.project.id,
        files: uploadFiles,
        onComplete: (result) {
          if (result.screenshot != null) {
            _showSnackBar('Screenshot uploaded successfully');
          } else {
            _showSnackBar('Upload failed: ${result.errorMessage}', isError: true);
          }
        },
      );
    } catch (e) {
      _showSnackBar('Upload failed: $e', isError: true);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _handleScreenshotTap(dynamic screenshot) {
    // Handle screenshot selection/preview
    // This could open a full-screen preview or add to editor
  }

  void _handleScreenshotDelete(dynamic screenshot) {
    // Handle screenshot deletion with confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Screenshot'),
        content: const Text('Are you sure you want to delete this screenshot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement screenshot deletion
              _showSnackBar('Screenshot deleted');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _retryFailedUploads() {
    final failedUploads = ref.read(uploadProgressNotifierProvider)
        .values
        .where((p) => p.hasError)
        .toList();

    if (failedUploads.isEmpty) return;

    // Clear failed progress and retry
    for (final failed in failedUploads) {
      ref.read(uploadProgressNotifierProvider.notifier)
          .removeProgress(failed.fileId);
    }

    _showSnackBar('Retrying ${failedUploads.length} failed uploads...');
  }

  String _getSelectedDeviceName() {
    if (selectedDeviceId == null) return '';
    final editorState = ref.read(editorProviderFamily(widget.project));
    try {
      return editorState.availableDevices
          .firstWhere((d) => d.id == selectedDeviceId)
          .name;
    } catch (e) {
      return selectedDeviceId!;
    }
  }

  String _formatLanguageDisplay(String languageCode) {
    const languageNames = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'zh': 'Chinese',
      'ja': 'Japanese',
      'ko': 'Korean',
    };
    
    return languageNames[languageCode] ?? languageCode.toUpperCase();
  }

  String _getUploadZoneTitle() {
    final bool canUpload = !_isUploading && 
                          selectedDeviceId != null && 
                          selectedLanguageCode != null;
    
    return canUpload
        ? 'Drag & drop screenshots here'
        : 'Select device and language first';
  }

  String _getUploadZoneSubtitle() {
    final bool canUpload = !_isUploading && 
                          selectedDeviceId != null && 
                          selectedLanguageCode != null;
    
    if (canUpload) {
      return 'Device: ${_getSelectedDeviceName()}\nLanguage: ${_formatLanguageDisplay(selectedLanguageCode!)}';
    } else {
      return 'Configure upload settings above';
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFFE91E63),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

