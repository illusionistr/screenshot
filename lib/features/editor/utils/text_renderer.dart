import 'package:flutter/material.dart';
import '../models/text_models.dart';

class TextRenderer {
  /// Renders all text overlays for a screen
  static Widget renderTextOverlay({
    required ScreenTextConfig textConfig,
    required Size containerSize,
    double scaleFactor = 1.0,
  }) {
    final visibleElements = textConfig.visibleElements;
    
    if (visibleElements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: visibleElements.map((element) {
        return renderTextElement(
          element: element,
          containerSize: containerSize,
          scaleFactor: scaleFactor,
        );
      }).toList(),
    );
  }

  /// Renders a single text element with proper positioning
  static Widget renderTextElement({
    required TextElement element,
    required Size containerSize,
    double scaleFactor = 1.0,
  }) {
    final position = _getElementPosition(element.type, containerSize);
    final scaledFontSize = element.fontSize * scaleFactor;
    
    return Positioned(
      left: position.left,
      top: position.top,
      right: position.right,
      bottom: position.bottom,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scaleFactor,
          vertical: 8 * scaleFactor,
        ),
        child: Text(
          element.content,
          style: TextStyle(
            fontFamily: element.fontFamily,
            fontSize: scaledFontSize.clamp(8.0, 100.0), // Ensure reasonable bounds
            fontWeight: element.fontWeight,
            color: element.color,
            height: 1.2,
          ),
          textAlign: element.textAlign,
          maxLines: element.type == TextFieldType.title ? 3 : 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// Gets the position parameters for a text element type
  static _ElementPosition _getElementPosition(TextFieldType type, Size containerSize) {
    switch (type) {
      case TextFieldType.title:
        // Title: Top area (20% from top)
        return _ElementPosition(
          left: 0,
          top: containerSize.height * 0.15, // 15% from top
          right: 0,
          bottom: null,
        );
      case TextFieldType.subtitle:
        // Subtitle: Bottom area (20% from bottom)
        return _ElementPosition(
          left: 0,
          top: null,
          right: 0,
          bottom: containerSize.height * 0.15, // 15% from bottom
        );
    }
  }

  /// Calculates optimal font size based on container size and text length
  static double calculateOptimalFontSize({
    required String text,
    required Size containerSize,
    required double baseFontSize,
    required TextStyle style,
    int maxLines = 2,
  }) {
    if (text.isEmpty) return baseFontSize;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    );

    double fontSize = baseFontSize;
    const double minFontSize = 8.0;
    const double maxWidth = 0.8; // Use 80% of container width
    const double maxHeight = 0.15; // Use 15% of container height
    
    while (fontSize > minFontSize) {
      textPainter.text = TextSpan(
        text: text,
        style: style.copyWith(fontSize: fontSize),
      );
      
      textPainter.layout(maxWidth: containerSize.width * maxWidth);
      
      if (textPainter.size.height <= containerSize.height * maxHeight) {
        break;
      }
      
      fontSize -= 1;
    }

    return fontSize.clamp(minFontSize, baseFontSize);
  }

  /// Creates a TextStyle from TextElement properties
  static TextStyle createTextStyle(TextElement element, {double? overrideFontSize}) {
    return TextStyle(
      fontFamily: element.fontFamily,
      fontSize: overrideFontSize ?? element.fontSize,
      fontWeight: element.fontWeight,
      color: element.color,
      height: 1.2,
    );
  }

  /// Validates text content for rendering
  static bool isValidForRendering(TextElement element) {
    return element.isVisible && 
           element.content.trim().isNotEmpty;
  }

  /// Gets the display area for a text element type
  static Rect getTextDisplayArea(TextFieldType type, Size containerSize) {
    final padding = 16.0;
    
    switch (type) {
      case TextFieldType.title:
        return Rect.fromLTWH(
          padding,
          containerSize.height * 0.15,
          containerSize.width - (padding * 2),
          containerSize.height * 0.2, // 20% height for title area
        );
      case TextFieldType.subtitle:
        return Rect.fromLTWH(
          padding,
          containerSize.height * 0.65, // Start at 65% from top
          containerSize.width - (padding * 2),
          containerSize.height * 0.2, // 20% height for subtitle area
        );
    }
  }

  /// Estimates text dimensions without laying out
  static Size estimateTextSize({
    required String text,
    required TextStyle style,
    required double maxWidth,
    int maxLines = 1,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    );
    
    textPainter.layout(maxWidth: maxWidth);
    return textPainter.size;
  }

  /// Checks if text will overflow in the given constraints
  static bool willTextOverflow({
    required String text,
    required TextStyle style,
    required Size availableSize,
    int maxLines = 2,
  }) {
    final estimatedSize = estimateTextSize(
      text: text,
      style: style,
      maxWidth: availableSize.width,
      maxLines: maxLines,
    );
    
    return estimatedSize.height > availableSize.height ||
           estimatedSize.width > availableSize.width;
  }

  /// Creates a responsive text widget that adapts to container size
  static Widget createResponsiveText({
    required TextElement element,
    required Size containerSize,
    double scaleFactor = 1.0,
  }) {
    final displayArea = getTextDisplayArea(element.type, containerSize);
    final maxLines = element.type == TextFieldType.title ? 3 : 2;
    
    // Calculate optimal font size
    final baseStyle = createTextStyle(element);
    final optimalFontSize = calculateOptimalFontSize(
      text: element.content,
      containerSize: Size(displayArea.width, displayArea.height),
      baseFontSize: element.fontSize * scaleFactor,
      style: baseStyle,
      maxLines: maxLines,
    );
    
    return Text(
      element.content,
      style: baseStyle.copyWith(fontSize: optimalFontSize),
      textAlign: element.textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Helper class for element positioning
class _ElementPosition {
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  const _ElementPosition({
    this.left,
    this.top,
    this.right,
    this.bottom,
  });
}