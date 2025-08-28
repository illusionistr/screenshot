import 'package:flutter/material.dart';

import '../../shared/models/device_model.dart';
import '../../shared/models/frame_variant_model.dart';
import '../../shared/services/device_service.dart';
import '../../shared/services/frame_asset_service.dart';

class FrameRenderer {
  FrameRenderer._();

  /// Enhanced frame container with asset validation and smart fallback
  static Future<Widget> buildSmartFrameContainer({
    required String deviceId,
    required Size containerSize,
    String? selectedVariantId,
    String? screenshotPath,
    Widget? screenshotWidget,
    Widget? placeholder,
  }) async {
    final device = DeviceService.getDeviceById(deviceId);
    if (device == null) {
      return Container(
        width: containerSize.width,
        height: containerSize.height,
        color: const Color(0xFFF8F9FA),
        child: const Center(
          child: Text('Device not found'),
        ),
      );
    }

    // Prepare content widget
    Widget content;
    if (screenshotWidget != null) {
      content = screenshotWidget;
    } else if (screenshotPath != null) {
      content = Container(
        width: containerSize.width,
        height: containerSize.height,
        color: const Color(0xFFF8F9FA), // Background color for any gaps
        child: Image.network(
          screenshotPath,
          width: containerSize.width,
          height: containerSize.height,
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            return placeholder ?? _buildDefaultScreenshotPlaceholder(device);
          },
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame == null) {
              return placeholder ?? _buildDefaultScreenshotPlaceholder(device);
            }

            // Return the image to fill the entire container
            return SizedBox(
              width: containerSize.width,
              height: containerSize.height,
              child: child,
            );
          },
        ),
      );
    } else {
      content = placeholder ?? _buildDefaultScreenshotPlaceholder(device);
    }

    // Get the best available frame variant
    FrameVariantModel? frameVariant;
    if (selectedVariantId != null && selectedVariantId.isNotEmpty) {
      frameVariant = await DeviceService.getFrameVariantWithFallback(
          deviceId, selectedVariantId);
    }
    frameVariant ??= await DeviceService.getDefaultFrameVariant(deviceId);

    // Render the appropriate frame
    if (frameVariant != null &&
        !frameVariant.isGeneric &&
        frameVariant.assetPath != null) {
      // Check if the asset is actually available
      final isAssetAvailable =
          await FrameAssetService.isFrameAssetAvailable(frameVariant.assetPath);
      if (isAssetAvailable) {
        return _renderRealFrame(
          assetPath: frameVariant.assetPath!,
          device: device,
          containerSize: containerSize,
          screenshotContent: content,
        );
      }
    }

    // Fallback to generic frame
    return renderGenericFrame(
      content: content,
      containerSize: containerSize,
      device: device,
    );
  }

  static Widget _renderRealFrame({
    required String assetPath,
    required DeviceModel device,
    required Size containerSize,
    required Widget screenshotContent,
  }) {
    // Calculate scale factors from original frame dimensions to container dimensions
    final scaleX = containerSize.width / device.frameWidth;
    final scaleY = containerSize.height / device.frameHeight;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Screenshot content positioned as background layer
        Positioned(
          // Scale the screen position coordinates by the scale factors
          left: device.screenPosition.dx * scaleX - 1,
          top: device.screenPosition.dy * scaleY - 1,
          // Scale the screen dimensions by the scale factors
          width: device.screenWidth * scaleX + 2,
          height: device.screenHeight * scaleY + 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0), // Adjust based on device
            child: _buildSmartFittingWidget(
              screenshotContent: screenshotContent,
              screenWidth: device.screenWidth * scaleX,
              screenHeight: device.screenHeight * scaleY,
            ),
          ),
        ),
        // Device frame on top (foreground layer)
        Image.asset(
          assetPath,
          width: containerSize.width,
          height: containerSize.height,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  /// Create a smart fitting widget for already-loaded screenshot content
  static Widget _buildSmartFittingWidget({
    required Widget screenshotContent,
    required double screenWidth,
    required double screenHeight,
  }) {
    // Wrap the already-loaded content in a container with smart background
    return Container(
      width: screenWidth,
      height: screenHeight,
      color:
          const Color(0xFFF8F9FA), // Light gray background for unfilled areas
      child: Center(
        child: screenshotContent,
      ),
    );
  }

  static Widget renderGenericFrame({
    required Widget content,
    required Size containerSize,
    DeviceModel? device,
    String? deviceId,
  }) {
    // Ensure we have a device - either passed directly or looked up
    DeviceModel? targetDevice = device;
    if (targetDevice == null && deviceId != null) {
      targetDevice = DeviceService.getDeviceById(deviceId);
    }

    if (targetDevice == null) {
      return content;
    }

    // Simple, clean frame with border/outline - not invisible
    return Container(
      width: containerSize.width,
      height: containerSize.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(targetDevice.isTablet ? 24 : 23),
        color: Colors.red,
        border: Border.all(
          color: Colors.black,
          width: 5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
       // borderRadius: BorderRadius.circular(targetDevice.isTablet ? 19 : 15),
        child: content,
      ),
    );
  }

  static Widget _buildDefaultScreenshotPlaceholder(DeviceModel device) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF8F9FA),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_outlined,
            size: device.isTablet ? 48 : 32,
            color: const Color(0xFFADB5BD),
          ),
          const SizedBox(height: 8),
          Text(
            'No screenshot\nassigned',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: device.isTablet ? 14 : 12,
              color: const Color(0xFFADB5BD),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
