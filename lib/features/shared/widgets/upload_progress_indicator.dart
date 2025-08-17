import 'package:flutter/material.dart';

import '../models/upload_state_model.dart';
import '../services/file_validation_service.dart';

class UploadProgressIndicator extends StatelessWidget {
  final UploadProgress progress;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final bool showDetails;
  final EdgeInsets? padding;

  const UploadProgressIndicator({
    super.key,
    required this.progress,
    this.onCancel,
    this.onRetry,
    this.showDetails = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File info row
          Row(
            children: [
              // File icon
              Icon(
                _getFileIcon(),
                color: _getStatusColor(context),
                size: 20,
              ),
              const SizedBox(width: 8),

              // File name and size
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.filename,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showDetails && progress.fileSize != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        FileValidationService.formatFileSize(progress.fileSize!),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Status indicator or actions
              _buildStatusWidget(context),
            ],
          ),

          // Progress bar (only for in-progress uploads)
          if (progress.isInProgress) ...[
            const SizedBox(height: 8),
            _buildProgressBar(context),
          ],

          // Error message
          if (progress.hasError) ...[
            const SizedBox(height: 8),
            _buildErrorMessage(context),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusWidget(BuildContext context) {
    if (progress.hasError) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRetry != null) ...[
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              iconSize: 18,
              tooltip: 'Retry upload',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close),
            iconSize: 18,
            tooltip: 'Remove',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      );
    }

    if (progress.isCompleted) {
      return Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 20,
      );
    }

    if (progress.isInProgress) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: progress.progress,
            ),
          ),
          if (onCancel != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onCancel,
              icon: const Icon(Icons.close),
              iconSize: 18,
              tooltip: 'Cancel upload',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Uploading...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              '${(progress.progress * 100).toInt()}%',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[600],
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              progress.errorMessage ?? 'Upload failed',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon() {
    if (progress.hasError) {
      return Icons.error_outline;
    }
    if (progress.isCompleted) {
      return Icons.image;
    }
    if (progress.isInProgress) {
      return Icons.cloud_upload;
    }
    return Icons.image;
  }

  Color _getStatusColor(BuildContext context) {
    if (progress.hasError) {
      return Colors.red[600]!;
    }
    if (progress.isCompleted) {
      return Colors.green[600]!;
    }
    if (progress.isInProgress) {
      return Theme.of(context).primaryColor;
    }
    return Colors.grey[600]!;
  }
}

// Widget for displaying multiple upload progress items
class UploadProgressList extends StatelessWidget {
  final List<UploadProgress> progressList;
  final Function(String fileId)? onCancel;
  final Function(String fileId)? onRetry;
  final bool showOverallProgress;
  final EdgeInsets? padding;
  final double? maxHeight;

  const UploadProgressList({
    super.key,
    required this.progressList,
    this.onCancel,
    this.onRetry,
    this.showOverallProgress = true,
    this.padding,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (progressList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      constraints: maxHeight != null ? BoxConstraints(maxHeight: maxHeight!) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall progress header
          if (showOverallProgress) ...[
            _buildOverallProgressHeader(context),
            const SizedBox(height: 16),
          ],

          // Progress items list
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: progressList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final progress = progressList[index];
                return UploadProgressIndicator(
                  progress: progress,
                  onCancel: onCancel != null ? () => onCancel!(progress.fileId) : null,
                  onRetry: onRetry != null ? () => onRetry!(progress.fileId) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgressHeader(BuildContext context) {
    final totalFiles = progressList.length;
    final completedFiles = progressList.where((p) => p.isCompleted && !p.hasError).length;
    final failedFiles = progressList.where((p) => p.hasError).length;
    final inProgressFiles = progressList.where((p) => p.isInProgress).length;

    final overallProgress = progressList.isEmpty
        ? 0.0
        : progressList.fold<double>(0.0, (sum, p) => sum + p.progress) / progressList.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upload Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$completedFiles of $totalFiles completed',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: overallProgress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (inProgressFiles > 0) ...[
              Text(
                '$inProgressFiles uploading',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
            if (failedFiles > 0) ...[
              if (inProgressFiles > 0) const Text(' • '),
              Text(
                '$failedFiles failed',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}