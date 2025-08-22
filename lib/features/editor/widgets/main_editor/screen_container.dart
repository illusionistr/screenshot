import 'package:flutter/material.dart';

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
  final String? layoutId;
  final String frameVariant;
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
    this.layoutId,
    this.frameVariant = 'real',
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
                    margin: const EdgeInsets.all(16),
                    child: _buildFrameWithContent(),
                  ),
                ),

                // Text overlay layer
                if (textConfig != null)
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      child: TextRenderer.renderTextOverlay(
                        textConfig: textConfig!,
                        containerSize: Size(
                          containerSize.width - 32, // Account for margins
                          containerSize.height - 32,
                        ),
                        scaleFactor: 0.7, // Scale down for preview
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
      containerSize.width - 32, // Account for margins
      containerSize.height - 32,
    );

    print('DEBUG ScreenContainer: _buildFrameWithContent called');
    print(
        'DEBUG ScreenContainer: assignedScreenshot != null: ${assignedScreenshot != null}');
    print(
        'DEBUG ScreenContainer: assignedScreenshot?.storageUrl: ${assignedScreenshot?.storageUrl}');
    print('DEBUG ScreenContainer: frameSize: $frameSize');
    print('DEBUG ScreenContainer: layoutId: $layoutId');
    print('DEBUG ScreenContainer: frameVariant: $frameVariant');

    // Create the content that goes inside the frame (background + screenshot)
    final Widget frameContent = _buildFrameContent();

    // Use layout-aware frame rendering if layout is specified
    if (layoutId != null) {
      return _buildLayoutAwareFrame(
        frameSize: frameSize,
        frameContent: frameContent,
      );
    }

    // Use the new smart frame container with asset validation
    return FutureBuilder<Widget>(
      future: FrameRenderer.buildSmartFrameContainer(
        deviceId: deviceId,
        containerSize: frameSize,
        selectedVariantId: frameVariant.isNotEmpty ? frameVariant : null,
        screenshotPath: assignedScreenshot?.storageUrl,
        placeholder: frameContent,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: frameSize.width,
            height: frameSize.height,
            color: Colors.grey.shade100,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          // Fallback to generic frame on error
          return FrameRenderer.buildFrameContainer(
            deviceId: deviceId,
            containerSize: frameSize,
            selectedVariantId:
                null, // Let the system choose the best available frame
            screenshotPath: assignedScreenshot?.storageUrl,
            placeholder: frameContent,
          );
        }

        return snapshot.data ?? frameContent;
      },
    );
  }

  Widget _buildFrameContent() {
    // Always show background with placeholder - let FrameRenderer handle the screenshot
    return Container(
      decoration: _getBackgroundDecoration(),
      child: child ?? _buildPlaceholderContent(),
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

  Widget _buildPlaceholderContent() {
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
    required Widget frameContent,
  }) {
    // Get the layout configuration
    final layout = LayoutsData.getLayoutById(layoutId!);
    if (layout == null) {
      // Fallback to regular frame if layout not found
      return FrameRenderer.buildFrameContainer(
        deviceId: deviceId,
        containerSize: frameSize,
        selectedVariantId: frameVariant,
        screenshotPath: assignedScreenshot?.storageUrl,
        placeholder: frameContent,
      );
    }

    final config = layout.config;

    // Calculate device frame position and size based on layout
    final devicePosition =
        LayoutRenderer.calculateDevicePosition(config, frameSize);
    final deviceSize = LayoutRenderer.calculateDeviceSize(config, frameSize);

    return Stack(
      children: [
        // Background content
        Positioned.fill(child: frameContent),

        // Device frame with screenshot
        Positioned(
          left: devicePosition.dx - deviceSize.width / 2,
          top: devicePosition.dy - deviceSize.height / 2,
          child: Transform.rotate(
            angle: config.deviceRotation *
                3.14159 /
                180, // Convert degrees to radians
            child: Container(
              width: deviceSize.width,
              height: deviceSize.height,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: assignedScreenshot?.storageUrl != null
                    ? Image.network(
                        assignedScreenshot!.storageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            frameContent,
                      )
                    : frameContent,
              ),
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
}
