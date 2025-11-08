import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../projects/models/project_model.dart';
import '../models/text_models.dart';
import '../providers/editor_provider.dart';
import '../models/layout_models.dart';
import 'layout_renderer.dart';
import '../models/positioning_models.dart';

class TextRenderer {
  /// Renders all text overlays for a screen
  static Widget renderTextOverlay({
    required ScreenTextConfig textConfig,
    required Size containerSize,
    required String currentLanguage,
    double scaleFactor = 1.0,
    LayoutConfig? layout,
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
          currentLanguage: currentLanguage,
          scaleFactor: scaleFactor,
          layout: layout,
        );
      }).toList(),
    );
  }

  /// Renders all text overlays with interactive selection support
  static Widget renderInteractiveTextOverlay({
    required ScreenTextConfig textConfig,
    required Size containerSize,
    required ProjectModel project,
    required String currentLanguage,
    required int screenIndex,
    double scaleFactor = 1.0,
    LayoutConfig? layout,
  }) {
    final visibleElements = textConfig.visibleElements;

    if (visibleElements.isEmpty) {
      return const SizedBox.shrink();
    }

    // Render all text elements independently using the positioning system
    return Stack(
      children: visibleElements.map((element) {
        return KeyedSubtree(
          key: ValueKey('text_overlay_${element.id}'),
          child: renderInteractiveTextElement(
            element: element,
            containerSize: containerSize,
            project: project,
            currentLanguage: currentLanguage,
            screenIndex: screenIndex,
            scaleFactor: scaleFactor,
            layout: layout,
          ),
        );
      }).toList(),
    );
  }

  /// Renders a single text element with proper positioning
  static Widget renderTextElement({
    required TextElement element,
    required Size containerSize,
    required String currentLanguage,
    double scaleFactor = 1.0,
    LayoutConfig? layout,
  }) {
    final position = _getElementPosition(element, containerSize, layout: layout);
    final t = layout != null
        ? LayoutRenderer.resolveTextTransform(layout, isTitle: element.type == TextFieldType.title)
        : null;
    final effectiveScale = (t?.scale ?? 1.0) * scaleFactor;
    final scaledFontSize = element.fontSize * effectiveScale;

    // Get the translated content for the current language
    final displayContent = element.getTranslation(currentLanguage);

    return Positioned(
      left: position.left,
      top: position.top,
      right: position.right,
      bottom: position.bottom,
      child: Transform.rotate(
        angle: ((t?.rotationDeg ?? 0.0) * math.pi / 180.0),
        alignment: Alignment.center,
        child: _withAnchorTranslation(
          t,
          child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * effectiveScale,
            vertical: 8 * effectiveScale,
          ),
          child: Text(
            displayContent,
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
        ),
      ),
    );
  }

  /// Renders a single interactive text element with proper positioning
  static Widget renderInteractiveTextElement({
    required TextElement element,
    required Size containerSize,
    required ProjectModel project,
    required String currentLanguage,
    required int screenIndex,
    double scaleFactor = 1.0,
    LayoutConfig? layout,
  }) {
    final position = _getElementPosition(element, containerSize, layout: layout);
    final t = layout != null
        ? LayoutRenderer.resolveTextTransform(layout, isTitle: element.type == TextFieldType.title)
        : null;
    final effectiveScale = (t?.scale ?? 1.0) * scaleFactor;

    return Positioned(
      left: position.left,
      top: position.top,
      right: position.right,
      bottom: position.bottom,
      child: Transform.rotate(
        angle: ((t?.rotationDeg ?? 0.0) * math.pi / 180.0),
        alignment: Alignment.center,
        child: _withAnchorTranslation(
          t,
          child: _InteractiveTextWidget(
            key: ValueKey('interactive_text_${element.id}'),
            element: element,
            containerSize: containerSize,
            project: project,
            currentLanguage: currentLanguage,
            screenIndex: screenIndex,
            scaleFactor: effectiveScale,
          ),
        ),
      ),
    );
  }

  static Widget _withAnchorTranslation(ElementTransform? t, {required Widget child}) {
    if (t == null) return child;
    double tx;
    switch (t.hAnchor) {
      case HorizontalAnchor.left:
        tx = 0.0;
        break;
      case HorizontalAnchor.center:
        tx = -0.5;
        break;
      case HorizontalAnchor.right:
        tx = -1.0;
        break;
    }
    double ty;
    switch (t.vAnchor) {
      case VerticalAnchor.top:
        ty = 0.0;
        break;
      case VerticalAnchor.center:
        ty = -0.5;
        break;
      case VerticalAnchor.bottom:
        ty = -1.0;
        break;
    }
    return FractionalTranslation(translation: Offset(tx, ty), child: child);
  }

  /// Gets the position parameters for a text element
  static _ElementPosition _getElementPosition(
      TextElement element, Size containerSize, {LayoutConfig? layout}) {
    // If a unified transform is provided via layout, prefer it
    if (layout != null) {
      final isTitle = element.type == TextFieldType.title;
      final t = LayoutRenderer.resolveTextTransform(layout, isTitle: isTitle);
      if (t != null) {
        // Compute top-left based on anchor + offset percentages
        final baseX = () {
          switch (t.hAnchor) {
            case HorizontalAnchor.left:
              return 0.0;
            case HorizontalAnchor.center:
              return containerSize.width / 2;
            case HorizontalAnchor.right:
              return containerSize.width;
          }
        }();
        final baseY = () {
          switch (t.vAnchor) {
            case VerticalAnchor.top:
              return 0.0;
            case VerticalAnchor.center:
              return containerSize.height / 2;
            case VerticalAnchor.bottom:
              return containerSize.height;
          }
        }();
        final left = baseX + (t.hPercent * containerSize.width);
        final top = baseY + (t.vPercent * containerSize.height);
        return const _ElementPosition().copyWith(left: left, top: top);
      }
    }
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
    // Use symmetric insets for centered content so the widget
    // is actually centered instead of offsetting its left edge.
    double? left, right;
    switch (horizontalPos) {
      case TextAlign.left:
        left = containerSize.width * 0.05; // 5% from left
        right = null;
        break;
      case TextAlign.center:
        left = containerSize.width * 0.05; // symmetric 5% margins
        right = containerSize.width * 0.05;
        break;
      case TextAlign.right:
        left = null;
        right = containerSize.width * 0.05; // 5% from right
        break;
      default:
        left = containerSize.width * 0.05; // default to centered region
        right = containerSize.width * 0.05;
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

  /// Public helper to obtain a TextStyle for a given font family
  /// Useful for UI previews (e.g., font dropdown items)
  static TextStyle previewStyleForFontFamily(
    String fontFamily, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = const Color(0xFF212529),
  }) {
    return _getGoogleFontStyle(
      fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
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

/// Interactive text widget that can be clicked to select
class _InteractiveTextWidget extends ConsumerStatefulWidget {
  final TextElement element;
  final Size containerSize;
  final double scaleFactor;
  final ProjectModel project;
  final String currentLanguage;
  final int screenIndex;

  const _InteractiveTextWidget({
    super.key,
    required this.element,
    required this.containerSize,
    required this.project,
    required this.currentLanguage,
    required this.screenIndex,
    this.scaleFactor = 1.0,
  });

  @override
  ConsumerState<_InteractiveTextWidget> createState() =>
      _InteractiveTextWidgetState();
}

class _InteractiveTextWidgetState
    extends ConsumerState<_InteractiveTextWidget> {
  bool _isHovered = false;
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    // Check if this element is selected AND belongs to the currently selected screen
    _isSelected = ref.watch(
      editorByProjectIdProvider(widget.project.id).select((state) =>
        state.textElementState.isSelected(widget.element.type) &&
        state.selectedScreenIndex == widget.screenIndex
      )
    );

    final editorNotifier =
        ref.read(editorByProjectIdProvider(widget.project.id).notifier);

    return GestureDetector(
      onTap: () => _handleTap(editorNotifier),
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * widget.scaleFactor,
          vertical: 8 * widget.scaleFactor,
        ),
        decoration: _buildDecoration(),
        child: _buildTextWidget(),
      ),
    );
  }

  void _handleTap(EditorNotifier editorNotifier) {
    // First select the screen this text element belongs to
    editorNotifier.selectScreen(widget.screenIndex);
    // Then select the text element type
    editorNotifier.selectTextElement(widget.element.type);
  }

  BoxDecoration _buildDecoration() {
    if (_isSelected) {
      return BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE91E63),
          width: 2 * widget.scaleFactor,
        ),
        borderRadius: BorderRadius.circular(4 * widget.scaleFactor),
        color: const Color(0xFFE91E63).withOpacity(0.1),
      );
    } else if (_isHovered) {
      return BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE91E63).withOpacity(0.5),
          width: 1 * widget.scaleFactor,
        ),
        borderRadius: BorderRadius.circular(4 * widget.scaleFactor),
        color: const Color(0xFFE91E63).withOpacity(0.05),
      );
    }

    return const BoxDecoration();
  }

  Widget _buildTextWidget() {
    // Use the existing text rendering logic from TextRenderer
    final scaledFontSize = widget.element.fontSize * widget.scaleFactor;

    // Get the translated content for the current language
    final displayContent = widget.element.getTranslation(widget.currentLanguage);

    return Text(
      displayContent,
      style: _getGoogleFontStyle(
        widget.element.fontFamily,
        fontSize: scaledFontSize.clamp(8.0, 100.0),
        fontWeight: widget.element.fontWeight,
        color: widget.element.color,
      ),
      textAlign: widget.element.textAlign,
      maxLines: widget.element.type == TextFieldType.title ? 3 : 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Creates a TextStyle using Google Fonts or fallback to system fonts
  TextStyle _getGoogleFontStyle(
    String fontFamily, {
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    // Use the same Google Fonts mapping as the main TextRenderer
    return TextRenderer._getGoogleFontStyle(
      fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
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

  _ElementPosition copyWith({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return _ElementPosition(
      left: left ?? this.left,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
    );
  }
}
