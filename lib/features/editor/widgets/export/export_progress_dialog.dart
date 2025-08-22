import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/editor_state.dart';
import '../../models/export_models.dart';
import '../../services/client_export_service.dart';
import '../../../projects/models/project_model.dart';

class ExportProgressDialog extends StatefulWidget {
  final EditorState editorState;
  final ProjectModel project;

  const ExportProgressDialog({
    super.key,
    required this.editorState,
    required this.project,
  });

  static Future<ExportResult> show({
    required BuildContext context,
    required EditorState editorState,
    required ProjectModel project,
  }) async {
    final completer = Completer<ExportResult>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExportProgressDialog(
        editorState: editorState,
        project: project,
      ),
    ).then((_) {
      // Dialog was dismissed without completing - this shouldn't happen
      if (!completer.isCompleted) {
        completer.completeError('Export cancelled by user');
      }
    });

    // Start the export process
    try {
      final result = await ClientExportService.exportAllScreens(
        editorState: editorState,
        project: project,
        onProgress: (progress) {
          // Update the dialog state through a custom notification system
          _ExportProgressNotification(progress).dispatch(context);
        },
      );
      
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }

    return completer.future;
  }

  @override
  State<ExportProgressDialog> createState() => _ExportProgressDialogState();
}

class _ExportProgressDialogState extends State<ExportProgressDialog> {
  ExportProgress _progress = const ExportProgress(
    currentScreen: 0,
    totalScreens: 0,
    currentScreenId: '',
    currentScreenName: 'Initializing...',
    status: ExportStatus.pending,
  );

  @override
  Widget build(BuildContext context) {
    return NotificationListener<_ExportProgressNotification>(
      onNotification: (notification) {
        setState(() {
          _progress = notification.progress;
        });
        return true;
      },
      child: AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.download, color: Color(0xFF007BFF), size: 24),
            SizedBox(width: 8),
            Text('Exporting Screenshots'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status text
              Text(
                _getStatusText(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              // Current operation
              Text(
                _progress.currentScreenName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              
              // Progress bar
              if (_progress.totalScreens > 0) ...[
                LinearProgressIndicator(
                  value: _progress.progressPercentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007BFF)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_progress.currentScreen} of ${_progress.totalScreens} screens',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '${_progress.progressPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ] else ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
                const Text(
                  'Preparing export...',
                  style: TextStyle(fontSize: 12),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Status details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusRow('Project', widget.project.appName),
                    _buildStatusRow('Device', widget.editorState.selectedDevice),
                    _buildStatusRow('Language', widget.editorState.selectedLanguage),
                    if (_progress.totalScreens > 0)
                      _buildStatusRow('Total Screens', '${_progress.totalScreens}'),
                  ],
                ),
              ),
              
              // Error message
              if (_progress.errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade600, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _progress.errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (_progress.canCancel)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (_progress.status) {
      case ExportStatus.pending:
        return 'Preparing export...';
      case ExportStatus.validating:
        return 'Validating screens...';
      case ExportStatus.processing:
        return 'Processing screens...';
      case ExportStatus.completed:
        return 'Export completed!';
      case ExportStatus.failed:
        return 'Export failed';
      case ExportStatus.cancelled:
        return 'Export cancelled';
    }
  }
}

// Custom notification for updating progress
class _ExportProgressNotification extends Notification {
  final ExportProgress progress;

  const _ExportProgressNotification(this.progress);
}

