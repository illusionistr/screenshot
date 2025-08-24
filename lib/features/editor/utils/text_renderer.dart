import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final position = _getElementPosition(element, containerSize);
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
        child: element.isRichText && element.segments != null
            ? _buildRichText(element, scaledFontSize.clamp(8.0, 100.0))
            : Text(
                element.content,
                style: _getGoogleFontStyle(
                  element.fontFamily,
                  fontSize: scaledFontSize.clamp(8.0, 100.0),
                  fontWeight: element.fontWeight,
                  color: element.color,
                ),
                textAlign: element.textAlign,
                maxLines: element.type == TextFieldType.title ? 3 : 2,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }

  /// Gets the position parameters for a text element
  static _ElementPosition _getElementPosition(
      TextElement element, Size containerSize) {
    // Use custom vertical position if set, otherwise fall back to defaults
    final verticalPos =
        element.verticalPosition ?? _getDefaultVerticalPosition(element.type);
    final horizontalPos = element.textAlign;

    // Calculate vertical position
    double? top, bottom;
    switch (verticalPos) {
      case VerticalPosition.top:
        top = containerSize.height * 0.05; // 5% from top
        bottom = null;
        break;
      case VerticalPosition.middle:
        top = containerSize.height * 0.5; // Center vertically
        bottom = null;
        break;
      case VerticalPosition.bottom:
        top = null;
        bottom = containerSize.height * 0.05; // 5% from bottom
        break;
    }

    // Calculate horizontal position based on text alignment
    double? left, right;
    switch (horizontalPos) {
      case TextAlign.left:
        left = containerSize.width * 0.05; // 5% from left
        right = null;
        break;
      case TextAlign.center:
        left = containerSize.width * 0.5; // Center horizontally
        right = null;
        break;
      case TextAlign.right:
        left = null;
        right = containerSize.width * 0.05; // 5% from right
        break;
      default:
        left = containerSize.width * 0.5; // Default to center
        right = null;
        break;
    }

    return _ElementPosition(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  /// Gets the default vertical position for a text element type
  static VerticalPosition _getDefaultVerticalPosition(TextFieldType type) {
    switch (type) {
      case TextFieldType.title:
        return VerticalPosition.top; // Default to top
      case TextFieldType.subtitle:
        return VerticalPosition.bottom; // Default to bottom
    }
  }

  /// Builds rich text from segments
  static Widget _buildRichText(TextElement element, double baseFontSize) {
    final textSpans = element.segments!.map((segment) {
      return TextSpan(
        text: segment.text,
        style: _getGoogleFontStyle(
          segment.fontFamily,
          fontSize: segment.fontSize,
          fontWeight: segment.fontWeight,
          color: segment.color,
        ).copyWith(
          fontStyle: segment.isItalic ? FontStyle.italic : FontStyle.normal,
          decoration: segment.isUnderline ? TextDecoration.underline : null,
        ),
      );
    }).toList();

    return Text.rich(
      TextSpan(children: textSpans),
      textAlign: element.textAlign,
      maxLines: element.type == TextFieldType.title ? 3 : 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Creates a TextStyle using Google Fonts or fallback to system fonts
  static TextStyle _getGoogleFontStyle(
    String fontFamily, {
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    // Map font family names to Google Fonts methods
    final baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.2,
    );

    switch (fontFamily.toLowerCase().replaceAll(' ', '')) {
      // Popular Sans Serif Fonts
      case 'inter':
        return GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      case 'roboto':
        return GoogleFonts.roboto(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      case 'opensans':
        return GoogleFonts.openSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      case 'lato':
        return GoogleFonts.lato(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      case 'montserrat':
        return GoogleFonts.montserrat(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      case 'poppins':
        return GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      case 'nunito':
        return GoogleFonts.nunito(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      // Note: Source Sans Pro method name needs verification
      // case 'sourcesanspro':
      //   return GoogleFonts.sourceSansPro(
      case 'ubuntu':
        return GoogleFonts.ubuntu(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      case 'karla':
        return GoogleFonts.karla(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      case 'quicksand':
        return GoogleFonts.quicksand(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      case 'comfortaa':
        return GoogleFonts.comfortaa(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );

      // Display & Brand Fonts
      case 'oswald':
        return GoogleFonts.oswald(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      case 'bebasneue':
        return GoogleFonts.bebasNeue(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      case 'playfairdisplay':
        return GoogleFonts.playfairDisplay(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      case 'cinzel':
        return GoogleFonts.cinzel(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      case 'dancingscript':
        return GoogleFonts.dancingScript(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      case 'pacifico':
        return GoogleFonts.pacifico(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );

      // Serif Fonts
      case 'merriweather':
        return GoogleFonts.merriweather(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );
      case 'lora':
        return GoogleFonts.lora(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: 1.2,
        );

      // Fallback to system font for any unmatched font
      default:
        return baseStyle.copyWith(fontFamily: fontFamily);
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
  static TextStyle createTextStyle(TextElement element,
      {double? overrideFontSize}) {
    return _getGoogleFontStyle(
      element.fontFamily,
      fontSize: overrideFontSize ?? element.fontSize,
      fontWeight: element.fontWeight,
      color: element.color,
    );
  }

  /// Validates text content for rendering
  static bool isValidForRendering(TextElement element) {
    return element.isVisible && element.content.trim().isNotEmpty;
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
