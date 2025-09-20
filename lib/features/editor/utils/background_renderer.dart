import 'package:flutter/material.dart';
import '../models/background_models.dart';

class BackgroundRenderer {
  static BoxDecoration renderBackground(ScreenBackground background) {
    switch (background.type) {
      case BackgroundType.solid:
        return BoxDecoration(
          color: background.solidColor ?? Colors.white,
        );
      
      case BackgroundType.gradient:
        return BoxDecoration(
          gradient: background.gradient ?? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white],
          ),
        );
      
      case BackgroundType.image:
        if (background.imageUrl != null) {
          return BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(background.imageUrl!),
              fit: BoxFit.cover,
            ),
          );
        }
        // Fallback to white if no image URL
        return const BoxDecoration(
          color: Colors.white,
        );
    }
  }

  static Widget renderBackgroundWidget(ScreenBackground background, {
    required double width,
    required double height,
    Widget? child,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: renderBackground(background).copyWith(
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }

  static Color getBackgroundDisplayColor(ScreenBackground background) {
    switch (background.type) {
      case BackgroundType.solid:
        return background.solidColor ?? Colors.white;
      
      case BackgroundType.gradient:
        if (background.gradient != null && background.gradient!.colors.isNotEmpty) {
          // Return the first color for display purposes
          return background.gradient!.colors.first;
        }
        return Colors.white;
      
      case BackgroundType.image:
        // Return a generic color for image backgrounds
        return Colors.grey.shade300;
    }
  }

  static String getBackgroundDisplayText(ScreenBackground background) {
    switch (background.type) {
      case BackgroundType.solid:
        return 'Solid Color';
      
      case BackgroundType.gradient:
        return 'Gradient';
      
      case BackgroundType.image:
        return background.imageUrl != null ? 'Image Background' : 'No Image';
    }
  }

  static LinearGradient createGradient({
    required Color startColor,
    required Color endColor,
    String direction = 'vertical',
  }) {
    switch (direction) {
      case 'horizontal':
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [startColor, endColor],
        );
      case 'diagonal':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        );
      case 'vertical':
      default:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [startColor, endColor],
        );
    }
  }

  static ScreenBackground createSolidBackground(Color color) {
    return ScreenBackground(
      type: BackgroundType.solid,
      solidColor: color,
    );
  }

  static ScreenBackground createGradientBackground({
    required Color startColor,
    required Color endColor,
    String direction = 'vertical',
  }) {
    return ScreenBackground(
      type: BackgroundType.gradient,
      gradient: createGradient(
        startColor: startColor,
        endColor: endColor,
        direction: direction,
      ),
    );
  }

  static ScreenBackground createImageBackground({
    required String imageUrl,
    String? imageId,
  }) {
    return ScreenBackground(
      type: BackgroundType.image,
      imageUrl: imageUrl,
      imageId: imageId,
    );
  }
}