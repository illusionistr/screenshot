import 'package:flutter/material.dart';

import '../../shared/models/device_model.dart';
import '../../shared/models/frame_variant_model.dart';
import '../../shared/services/device_service.dart';
import '../../shared/services/frame_asset_service.dart';

class FrameRenderer {
  FrameRenderer._();

  static Widget renderGenericFrame({
    required Widget child,
    required Size containerSize,
    required String deviceId,
  }) {
    print(
        'DEBUG: renderGenericFrame called with containerSize: $containerSize, deviceId: $deviceId');
    final device = DeviceService.getDeviceById(deviceId);
    if (device == null) {
      return child;
    }

    // Simple, clean frame with border/outline - not invisible
    return Container(
      width: containerSize.width,
      height: containerSize.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(device.isTablet ? 24 : 20),
        color: Colors.transparent,
        border: Border.all(
          color: Colors.black,
          width: 5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(device.isTablet ? 19 : 15),
        child: child,
      ),
    );
  }

  static Future<Widget> renderFrameWithScreenshot({
    required String deviceId,
    required Size containerSize,
    String? screenshotPath,
    Widget? placeholder,
  }) async {
    final device = DeviceService.getDeviceById(deviceId);
    final frameVariant = await DeviceService.getDefaultFrameVariant(deviceId);
    print('Frame variant: $frameVariant');
    // If we have a real frame asset, try to use it
    if (frameVariant != null &&
        !frameVariant.isGeneric &&
        frameVariant.assetPath != null) {
      return _renderRealFrame(
        assetPath: frameVariant.assetPath!,
        device: device!,
        containerSize: containerSize,
        screenshotPath: screenshotPath,
        placeholder: placeholder,
      );
    }

    // Fallback to generic frame
    final content = screenshotPath != null
        ? Image.network(
            screenshotPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return placeholder ?? _buildDefaultScreenshotPlaceholder(device!);
            },
          )
        : placeholder ?? _buildDefaultScreenshotPlaceholder(device!);

