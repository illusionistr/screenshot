import 'package:flutter/material.dart';

import '../models/screenshot_model.dart';
import '../services/file_validation_service.dart';

class ScreenshotThumbnail extends StatefulWidget {
  final ScreenshotModel screenshot;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool showInfo;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const ScreenshotThumbnail({
    super.key,
    required this.screenshot,
    this.onDelete,
    this.onTap,
    this.showInfo = true,
    this.padding,
    this.borderRadius,
  });

  @override
  State<ScreenshotThumbnail> createState() => _ScreenshotThumbnailState();
}

class _ScreenshotThumbnailState extends State<ScreenshotThumbnail> {
  bool _isHovered = false;
  bool _isLoading = true;
  bool _hasError = false;

  BorderRadius get _borderRadius => widget.borderRadius ?? BorderRadius.circular(8);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: _borderRadius,
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: _borderRadius,
            child: Stack(
              children: [
                // Image
                if (!_hasError) ...[
                  Image.network(
                    widget.screenshot.storageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        });
                        return child;
                      }
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                            _hasError = true;
                          });
                        }
                      });
                      return Container();
                    },
                  ),
                ],

                // Error state
                if (_hasError) ...[
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[100],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 32,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Failed to load',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],

                // Loading overlay
                if (_isLoading) ...[
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ],

                // Hover overlay with actions
                if (_isHovered && !_isLoading) ...[
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Delete button
                        if (widget.onDelete != null) ...[
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: widget.onDelete,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 32),
                        ],

                        // File info
                        if (widget.showInfo) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.screenshot.originalFilename,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.screenshot.dimensions.width} × ${widget.screenshot.dimensions.height}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                  ),
                                ),
                                Text(
                                  FileValidationService.formatFileSize(widget.screenshot.fileSize),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}