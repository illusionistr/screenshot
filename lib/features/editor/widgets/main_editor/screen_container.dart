import 'package:flutter/material.dart';
import '../../models/background_models.dart';
import '../../utils/background_renderer.dart';
import '../../utils/platform_dimension_calculator.dart';
import 'screen_management_buttons.dart';

class ScreenContainer extends StatelessWidget {
  final String screenId;
  final String deviceId;
  final bool isSelected;
  final bool isLandscape;
  final ScreenBackground? background;
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
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: _getBackgroundDecoration(),
                    child: child ?? _buildPlaceholderContent(),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  BoxDecoration _getBackgroundDecoration() {
    final baseDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.grey.shade200),
    );

    if (background == null) {
      return baseDecoration.copyWith(color: Colors.white);
    }

    // Use BackgroundRenderer to get the proper decoration
    final backgroundDecoration = BackgroundRenderer.renderBackground(background!);
    
    // Merge with base decoration to preserve border and border radius
    return baseDecoration.copyWith(
      color: backgroundDecoration.color,
      gradient: backgroundDecoration.gradient,
      image: backgroundDecoration.image,
    );
  }

  Widget _buildPlaceholderContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smartphone,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Screenshot Layout',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            PlatformDimensionCalculator.getDimensionDisplayText(deviceId, isLandscape: isLandscape),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}