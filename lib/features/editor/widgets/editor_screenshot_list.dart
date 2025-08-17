import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/models/project_model.dart';
import '../../shared/models/screenshot_model.dart';
import '../models/editor_state.dart';
import '../providers/editor_provider.dart';

class EditorScreenshotList extends ConsumerStatefulWidget {
  const EditorScreenshotList({
    super.key,
    required this.project,
    this.height = 200,
    this.onScreenshotTap,
    this.onScreenshotLongPress,
    this.onScreenshotReorder,
  });

  final ProjectModel project;
  final double height;
  final Function(ScreenshotModel)? onScreenshotTap;
  final Function(ScreenshotModel)? onScreenshotLongPress;
  final Function(int oldIndex, int newIndex)? onScreenshotReorder;

  @override
  ConsumerState<EditorScreenshotList> createState() => _EditorScreenshotListState();
}

class _EditorScreenshotListState extends ConsumerState<EditorScreenshotList> {
  final ScrollController _scrollController = ScrollController();
  bool _isDragMode = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProviderFamily(widget.project));
    final filteredScreenshots = _getFilteredScreenshots(editorState);

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E5E9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with controls
          _buildHeader(editorState, filteredScreenshots.length),
          
          // Screenshot list
          Expanded(
            child: filteredScreenshots.isEmpty
                ? _buildEmptyState()
                : _buildScreenshotList(filteredScreenshots),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(EditorState editorState, int screenshotCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE1E5E9)),
        ),
      ),
      child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title and count
          Row(
            children: [
              const Icon(
                Icons.photo_library_outlined,
                color: Color(0xFF6C757D),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Screenshots',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            
            
            ],
          ),
            Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$screenshotCount',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE91E63),
              ),
            ),
          ), 
         
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: const Color(0xFFE1E5E9),
          ),
          const SizedBox(height: 12),
          Text(
            'No screenshots available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6C757D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Upload screenshots or adjust filters',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotList(List<ScreenshotModel> screenshots) {
  
      return _buildScrollableList(screenshots);
  
  }

  Widget _buildScrollableList(List<ScreenshotModel> screenshots) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: screenshots.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final screenshot = screenshots[index];
            return _ScreenshotThumbnail(
              screenshot: screenshot,
              isSelected: false, // TODO: Implement selection state
              onTap: () => widget.onScreenshotTap?.call(screenshot),
              onLongPress: () => widget.onScreenshotLongPress?.call(screenshot),
              isDragMode: false,
            );
          },
        ),
      ),
    );
  }

  

  List<ScreenshotModel> _getFilteredScreenshots(EditorState editorState) {
    // Start with all project screenshots
    List<ScreenshotModel> allScreenshots = widget.project.getAllScreenshots();
    
    // Filter by selected device and language
    return allScreenshots.where((screenshot) {
      bool matchesDevice = true;
      bool matchesLanguage = true;
      
      if (editorState.selectedDevice.isNotEmpty) {
        matchesDevice = screenshot.deviceId == editorState.selectedDevice;
      }
      
      if (editorState.selectedLanguage.isNotEmpty) {
        matchesLanguage = screenshot.languageCode == editorState.selectedLanguage;
      }
      
      return matchesDevice && matchesLanguage;
    }).toList();
  }

  String _getFilterDisplayText(EditorState editorState) {
    final parts = <String>[];
    
    if (editorState.selectedDevice.isNotEmpty) {
      try {
        final device = editorState.availableDevices
            .firstWhere((d) => d.id == editorState.selectedDevice);
        parts.add(device.name);
      } catch (e) {
        parts.add(editorState.selectedDevice);
      }
    }
    
    if (editorState.selectedLanguage.isNotEmpty) {
      parts.add(editorState.selectedLanguage.toUpperCase());
    }
    
    return parts.join(' • ');
  }
}

class _ScreenshotThumbnail extends StatefulWidget {
  const _ScreenshotThumbnail({
    required this.screenshot,
    required this.isSelected,
    required this.isDragMode,
    this.onTap,
    this.onLongPress,
  });

  final ScreenshotModel screenshot;
  final bool isSelected;
  final bool isDragMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  State<_ScreenshotThumbnail> createState() => _ScreenshotThumbnailState();
}

class _ScreenshotThumbnailState extends State<_ScreenshotThumbnail>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isSelected
                        ? const Color(0xFFE91E63)
                        : (_isHovered ? const Color(0xFFE1E5E9) : Colors.transparent),
                    width: widget.isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    if (_isHovered)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      // Screenshot image
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: const Color(0xFFF5F5F5),
                        child: widget.screenshot.storageUrl.isNotEmpty
                            ? Image.network(
                                widget.screenshot.storageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholder();
                                },
                              )
                            : _buildPlaceholder(),
                      ),
                      
                      // Drag handle (only visible in drag mode)
                      if (widget.isDragMode)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.drag_indicator,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      
                      // Selection indicator
                      if (widget.isSelected)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      
                      // Metadata overlay (bottom)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Language code
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  widget.screenshot.languageCode.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              
                              // Device indicator
                              Icon(
                                Icons.smartphone,
                                color: Colors.white.withOpacity(0.9),
                                size: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            color: const Color(0xFFE1E5E9),
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            'Screenshot',
            style: TextStyle(
              fontSize: 10,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}