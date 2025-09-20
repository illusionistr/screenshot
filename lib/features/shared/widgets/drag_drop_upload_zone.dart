import 'dart:html' as html;

import 'package:flutter/material.dart';

import '../services/file_validation_service.dart';

class DragDropUploadZone extends StatefulWidget {
  final Function(List<html.File>) onFilesDropped;
  final Function()? onTap;
  final String? title;
  final String? subtitle;
  final Widget? icon;
  final bool allowMultiple;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? dragOverColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final bool enabled;

  const DragDropUploadZone({
    super.key,
    required this.onFilesDropped,
    this.onTap,
    this.title,
    this.subtitle,
    this.icon,
    this.allowMultiple = true,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderColor,
    this.dragOverColor,
    this.borderRadius,
    this.padding,
    this.titleStyle,
    this.subtitleStyle,
    this.enabled = true,
  });

  @override
  State<DragDropUploadZone> createState() => _DragDropUploadZoneState();
}

class _DragDropUploadZoneState extends State<DragDropUploadZone> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? Colors.grey[50]!;
    final borderColor = widget.borderColor ?? Colors.grey[300]!;
    final dragOverColor = widget.dragOverColor ?? theme.primaryColor.withOpacity(0.1);

    return GestureDetector(
      onTap: widget.enabled ? _handleTap : null,
      child: Container(
        height: widget.height,
        width: widget.width,
        padding: widget.padding ?? const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _isDragOver ? dragOverColor : backgroundColor,
          border: Border.all(
            color: _isDragOver ? theme.primaryColor : borderColor,
            width: _isDragOver ? 2 : 1,
            style: BorderStyle.solid,
          ),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        ),
        child: _buildUploadZoneContent(theme),
      ),
    );
  }

  Widget _buildUploadZoneContent(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        widget.icon ??
            Icon(
              _isDragOver ? Icons.file_upload : Icons.cloud_upload_outlined,
              size: 48,
              color: _isDragOver ? theme.primaryColor : Colors.grey[400],
            ),

        const SizedBox(height: 16),

        // Title
        Text(
          widget.title ?? (_isDragOver ? 'Drop files here' : 'Drag & drop files here'),
          style: widget.titleStyle ??
              TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _isDragOver ? theme.primaryColor : Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          widget.subtitle ?? 'or click to browse files',
          style: widget.subtitleStyle ??
              TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // File type info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'PNG, JPG, JPEG • Max 10MB',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  void _handleTap() {
    if (!widget.enabled) return;

    final input = html.FileUploadInputElement();
    input.accept = '.png,.jpg,.jpeg,image/png,image/jpeg';
    input.multiple = widget.allowMultiple;

    input.onChange.listen((event) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        _handleFiles(files);
      }
    });

    input.click();
  }

  void _handleFiles(List<html.File> files) {
    final validFiles = <html.File>[];
    final errors = <String>[];

    for (final file in files) {
      final validation = FileValidationService.validateFile(file);
      if (validation.isValid) {
        validFiles.add(file);
      } else {
        errors.addAll(validation.errors);
      }
    }

    if (validFiles.isNotEmpty) {
      widget.onFilesDropped(validFiles);
    }

    if (errors.isNotEmpty) {
      _showValidationErrors(errors);
    }
  }

  void _showValidationErrors(List<String> errors) {
    final messenger = ScaffoldMessenger.of(context);
    for (final error in errors.take(3)) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _setupDragAndDrop();
  }

  void _setupDragAndDrop() {
    // Add drag and drop event listeners to the document
    html.document.addEventListener('dragover', _onDragOver);
    html.document.addEventListener('drop', _onDrop);
    html.document.addEventListener('dragenter', _onDragEnter);
    html.document.addEventListener('dragleave', _onDragLeave);
  }

  void _onDragOver(html.Event event) {
    event.preventDefault();
    if (!_isDragOver) {
      setState(() {
        _isDragOver = true;
      });
    }
  }

  void _onDragEnter(html.Event event) {
    event.preventDefault();
    setState(() {
      _isDragOver = true;
    });
  }

  void _onDragLeave(html.Event event) {
    event.preventDefault();
    // Check if we're leaving the window entirely
    final dragEvent = event as dynamic;
    if (dragEvent.clientX == 0 && dragEvent.clientY == 0) {
      setState(() {
        _isDragOver = false;
      });
    }
  }

  void _onDrop(html.Event event) {
    event.preventDefault();
    setState(() {
      _isDragOver = false;
    });

    if (!widget.enabled) return;

    final dragEvent = event as dynamic;
    final files = dragEvent.dataTransfer?.files;
    if (files != null && files.isNotEmpty) {
      _handleFiles(files);
    }
  }

  @override
  void dispose() {
    // Remove event listeners
    html.document.removeEventListener('dragover', _onDragOver);
    html.document.removeEventListener('drop', _onDrop);
    html.document.removeEventListener('dragenter', _onDragEnter);
    html.document.removeEventListener('dragleave', _onDragLeave);
    super.dispose();
  }
}