import 'package:flutter/material.dart';
import '../../utils/platform_dimension_calculator.dart';

class ScreenExpandModal extends StatelessWidget {
  final String screenId;
  final String deviceId;
  final bool isLandscape;
  final Widget? child;

  const ScreenExpandModal({
    super.key,
    required this.screenId,
    required this.deviceId,
    this.isLandscape = false,
    this.child,
  });

  static void show(
    BuildContext context, {
    required String screenId,
    required String deviceId,
    bool isLandscape = false,
    Widget? child,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ScreenExpandModal(
        screenId: screenId,
        deviceId: deviceId,
        isLandscape: isLandscape,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxModalHeight = screenSize.height * 0.85;
    final maxModalWidth = screenSize.width * 0.9;

    final containerSize = PlatformDimensionCalculator.calculateSizeForConstraints(
      deviceId: deviceId,
      maxHeight: maxModalHeight,
      maxWidth: maxModalWidth,
      isLandscape: isLandscape,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: containerSize.width + 40,
          maxHeight: containerSize.height + 80,
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: containerSize.width,
                height: containerSize.height,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: child ?? _buildPlaceholderContent(),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Screen ID: $screenId',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          PlatformDimensionCalculator.getDimensionDisplayText(
                            deviceId, 
                            isLandscape: isLandscape,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smartphone,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Expanded View',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Screenshot Layout Preview',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            PlatformDimensionCalculator.getDimensionDisplayText(deviceId, isLandscape: isLandscape),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}