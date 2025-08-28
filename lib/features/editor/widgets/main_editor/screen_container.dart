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

class ScreenContainer extends StatelessWidget {
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
  final VoidCallback? onTap;
  final VoidCallback? onReorder;
  final VoidCallback? onExpand;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final bool showDeleteButton;
  final Widget? child;

  const ScreenContainer({
    super.key,
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
    this.onTap,
    this.onReorder,
    this.onExpand,
    this.onDuplicate,
    this.onDelete,
    this.showDeleteButton = true,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final containerSize = PlatformDimensionCalculator.calculateContainerSize(
      deviceId,
      isLandscape: isLandscape,
    );

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
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
                if (textConfig != null)
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      child: _buildTextOverlay(
                        textConfig!,
                        Size(
                          containerSize.width - 32, // Account for margins
                          containerSize.height - 32,
                        ),
                      ),
                    ),
                  ),

                // Selection indicator
                if (isSelected)
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
        ScreenManagementButtons(
          onReorder: onReorder,
          onExpand: onExpand,
          onDuplicate: onDuplicate,
          onDelete: onDelete,
          showDeleteButton: showDeleteButton,
        ),
      ],
    );
  }

  Widget _buildFrameWithContent() {
    final containerSize = PlatformDimensionCalculator.calculateContainerSize(
      deviceId,
      isLandscape: isLandscape,
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
      child: child ?? _buildContentPlaceholder(),
    );
  }

  BoxDecoration _getMainContainerDecoration(BuildContext context) {
    // Base decoration with border and border radius
    final baseDecoration = BoxDecoration(
      border: Border.all(
        color:
            isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
    );

    if (background == null) {
      return baseDecoration.copyWith(color: Colors.grey.shade50);
    }

    // Use BackgroundRenderer to get the proper decoration and combine with border
    final backgroundDecoration =
        BackgroundRenderer.renderBackground(background!);

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
            assignedScreenshot != null
                ? Icons.image_outlined
                : Icons.smartphone,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            assignedScreenshot != null ? 'Screenshot' : 'No Screenshot',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            assignedScreenshot != null
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
    // Get the layout configuration (will always return a valid layout)
    final config = LayoutsData.getLayoutConfigOrDefault(layoutId);
    // Calculate device frame position and size based on layout
    final devicePosition =
        LayoutRenderer.calculateDevicePosition(config, frameSize);
    final deviceSize = LayoutRenderer.calculateDeviceSize(
      config,
      frameSize,
      deviceId: deviceId,
      isLandscape: isLandscape,
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
            angle: config.deviceRotation *
                3.14159 /
                180, // Convert degrees to radians
            child: FutureBuilder<Widget>(
              future: FrameRenderer.buildSmartFrameContainer(
                deviceId: deviceId,
                containerSize: deviceSize,
                selectedVariantId:
                    frameVariant.isNotEmpty ? frameVariant : null,
                screenshotPath: assignedScreenshot?.storageUrl,
                screenshotWidget: assignedScreenshot?.storageUrl != null
                    ? Image.network(
                        assignedScreenshot!.storageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return placeholderContent;
                        },
                      )
                    : null,
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
                    child: placeholderContent,
                    containerSize: deviceSize,
                    deviceId: deviceId,
                  );
                }

                return snapshot.data ??
                    FrameRenderer.renderGenericFrame(
                      child: placeholderContent,
                      containerSize: deviceSize,
                      deviceId: deviceId,
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
    // Use interactive text overlay if project is available
    if (project != null) {
      return TextRenderer.renderInteractiveTextOverlay(
        textConfig: textConfig,
        containerSize: containerSize,
        project: project!,
        scaleFactor: 0.7, // Scale down for preview
      );
    }

    // Fall back to static text overlay
    return TextRenderer.renderTextOverlay(
      textConfig: textConfig,
      containerSize: containerSize,
      scaleFactor: 0.7, // Scale down for preview
    );
  }
}
