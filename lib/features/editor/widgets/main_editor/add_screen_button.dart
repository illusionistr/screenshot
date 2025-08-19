import 'package:flutter/material.dart';
import '../../utils/platform_dimension_calculator.dart';

class AddScreenButton extends StatelessWidget {
  final String deviceId;
  final bool isLandscape;
  final VoidCallback? onPressed;
  final int currentScreenCount;
  final int maxScreens;

  const AddScreenButton({
    super.key,
    required this.deviceId,
    this.isLandscape = false,
    this.onPressed,
    this.currentScreenCount = 0,
    this.maxScreens = 10,
  });

  @override
  Widget build(BuildContext context) {
    final containerSize = PlatformDimensionCalculator.calculateContainerSize(
      deviceId,
      isLandscape: isLandscape,
    );

    final isDisabled = currentScreenCount >= maxScreens;

    return Container(
      width: containerSize.width,
      height: containerSize.height,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey.shade100 : Colors.grey.shade50,
              border: Border.all(
                color: isDisabled ? Colors.grey.shade300 : Colors.grey.shade400,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: DashedBorderPainter(
                      color: isDisabled ? Colors.grey.shade300 : Colors.grey.shade400,
                      strokeWidth: 2,
                      dashLength: 8,
                      gapLength: 6,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDisabled 
                            ? Colors.grey.shade300 
                            : Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 40,
                          color: isDisabled ? Colors.grey.shade500 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Add Screenshot Layout',
                        style: TextStyle(
                          color: isDisabled ? Colors.grey.shade500 : Colors.grey.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDisabled 
                            ? Colors.grey.shade300 
                            : Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isDisabled ? 'MAX REACHED' : 'ADD',
                          style: TextStyle(
                            color: isDisabled ? Colors.grey.shade600 : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      if (!isDisabled) ...[
                        const SizedBox(height: 12),
                        Text(
                          '$currentScreenCount/$maxScreens screens',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, 
                     size.width - strokeWidth, size.height - strokeWidth),
        const Radius.circular(8),
      ));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final dashPath = pathMetric.extractPath(
          distance,
          distance + dashLength,
        );
        canvas.drawPath(dashPath, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}