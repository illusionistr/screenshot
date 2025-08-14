import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/constants/upload_constants.dart';
import '../../../config/dependency_injection.dart';
import '../services/screenshot_manager.dart';

class UploadProgress {
  final String fileName;
  final double progress;
  final String status; // 'uploading', 'compressing', 'completed', 'error'
  final String? error;

  const UploadProgress({
    required this.fileName,
    required this.progress,
    required this.status,
    this.error,
  });

  UploadProgress copyWith({
    String? fileName,
    double? progress,
    String? status,
    String? error,
  }) {
    return UploadProgress(
      fileName: fileName ?? this.fileName,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

class ScreenshotUploader extends StatefulWidget {
  final Function(List<FileUpload>) onFilesSelected;
  final bool allowMultiple;
  final bool showDropZone;
  final String? helpText;

  const ScreenshotUploader({
    super.key,
    required this.onFilesSelected,
    this.allowMultiple = true,
    this.showDropZone = true,
    this.helpText,
  });

  @override
  State<ScreenshotUploader> createState() => ScreenshotUploaderState();
}

class FileUpload {
  final String fileName;
  final Uint8List bytes;
  final String? mimeType;

  const FileUpload({
    required this.fileName,
    required this.bytes,
    this.mimeType,
  });
}

class ScreenshotUploaderState extends State<ScreenshotUploader> {
  bool _isDragOver = false;
  final List<UploadProgress> _uploadProgress = [];
  final ScreenshotManager _screenshotManager = serviceLocator<ScreenshotManager>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // File picker button
        ElevatedButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.upload_file),
          label: Text(widget.allowMultiple ? 'Choose Files' : 'Choose File'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
        
        if (widget.showDropZone) ...[
          const SizedBox(height: 16),
          const Text(
            'or',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          
          // Drag & Drop Zone
          _buildDropZone(),
        ],
        
        // Help text
        if (widget.helpText != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.helpText!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
        
        // Upload constraints info
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    'File Requirements',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Max size: ${(UploadConstants.maxFileSizeBytes / (1024 * 1024)).toInt()}MB per file\n'
                '• Formats: PNG, JPEG\n'
                '• Images will be automatically optimized for web viewing',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ),
        
        // Progress indicators
        if (_uploadProgress.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._uploadProgress.map((progress) => _buildProgressItem(progress)),
        ],
      ],
    );
  }

  Widget _buildDropZone() {
    return GestureDetector(
      onTap: _pickFiles,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: _isDragOver ? Colors.blue : Colors.grey[300]!,
            width: _isDragOver ? 2 : 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _isDragOver ? Colors.blue[50] : Colors.grey[50],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 40,
              color: _isDragOver ? Colors.blue : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              'Drop screenshots here or click to browse',
              style: TextStyle(
                fontSize: 14,
                color: _isDragOver ? Colors.blue : Colors.grey[600],
                fontWeight: _isDragOver ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.allowMultiple ? 'Multiple files supported' : 'Single file only',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(UploadProgress progress) {
    Color statusColor;
    IconData statusIcon;
    
    switch (progress.status) {
      case 'uploading':
        statusColor = Colors.blue;
        statusIcon = Icons.upload;
        break;
      case 'compressing':
        statusColor = Colors.orange;
        statusIcon = Icons.compress;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'error':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.file_present;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, size: 16, color: statusColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  progress.fileName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(progress.progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
          if (progress.error != null) ...[
            const SizedBox(height: 8),
            Text(
              progress.error!,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: UploadConstants.allowedExtensions,
        allowMultiple: widget.allowMultiple,
      );

      if (result != null && result.files.isNotEmpty) {
        await _processSelectedFiles(result.files);
      }
    } catch (e) {
      _showError('Failed to pick files: $e');
    }
  }

  Future<void> _processSelectedFiles(List<PlatformFile> files) async {
    final List<FileUpload> validFiles = [];
    
    // Clear previous progress
    setState(() {
      _uploadProgress.clear();
    });

    for (final file in files) {
      if (file.bytes == null) {
        _showError('Failed to read file: ${file.name}');
        continue;
      }

      // Add to progress tracking
      setState(() {
        _uploadProgress.add(UploadProgress(
          fileName: file.name,
          progress: 0.0,
          status: 'uploading',
        ));
      });

      // Validate file
      final validation = _screenshotManager.validateFile(
        fileBytes: file.bytes!,
        fileName: file.name,
        mimeType: file.extension != null ? 'image/${file.extension}' : null,
      );

      final progressIndex = _uploadProgress.length - 1;

      if (!validation.isValid) {
        setState(() {
          _uploadProgress[progressIndex] = _uploadProgress[progressIndex].copyWith(
            status: 'error',
            error: validation.error,
            progress: 0.0,
          );
        });
        continue;
      }

      // File is valid, add to upload list
      validFiles.add(FileUpload(
        fileName: file.name,
        bytes: file.bytes!,
        mimeType: file.extension != null ? 'image/${file.extension}' : null,
      ));

      // Update progress to completed validation
      setState(() {
        _uploadProgress[progressIndex] = _uploadProgress[progressIndex].copyWith(
          status: 'completed',
          progress: 1.0,
        );
      });
    }

    // Notify parent component about valid files
    if (validFiles.isNotEmpty) {
      widget.onFilesSelected(validFiles);
    }

    // Clear progress after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _uploadProgress.clear();
        });
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Public method to update progress from parent
  void updateProgress(String fileName, double progress, String status, {String? error}) {
    if (!mounted) return;
    
    setState(() {
      final index = _uploadProgress.indexWhere((p) => p.fileName == fileName);
      if (index != -1) {
        _uploadProgress[index] = _uploadProgress[index].copyWith(
          progress: progress,
          status: status,
          error: error,
        );
      }
    });
  }

  // Public method to add progress item
  void addProgressItem(String fileName) {
    if (!mounted) return;
    
    setState(() {
      _uploadProgress.add(UploadProgress(
        fileName: fileName,
        progress: 0.0,
        status: 'uploading',
      ));
    });
  }
}