    return renderGenericFrame(
      child: content,
      containerSize: containerSize,
      deviceId: deviceId,
    );
  }

  static Widget _renderRealFrame({
    required String assetPath,
    required DeviceModel device,
    required Size containerSize,
    String? screenshotPath,
    Widget? placeholder,
  }) {
    print('DEBUG _renderRealFrame: assetPath=$assetPath');

    // Calculate scale factors from original frame dimensions to container dimensions
    final scaleX = containerSize.width / device.frameWidth;
    final scaleY = containerSize.height / device.frameHeight;

    print(
        'DEBUG _renderRealFrame: Original frame=${device.frameWidth}x${device.frameHeight}, Container=${containerSize.width}x${containerSize.height}');
    print(
        'DEBUG _renderRealFrame: Scale factors: scaleX=$scaleX, scaleY=$scaleY');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Device frame
        Image.asset(
          assetPath,
          width: containerSize.width,
          height: containerSize.height,
          fit: BoxFit.cover,
          // errorBuilder: (context, error, stackTrace) {
          //   print('DEBUG _renderRealFrame: error=$error');
          //   // Fallback to generic frame if asset fails to load
          //   final content = screenshotPath != null
          //       ? Image.network(
          //           screenshotPath,
          //           fit: BoxFit.cover,
          //           errorBuilder: (context, error, stackTrace) {
          //             return placeholder ??
          //                 _buildDefaultScreenshotPlaceholder(device);
          //           },
          //         )
          //       : placeholder ?? _buildDefaultScreenshotPlaceholder(device);
          //   return renderGenericFrame(
          //     child: content,
          //     containerSize: containerSize,
          //     deviceId: device.id,
          //   );
          // },
        ),
        // Screenshot content positioned over device screen area
        if (screenshotPath != null || placeholder != null)
          Positioned(
            // Scale the screen position coordinates by the scale factors
            left: device.screenPosition.dx * scaleX,
            top: device.screenPosition.dy * scaleY,
            // Scale the screen dimensions by the scale factors
            width: device.screenWidth * scaleX,
            height: device.screenHeight * scaleY,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(8.0), // Adjust based on device
              child: screenshotPath != null
                  ? Image.network(
                      screenshotPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('DEBUG _renderRealFrame: error=$error');
                        return placeholder ??
                            _buildDefaultScreenshotPlaceholder(device);
                      },
                    )
                  : placeholder ?? _buildDefaultScreenshotPlaceholder(device),
            ),
          ),
      ],
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

  static Future<bool> shouldUseGenericFrame(
      String deviceId, String? variantId) async {
    if (variantId == null) {
      return !(await DeviceService.hasRealFrameVariants(deviceId));
    }

    final frameVariant = DeviceService.getFrameVariant(deviceId, variantId);
    return frameVariant?.isGeneric ?? true;
  }

  static Widget buildFrameContainer({
    required String deviceId,
    required Size containerSize,
    String? selectedVariantId,
    String? screenshotPath,
    Widget? screenshotWidget,
    Widget? placeholder,
  }) {
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
      content = Image.network(
        screenshotPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return placeholder ?? _buildDefaultScreenshotPlaceholder(device);
        },
      );
    } else {
      content = placeholder ?? _buildDefaultScreenshotPlaceholder(device);
    }

    // Use generic frame for now - will be enhanced in next phase
    return renderGenericFrame(
      child: content,
      containerSize: containerSize,
      deviceId: deviceId,
    );
  }

  /// Enhanced frame container with asset validation and smart fallback
  static Future<Widget> buildSmartFrameContainer({
    required String deviceId,
    required Size containerSize,
    String? selectedVariantId,
    String? screenshotPath,
    Widget? screenshotWidget,
    Widget? placeholder,
  }) async {
    print(
        'DEBUG buildSmartFrameContainer: deviceId=$deviceId, selectedVariantId=$selectedVariantId');

    final device = DeviceService.getDeviceById(deviceId);
    if (device == null) {
      print(
          'DEBUG buildSmartFrameContainer: Device not found for id=$deviceId');
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
      content = Image.network(
        screenshotPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return placeholder ?? _buildDefaultScreenshotPlaceholder(device);
        },
      );
    } else {
      content = placeholder ?? _buildDefaultScreenshotPlaceholder(device);
    }

    // Get the best available frame variant
    FrameVariantModel? frameVariant;
    if (selectedVariantId != null && selectedVariantId.isNotEmpty) {
      print(
          'DEBUG buildSmartFrameContainer: Getting frame variant for selectedVariantId=$selectedVariantId');
      frameVariant = await DeviceService.getFrameVariantWithFallback(
          deviceId, selectedVariantId);
    }
    frameVariant ??= await DeviceService.getDefaultFrameVariant(deviceId);

    print(
        'DEBUG buildSmartFrameContainer: frameVariant=${frameVariant?.id}, isGeneric=${frameVariant?.isGeneric}, assetPath=${frameVariant?.assetPath}');

    // Render the appropriate frame
    if (frameVariant != null &&
        !frameVariant.isGeneric &&
        frameVariant.assetPath != null) {
      print(
          'DEBUG buildSmartFrameContainer: Checking asset availability for ${frameVariant.assetPath}');
      // Check if the asset is actually available
      final isAssetAvailable =
          await FrameAssetService.isFrameAssetAvailable(frameVariant.assetPath);
      print(
          'DEBUG buildSmartFrameContainer: Asset available: $isAssetAvailable');
      if (isAssetAvailable) {
        print(
            'DEBUG buildSmartFrameContainer: Rendering real frame with asset ${frameVariant.assetPath}');
        return _renderRealFrame(
          assetPath: frameVariant.assetPath!,
          device: device,
          containerSize: containerSize,
          screenshotPath: screenshotPath,
          placeholder: content,
        );
      }
    }

    // Fallback to generic frame
    print('DEBUG buildSmartFrameContainer: Falling back to generic frame');
    return renderGenericFrame(
      child: content,
      containerSize: containerSize,
      deviceId: deviceId,
    );
  }
}
