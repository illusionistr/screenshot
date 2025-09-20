import 'package:flutter/material.dart';

import '../../../projects/models/project_model.dart';
import '../../../shared/models/screenshot_model.dart';
import '../../constants/layouts_data.dart';
import '../../models/background_models.dart';
import '../../models/layout_models.dart';
import '../../models/text_models.dart' as text_models;
import '../../utils/background_renderer.dart';
import '../../utils/frame_renderer.dart';
import '../../utils/layout_renderer.dart';
import '../../utils/platform_dimension_calculator.dart';
import '../../utils/text_renderer.dart';
import 'screen_management_buttons.dart';
import '../../services/export_service.dart';
import '../../models/positioning_models.dart';

class ScreenContainer extends StatefulWidget {
  final String screenId;
  final String deviceId;
  final bool isSelected;
  final bool isLandscape;
  final ScreenBackground? background;
  final text_models.ScreenTextConfig? textConfig;
  final ScreenshotModel? assignedScreenshot;
  final String layoutId;
  final String frameVariant;
  final ProjectModel? project;
  final Map<String, dynamic>? customSettings;
  final VoidCallback? onTap;
  final VoidCallback? onReorder;
  final VoidCallback? onExpand;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final bool showDeleteButton;
  final Widget? child;

  ScreenContainer({
    Key? key,
    required this.screenId,
    required this.deviceId,
    this.isSelected = false,
    this.isLandscape = false,
    this.background,
    this.textConfig,
    this.assignedScreenshot,
    required this.layoutId,
    this.frameVariant = 'real',
    this.project,
    this.customSettings,
    this.onTap,
    this.onReorder,
    this.onExpand,
    this.onDuplicate,
    this.onDelete,
    this.showDeleteButton = true,
    this.child,
  }) : super(key: key);

  @override
  State<ScreenContainer> createState() => _ScreenContainerState();
}

