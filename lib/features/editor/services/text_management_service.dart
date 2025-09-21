import 'package:flutter/material.dart';
import '../models/text_models.dart';
import '../models/editor_state.dart';

class TextManagementService {
  /// Migrates legacy caption field to new text configuration
  static ScreenTextConfig migrateLegacyCaption({
    required String caption,
    required String fontFamily,
    required double fontSize,
    required FontWeight fontWeight,
    required TextAlign textAlign,
    required Color color,
  }) {
    if (caption.trim().isEmpty) {
      return const ScreenTextConfig();
    }

    // Create a title element from legacy caption data
    final titleElement = TextElement.withContent(
      id: 'migrated_title_${DateTime.now().millisecondsSinceEpoch}',
      type: TextFieldType.title,
      content: caption,
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      textAlign: textAlign,
      color: color,
      isVisible: true,
    );

    return ScreenTextConfig(
      elements: {TextFieldType.title: titleElement},
    );
  }

  /// Validates text element configuration
  static ValidationResult validateTextElement(TextElement element) {
    final errors = <String>[];
    final warnings = <String>[];

    // Content validation
    if (element.content.trim().isEmpty) {
      errors.add('Text content cannot be empty');
    } else if (element.content.length > 500) {
      warnings.add('Text content is very long and may not display properly');
    }

    // Font size validation
    if (element.fontSize < 8) {
      warnings.add('Font size is very small and may not be readable');
    } else if (element.fontSize > 100) {
      warnings.add('Font size is very large and may not fit properly');
    }

    // Font family validation
    const supportedFonts = [
      'Inter', 'Roboto', 'Open Sans', 'Lato', 'Montserrat', 'Poppins', 'Nunito'
    ];
    if (!supportedFonts.contains(element.fontFamily)) {
      warnings.add('Font family "${element.fontFamily}" may not be available on all devices');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validates screen text configuration
  static ValidationResult validateScreenTextConfig(ScreenTextConfig config) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check for duplicate element types (shouldn't happen but good to validate)
    final elementTypes = config.allElements.map((e) => e.type).toList();
    final uniqueTypes = elementTypes.toSet();
    if (elementTypes.length != uniqueTypes.length) {
      errors.add('Duplicate text element types found');
    }

    // Validate individual elements
    for (final element in config.allElements) {
      final elementValidation = validateTextElement(element);
      errors.addAll(elementValidation.errors.map(
        (error) => '${element.type.displayName}: $error'
      ));
      warnings.addAll(elementValidation.warnings.map(
        (warning) => '${element.type.displayName}: $warning'
      ));
    }

    // Check for conflicting positioning (both title and subtitle in similar areas)
    final visibleElements = config.visibleElements;
    if (visibleElements.length > 2) {
      warnings.add('More than 2 text elements may cause overlap');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Creates default text elements for common use cases
  static Map<String, TextElement> createDefaultElements() {
    return {
      'app_title': TextElement.createDefault(TextFieldType.title)
          .updateContent('App Title')
          .copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
      'feature_subtitle': TextElement.createDefault(TextFieldType.subtitle)
          .updateContent('Key Feature')
          .copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
    };
  }

  /// Optimizes text element for better display
  static TextElement optimizeTextElement({
    required TextElement element,
    required Size containerSize,
    double maxWidthRatio = 0.8,
    double maxHeightRatio = 0.15,
  }) {
    // Calculate optimal font size based on container size and text length
    double optimalFontSize = element.fontSize;
    
    // Rough estimation: longer text needs smaller font
    final textLength = element.content.length;
    final containerArea = containerSize.width * containerSize.height;
    final baseSize = (containerArea / 10000).clamp(12.0, 32.0);
    
    if (textLength > 50) {
      optimalFontSize = (baseSize * 0.7).clamp(12.0, element.fontSize);
    } else if (textLength > 20) {
      optimalFontSize = (baseSize * 0.85).clamp(14.0, element.fontSize);
    } else {
      optimalFontSize = baseSize.clamp(16.0, element.fontSize);
    }

    return element.copyWith(fontSize: optimalFontSize);
  }

  /// Converts between FontWeight and EditorFontWeight
  static EditorFontWeight fontWeightToEditorFontWeight(FontWeight fontWeight) {
    for (final editorWeight in EditorFontWeight.values) {
      if (editorWeight.fontWeight == fontWeight) {
        return editorWeight;
      }
    }
    return EditorFontWeight.normal;
  }

  /// Converts between TextAlign and EditorTextAlign
  static EditorTextAlign textAlignToEditorTextAlign(TextAlign textAlign) {
    for (final editorAlign in EditorTextAlign.values) {
      if (editorAlign.textAlign == textAlign) {
        return editorAlign;
      }
    }
    return EditorTextAlign.center;
  }

  /// Cleans up text content
  static String cleanTextContent(String content) {
    return content
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll(RegExp(r'[\r\n]+'), '\n'); // Normalize line breaks
  }

  /// Estimates text rendering size
  static Size estimateTextSize({
    required String text,
    required double fontSize,
    required FontWeight fontWeight,
    required String fontFamily,
    required double maxWidth,
  }) {
    // Rough estimation based on character count and font size
    final charWidth = fontSize * 0.6; // Approximate character width
    final lineHeight = fontSize * 1.2; // Approximate line height
    
    final words = text.split(' ');
    final lines = <String>[];
    String currentLine = '';
    
    for (final word in words) {
      final testLine = currentLine.isEmpty ? word : '$currentLine $word';
      final testWidth = testLine.length * charWidth;
      
      if (testWidth <= maxWidth) {
        currentLine = testLine;
      } else {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
          currentLine = word;
        } else {
          lines.add(word); // Single word that exceeds width
        }
      }
    }
    
    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }
    
    final totalHeight = lines.length * lineHeight;
    final maxLineWidth = lines.map((line) => line.length * charWidth).reduce(
      (a, b) => a > b ? a : b
    );
    
    return Size(maxLineWidth.clamp(0, maxWidth), totalHeight);
  }

  /// Gets text element by ID from configuration
  static TextElement? getElementByType(
    ScreenTextConfig config, 
    TextFieldType type
  ) {
    return config.getElement(type);
  }

  /// Updates text configuration with new element
  static ScreenTextConfig updateElementInConfig({
    required ScreenTextConfig config,
    required TextElement element,
  }) {
    return config.updateElement(element);
  }

  /// Removes element from configuration
  static ScreenTextConfig removeElementFromConfig({
    required ScreenTextConfig config,
    required TextFieldType type,
  }) {
    return config.removeElement(type);
  }

  /// Creates a copy of configuration with all elements having the same formatting
  static ScreenTextConfig applyFormattingToAllElements({
    required ScreenTextConfig config,
    required TextElement sourceElement,
  }) {
    final updatedElements = <TextFieldType, TextElement>{};
    
    for (final element in config.allElements) {
      updatedElements[element.type] = element.copyWith(
        fontFamily: sourceElement.fontFamily,
        fontSize: sourceElement.fontSize,
        fontWeight: sourceElement.fontWeight,
        textAlign: sourceElement.textAlign,
        color: sourceElement.color,
      );
    }
    
    return ScreenTextConfig(elements: updatedElements);
  }
}

/// Validation result for text configurations
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
  bool get hasIssues => hasErrors || hasWarnings;

  @override
  String toString() {
    final buffer = StringBuffer();
    if (hasErrors) {
      buffer.writeln('Errors:');
      for (final error in errors) {
        buffer.writeln('  - $error');
      }
    }
    if (hasWarnings) {
      buffer.writeln('Warnings:');
      for (final warning in warnings) {
        buffer.writeln('  - $warning');
      }
    }
    return buffer.toString();
  }
}