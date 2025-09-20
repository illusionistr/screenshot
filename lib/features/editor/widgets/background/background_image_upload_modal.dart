import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/drag_drop_upload_zone.dart';
import '../../providers/background_image_provider.dart';

class BackgroundImageUploadModal extends ConsumerStatefulWidget {
  const BackgroundImageUploadModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const BackgroundImageUploadModal(),
    );
  }

  @override
  ConsumerState<BackgroundImageUploadModal> createState() => _BackgroundImageUploadModalState();
}

class _BackgroundImageUploadModalState extends ConsumerState<BackgroundImageUploadModal> {
  UploadProgress uploadProgress = const UploadProgress();
  bool hasUploadedSuccessfully = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Background Image'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(hasUploadedSuccessfully ? 'Done' : 'Cancel'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (uploadProgress.isUploading) {
      return _buildUploadProgress();
    }

    if (uploadProgress.error != null) {
      return _buildErrorState();
    }

    if (hasUploadedSuccessfully) {
      return _buildSuccessState();
    }

    return _buildUploadZone();
  }

  Widget _buildUploadZone() {
    return Column(
      children: [
        Expanded(
          child: DragDropUploadZone(
            onFilesDropped: _handleFilesDropped,
            title: 'Drop background image here',
            subtitle: 'or click to browse files',
            icon: Icon(
              Icons.image_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            allowMultiple: false,
          ),
        ),
        const SizedBox(height: 16),
        _buildFileRequirements(),
      ],
    );
  }

  Widget _buildFileRequirements() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.blue.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'File Requirements',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Supported formats: PNG, JPG, JPEG, WebP\n'
            '• Maximum file size: 10MB\n'
            '• Recommended dimensions: 1920×1080 or higher',
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          value: uploadProgress.progress,
          strokeWidth: 3,
        ),
        const SizedBox(height: 16),
        Text(
          'Uploading ${uploadProgress.fileName ?? "file"}...',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(uploadProgress.progress * 100).toStringAsFixed(0)}% complete',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red.shade400,
        ),
        const SizedBox(height: 16),
        const Text(
          'Upload Failed',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          uploadProgress.error!,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _resetUpload,
          child: const Text('Try Again'),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 64,
          color: Colors.green.shade400,
        ),
        const SizedBox(height: 16),
        const Text(
          'Upload Successful!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your background image has been uploaded and is ready to use.',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _resetUpload,
          child: const Text('Upload Another'),
        ),
      ],
    );
  }


  void _handleFilesDropped(List<html.File> files) async {
    if (files.isEmpty) return;
    
    final file = files.first;
    
    // Validate file
    try {
      _validateFile(file);
    } catch (e) {
      setState(() {
        uploadProgress = UploadProgress(error: e.toString());
      });
      return;
    }

    // Start upload
    final backgroundImageNotifier = ref.read(backgroundImageProvider.notifier);
    
    setState(() {
      uploadProgress = UploadProgress(
        isUploading: true,
        fileName: file.name,
      );
    });

    try {
      final result = await backgroundImageNotifier.uploadBackgroundImage(file);
      
      if (result != null) {
        setState(() {
          uploadProgress = const UploadProgress();
          hasUploadedSuccessfully = true;
        });
      } else {
        setState(() {
          uploadProgress = const UploadProgress(
            error: 'Upload failed. Please try again.',
          );
        });
      }
    } catch (e) {
      setState(() {
        uploadProgress = UploadProgress(
          error: e.toString(),
        );
      });
    }
  }

  void _validateFile(html.File file) {
    // Check file size
    if (file.size > 10 * 1024 * 1024) {
      throw Exception('File size exceeds 10MB limit');
    }

    // Check file extension
    final extension = file.name.split('.').last.toLowerCase();
    if (!['png', 'jpg', 'jpeg', 'webp'].contains(extension)) {
      throw Exception('Only PNG, JPG, JPEG, and WebP files are allowed');
    }
  }

  void _resetUpload() {
    setState(() {
      uploadProgress = const UploadProgress();
      hasUploadedSuccessfully = false;
    });
  }
}