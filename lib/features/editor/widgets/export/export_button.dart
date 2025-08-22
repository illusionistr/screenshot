import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/editor_state.dart';
import '../../models/export_models.dart';
import '../../services/client_export_service.dart';
import '../../../projects/models/project_model.dart';
import 'export_progress_dialog.dart';

class ExportButton extends ConsumerStatefulWidget {
  final EditorState editorState;
  final ProjectModel project;

  const ExportButton({
    super.key,
    required this.editorState,
    required this.project,
  });

  @override
  ConsumerState<ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends ConsumerState<ExportButton> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    // Check if there are any exportable screens
    final exportableScreens = ClientExportService.getExportableScreens(
      widget.editorState, 
      widget.project
    );
    final hasExportableScreens = exportableScreens.isNotEmpty;

    return Tooltip(
      message: hasExportableScreens 
          ? 'Export all screens as high-resolution images'
          : 'No screens with screenshots found for ${widget.editorState.selectedLanguage} + ${widget.editorState.selectedDevice}',
      child: ElevatedButton.icon(
        onPressed: hasExportableScreens && !_isExporting ? _handleExport : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasExportableScreens ? const Color(0xFF007BFF) : Colors.grey.shade400,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        icon: _isExporting 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.download, size: 16),
        label: Text(
          _isExporting ? 'Exporting...' : 'Export',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _handleExport() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Show progress dialog and start export
      final result = await ExportProgressDialog.show(
        context: context,
        editorState: widget.editorState,
        project: widget.project,
      );

      if (mounted) {
        // Show result dialog
        await _showResultDialog(result);
      }
    } catch (e) {
      if (mounted) {
        await _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _showResultDialog(ExportResult result) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.isSuccessful ? Icons.check_circle : Icons.error,
              color: result.isSuccessful ? Colors.green : Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result.isSuccessful ? 'Export Completed' : 'Export Failed',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.summaryMessage),
            if (result.totalFilesExported > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Files exported: ${result.totalFilesExported}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text('Total size: ${result.totalSizeFormatted}'),
              if (result.totalDuration != null)
                Text('Duration: ${_formatDuration(result.totalDuration!)}'),
            ],
            if (result.hasSkippedScreens) ...[
              const SizedBox(height: 12),
              Text(
                'Skipped screens: ${result.skippedScreens.length}',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (result.hasErrors) ...[
              const SizedBox(height: 12),
              Text(
                'Errors: ${result.errors.length}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              for (final error in result.errors.take(3))
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    '• $error',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              if (result.errors.length > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    '• ... and ${result.errors.length - 3} more',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(String error) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Export Error'),
          ],
        ),
        content: Text('Failed to start export: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '${minutes}m ${seconds}s';
    }
  }
}