class _ScreenContainerState extends State<ScreenContainer> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _exporting = false;

  Future<void> _handleExport() async {
    try {
      setState(() => _exporting = true);
      // Wait for the frame where selection/UI overlays are hidden
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 16));

      await ExportService.exportScreenAsPng(
        repaintBoundaryKey: _repaintKey,
        deviceId: widget.deviceId,
        isLandscape: widget.isLandscape,
        filename: '${widget.project?.appName ?? 'screen'}_${widget.screenId}.png',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export started')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final containerSize = PlatformDimensionCalculator.calculateContainerSize(
      widget.deviceId,
      isLandscape: widget.isLandscape,
    );

    return Column(
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: RepaintBoundary(
            key: _repaintKey,
            child: Container(
              width: containerSize.width,
              height: containerSize.height,
              decoration: _getMainContainerDecoration(context),
              child: Stack(
                children: [
                  // Frame and screenshot layer
                  Positioned.fill(
                    child: Container(
                      child: _buildFrameWithContent(),
                    ),
                  ),

                  // Text overlay layer
                  if (widget.textConfig != null)
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        child: _buildTextOverlay(
                          widget.textConfig!,
                          Size(
                            containerSize.width - 32, // Account for margins
                            containerSize.height - 32,
                          ),
                        ),
                      ),
                    ),

                  // Selection indicator (hidden during export)
                  if (widget.isSelected && !_exporting)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Selected',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        ScreenManagementButtons(
          onReorder: widget.onReorder,
          onExpand: widget.onExpand,
          onDuplicate: widget.onDuplicate,
          onDelete: widget.onDelete,
          onExport: _handleExport,
          showDeleteButton: widget.showDeleteButton,
        ),
      ],
    );
  }

  Widget _buildFrameWithContent() {
    final containerSize = PlatformDimensionCalculator.calculateContainerSize(
      widget.deviceId,
      isLandscape: widget.isLandscape,
    );

    final frameSize = Size(
      containerSize.width, // Account for margins
      containerSize.height,
    );

    // Create the placeholder content that goes inside the frame
    final Widget placeholderContent = _buildPlaceholderFrameContent();

    // Always use layout-aware frame rendering since we now guarantee a layout
    return _buildLayoutAwareFrame(
      frameSize: frameSize,
      placeholderContent: placeholderContent,
    );
  }

  Widget _buildPlaceholderFrameContent() {
    // Always show background with placeholder - let FrameRenderer handle the screenshot
    return Container(
      decoration: _getBackgroundDecoration(),
      child: widget.child ?? _buildContentPlaceholder(),
    );
  }

  BoxDecoration _getMainContainerDecoration(BuildContext context) {
    // Base decoration with border and border radius
    // During export, hide any editor borders entirely so they don't appear
    // in the final PNG. In the editor UI, keep a subtle grey border and
    // highlight selection.
    final bool exporting = _exporting;
    final bool selected = widget.isSelected && !exporting;

    final baseDecoration = BoxDecoration(
      border: Border.all(
        color: exporting
            ? Colors.transparent
            : (selected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300),
        width: exporting
            ? 0
            : (selected ? 2 : 1),
      ),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
    );

    if (widget.background == null) {
      return baseDecoration.copyWith(color: Colors.grey.shade50);
    }

    // Use BackgroundRenderer to get the proper decoration and combine with border
    final backgroundDecoration =
        BackgroundRenderer.renderBackground(widget.background!);

    return baseDecoration.copyWith(
      color: backgroundDecoration.color,
      gradient: backgroundDecoration.gradient,
      image: backgroundDecoration.image,
    );
  }

  BoxDecoration _getBackgroundDecoration() {
    // This method is no longer used for main container background
    // Keep for frame content if needed, but should be transparent
    return const BoxDecoration(
      color: Colors.transparent,
    );
  }

  Widget _buildContentPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.assignedScreenshot != null
                ? Icons.image_outlined
                : Icons.smartphone,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            widget.assignedScreenshot != null ? 'Screenshot' : 'No Screenshot',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.assignedScreenshot != null
                ? 'Tap to select different screenshot'
                : 'Select screen then pick a screenshot',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutAwareFrame({
    required Size frameSize,
    required Widget placeholderContent,
  }) {
    // Get the base layout configuration and apply transform overrides if any
    final baseConfig = LayoutsData.getLayoutConfigOrDefault(widget.layoutId);
    final config = _applyTransformOverrides(baseConfig, widget.customSettings);
    // Calculate device frame position and size based on layout
    final devicePosition =
        LayoutRenderer.calculateDevicePosition(config, frameSize);
    final deviceSize = LayoutRenderer.calculateDeviceSize(
      config,
      frameSize,
      deviceId: widget.deviceId,
      isLandscape: widget.isLandscape,
    );

    return Stack(
      children: [
        // Background content
        // Positioned.fill(child: placeholderContent),

        // Device frame with screenshot - now using real/generic frames
        Positioned(
          left: devicePosition.dx - deviceSize.width / 2,
          top: devicePosition.dy - deviceSize.height / 2,
          child: Transform.rotate(
            angle: LayoutRenderer.getDeviceRotationDegrees(config) *
                3.14159 /
                180, // Convert degrees to radians
            child: FutureBuilder<Widget>(
              future: FrameRenderer.buildSmartFrameContainer(
                deviceId: widget.deviceId,
                containerSize: deviceSize,
                selectedVariantId:
                    widget.frameVariant.isNotEmpty ? widget.frameVariant : null,
                screenshotPath: widget.assignedScreenshot?.storageUrl,
                placeholder: placeholderContent,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: deviceSize.width,
                    height: deviceSize.height,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  // Fallback to generic frame on error
                  return FrameRenderer.renderGenericFrame(
                    content: placeholderContent,
                    containerSize: deviceSize,
                    deviceId: widget.deviceId,
                  );
                }

                return snapshot.data ??
                    FrameRenderer.renderGenericFrame(
                      content: placeholderContent,
                      containerSize: deviceSize,
                      deviceId: widget.deviceId,
                    );
              },
            ),
          ),
        ),

        // Title text overlay
        if (config.titlePosition == TextPosition.overlay)
          Positioned(
            left: devicePosition.dx - deviceSize.width / 2,
            top: devicePosition.dy - deviceSize.height / 2,
            child: Container(
              width: deviceSize.width,
              height: deviceSize.height,
              alignment: Alignment.center,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Title',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextOverlay(
      text_models.ScreenTextConfig textConfig, Size containerSize) {
    final baseConfig = LayoutsData.getLayoutConfigOrDefault(widget.layoutId);
    final config = _applyTransformOverrides(baseConfig, widget.customSettings);
    // During export, render non-interactive overlay to avoid selection UI
    if (_exporting || widget.project == null) {
      return TextRenderer.renderTextOverlay(
        textConfig: textConfig,
        containerSize: containerSize,
        scaleFactor: 0.7,
        layout: config,
      );
    }

    // Interactive overlay for editing
    return TextRenderer.renderInteractiveTextOverlay(
      textConfig: textConfig,
      containerSize: containerSize,
      project: widget.project!,
      scaleFactor: 0.7,
      layout: config,
    );
  }

  LayoutConfig _applyTransformOverrides(
      LayoutConfig config, Map<String, dynamic>? settings) {
    if (settings == null) return config;

    ElementTransform? parse(dynamic v) {
      if (v is Map<String, dynamic>) return ElementTransform.fromJson(v);
      if (v is Map) return ElementTransform.fromJson(Map<String, dynamic>.from(v));
      return null;
    }

    final dev = parse(settings['deviceTransform']);
    final title = parse(settings['titleTransform']);
    final sub = parse(settings['subtitleTransform']);
    if (dev == null && title == null && sub == null) return config;
    return config.copyWith(
      deviceTransform: dev ?? config.deviceTransform,
      titleTransform: title ?? config.titleTransform,
      subtitleTransform: sub ?? config.subtitleTransform,
    );
  }
}
