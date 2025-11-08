import 'package:flutter/material.dart';

import '../../../projects/models/project_model.dart';
import '../../../shared/models/screenshot_model.dart';
import '../../utils/background_renderer.dart';
import '../../utils/frame_renderer.dart';
import '../../utils/layout_renderer.dart';
import '../../utils/platform_dimension_calculator.dart';
import '../../models/text_models.dart' as text_models;
import '../../constants/layouts_data.dart';
import '../../models/background_models.dart';
import '../../models/layout_models.dart';
import '../../utils/text_renderer.dart';
import '../../models/positioning_models.dart';

/// Non-interactive export-only view that mirrors ScreenContainer visuals
class ExportScreenView extends StatelessWidget {
  final String deviceId;
  final bool isLandscape;
  final ScreenBackground? background;
  final text_models.ScreenTextConfig? textConfig;
  final ScreenshotModel? assignedScreenshot;
  final String layoutId;
  final String frameVariant;
  final ProjectModel? project;
  final Map<String, dynamic>? customSettings;
  final String currentLanguage;

  const ExportScreenView({
    super.key,
    required this.deviceId,
    required this.isLandscape,
    this.background,
    this.textConfig,
    this.assignedScreenshot,
    required this.layoutId,
    this.frameVariant = 'real',
    this.project,
    this.customSettings,
    this.currentLanguage = 'en',
  });

  @override
  Widget build(BuildContext context) {
    final containerSize = PlatformDimensionCalculator.calculateContainerSize(
      deviceId,
      isLandscape: isLandscape,
    );
    final baseConfig = LayoutsData.getLayoutConfigOrDefault(layoutId);
    final config = _applyTransformOverrides(baseConfig, customSettings, deviceId);

    return Container(
      width: containerSize.width,
      height: containerSize.height,
      decoration: _getMainContainerDecoration(),
      child: Stack(
        children: [
          // Frame and screenshot layer
          Positioned.fill(
            child: _buildFrameWithContent(),
          ),

          // Text overlay layer (non-interactive)
          if (textConfig != null)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: TextRenderer.renderTextOverlay(
                  textConfig: textConfig!,
                  containerSize: Size(
                    containerSize.width - 32,
                    containerSize.height - 32,
                  ),
                  currentLanguage: currentLanguage,
                  scaleFactor: 0.7,
                  layout: config,
                ),
              ),
            ),
        ],
      ),
    );
  }

  BoxDecoration _getMainContainerDecoration() {
    // No border in export view - we want the background to fill the entire image
    final baseDecoration = BoxDecoration(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
    );

    if (background == null) {
      return baseDecoration.copyWith(color: Colors.grey.shade50);
    }

    final backgroundDecoration = BackgroundRenderer.renderBackground(background!);
    return baseDecoration.copyWith(
      color: backgroundDecoration.color,
      gradient: backgroundDecoration.gradient,
      image: backgroundDecoration.image,
    );
  }

  Widget _buildFrameWithContent() {
    final containerSize = PlatformDimensionCalculator.calculateContainerSize(
      deviceId,
      isLandscape: isLandscape,
    );

    final frameSize = Size(
      containerSize.width,
      containerSize.height,
    );

    final placeholderContent = Container(
      decoration: const BoxDecoration(color: Colors.transparent),
    );

    return _buildLayoutAwareFrame(
      frameSize: frameSize,
      placeholderContent: placeholderContent,
    );
  }

  Widget _buildLayoutAwareFrame({
    required Size frameSize,
    required Widget placeholderContent,
  }) {
    final baseConfig = LayoutsData.getLayoutConfigOrDefault(layoutId);
    final config = _applyTransformOverrides(baseConfig, customSettings, deviceId);
    final devicePosition = LayoutRenderer.calculateDevicePosition(config, frameSize);
    final deviceSize = LayoutRenderer.calculateDeviceSize(
      config,
      frameSize,
      deviceId: deviceId,
      isLandscape: isLandscape,
    );

    return Stack(
      children: [
        Positioned(
          left: devicePosition.dx - deviceSize.width / 2,
          top: devicePosition.dy - deviceSize.height / 2,
          child: Transform.rotate(
            angle: LayoutRenderer.getDeviceRotationDegrees(config) * 3.14159 / 180,
            child: FutureBuilder<Widget>(
              future: FrameRenderer.buildSmartFrameContainer(
                deviceId: deviceId,
                containerSize: deviceSize,
                selectedVariantId: frameVariant.isNotEmpty ? frameVariant : null,
                screenshotPath: assignedScreenshot?.storageUrl,
                placeholder: placeholderContent,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    width: deviceSize.width,
                    height: deviceSize.height,
                  );
                }

                if (snapshot.hasError) {
                  return FrameRenderer.renderGenericFrame(
                    content: placeholderContent,
                    containerSize: deviceSize,
                    deviceId: deviceId,
                  );
                }
                return snapshot.data ??
                    FrameRenderer.renderGenericFrame(
                      content: placeholderContent,
                      containerSize: deviceSize,
                      deviceId: deviceId,
                    );
              },
            ),
          ),
        ),
      ],
    );
  }
}

LayoutConfig _applyTransformOverrides(
    LayoutConfig config, Map<String, dynamic>? settings, String deviceId) {
  if (settings == null) return config;

  ElementTransform? parse(dynamic v) {
    if (v is Map<String, dynamic>) return ElementTransform.fromJson(v);
    if (v is Map) return ElementTransform.fromJson(Map<String, dynamic>.from(v));
    return null;
  }

  // Resolution order for device transform:
  // 1. Device-specific transform (deviceTransformsByDevice[deviceId])
  // 2. Default deviceTransform
  // 3. Layout's deviceTransform (config.deviceTransform)

  ElementTransform? deviceTransform;

  // Check for device-specific transform first
  if (settings.containsKey('deviceTransformsByDevice')) {
    final deviceTransforms = settings['deviceTransformsByDevice'];
    if (deviceTransforms is Map && deviceTransforms.containsKey(deviceId)) {
      deviceTransform = parse(deviceTransforms[deviceId]);
      if (deviceTransform != null) {
        print('[ExportScreenView] Using device-specific transform for $deviceId');
      }
    }
  }

  // Fall back to default deviceTransform if no device-specific found
  if (deviceTransform == null) {
    deviceTransform = parse(settings['deviceTransform']);
    if (deviceTransform != null) {
      print('[ExportScreenView] Using default deviceTransform for $deviceId');
    }
  }

  final title = parse(settings['titleTransform']);
  final sub = parse(settings['subtitleTransform']);
  if (deviceTransform == null && title == null && sub == null) return config;
  return config.copyWith(
    deviceTransform: deviceTransform ?? config.deviceTransform,
    titleTransform: title ?? config.titleTransform,
    subtitleTransform: sub ?? config.subtitleTransform,
  );
}

