import '../models/editor_state.dart';
import '../models/layout_models.dart';
import '../models/text_models.dart';

/// Exception thrown when layout application fails
class LayoutApplicationException implements Exception {
  final String message;

  const LayoutApplicationException(this.message);

  @override
  String toString() => 'LayoutApplicationException: $message';
}

/// Service responsible for applying layout configurations to screens
class LayoutApplicationService {
  /// Applies a layout configuration to a specific screen
  ///
  /// This method will:
  /// - Create missing text elements (title/subtitle) if they don't exist
  /// - Override positioning properties according to layout
  /// - Preserve existing text content and styling
  /// - Apply layout's device positioning
  static ScreenConfig applyLayoutToScreen({
    required ScreenConfig screen,
    required LayoutConfig layout,
  }) {
    try {
      // Validate inputs
      if (!canApplyLayout(screen: screen, layout: layout)) {
        throw LayoutApplicationException(
            'Layout cannot be applied to this screen');
      }

      // Create or update text configuration with layout defaults
      final updatedTextConfig = _applyLayoutToTextConfig(
        existingTextConfig: screen.textConfig,
        layout: layout,
      );

      // Apply layout's device positioning (this would be handled by frame renderer)
      // For now, we focus on text configuration

      return screen.copyWith(
        textConfig: updatedTextConfig,
        // Note: layoutId will be set by the calling code
      );
    } catch (e) {
      // If layout application fails, return the original screen
      throw LayoutApplicationException(
          'Failed to apply layout: ${e.toString()}');
    }
  }

  /// Creates or updates text configuration based on layout requirements
  static ScreenTextConfig _applyLayoutToTextConfig({
    required ScreenTextConfig existingTextConfig,
    required LayoutConfig layout,
  }) {
    // Start with existing text config or create empty one
    var updatedConfig = existingTextConfig;

    // Ensure both title and subtitle elements exist
    updatedConfig = _ensureTextElementsExist(updatedConfig);

    // Apply layout's positioning and alignment to existing elements
    updatedConfig = _applyLayoutPositioning(updatedConfig, layout);

    return updatedConfig;
  }

  /// Ensures both title and subtitle text elements exist
  /// Creates default elements if they don't exist, preserves existing ones
  static ScreenTextConfig _ensureTextElementsExist(ScreenTextConfig config) {
    var updatedConfig = config;

    // Create title element if it doesn't exist
    if (!updatedConfig.hasElement(TextFieldType.title)) {
      final titleElement = TextElement.createDefault(TextFieldType.title);
      updatedConfig = updatedConfig.addElement(titleElement);
    }

    // Create subtitle element if it doesn't exist
    if (!updatedConfig.hasElement(TextFieldType.subtitle)) {
      final subtitleElement = TextElement.createDefault(TextFieldType.subtitle);
      updatedConfig = updatedConfig.addElement(subtitleElement);
    }

    return updatedConfig;
  }

  /// Applies layout positioning and alignment to text elements
  /// This overrides manual positioning changes while preserving content and styling
  static ScreenTextConfig _applyLayoutPositioning(
    ScreenTextConfig config,
    LayoutConfig layout,
  ) {
    var updatedConfig = config;

    // Apply positioning to title element if it exists
    final titleElement = updatedConfig.getElement(TextFieldType.title);
    if (titleElement != null) {
      final updatedTitle = _applyLayoutToTextElement(
        element: titleElement,
        layout: layout,
        elementType: TextFieldType.title,
      );
      updatedConfig = updatedConfig.updateElement(updatedTitle);
    }

    // Apply positioning to subtitle element if it exists
    final subtitleElement = updatedConfig.getElement(TextFieldType.subtitle);
    if (subtitleElement != null) {
      final updatedSubtitle = _applyLayoutToTextElement(
        element: subtitleElement,
        layout: layout,
        elementType: TextFieldType.subtitle,
      );
      updatedConfig = updatedConfig.updateElement(updatedSubtitle);
    }

    return updatedConfig;
  }

  /// Applies layout configuration to a specific text element
  /// Overrides positioning properties while preserving content and styling
  static TextElement _applyLayoutToTextElement({
    required TextElement element,
    required LayoutConfig layout,
    required TextFieldType elementType,
  }) {
    // Determine the text alignment based on layout and element type
    final textAlign = elementType == TextFieldType.title
        ? layout.titleAlignment
        : layout.subtitleAlignment;

    // Get the appropriate vertical position based on layout positions
    final verticalPosition =
        _getVerticalPositionFromLayout(layout, elementType);

    // Apply layout properties while preserving content and styling
    return element.copyWith(
      textAlign: textAlign,
      verticalPosition: verticalPosition,
      // Preserve existing content, styling, fonts, colors, etc.
      // Only override positioning-related properties
    );
  }

  /// Converts layout text positions to vertical positions
  static VerticalPosition _getVerticalPositionFromLayout(
    LayoutConfig layout,
    TextFieldType elementType,
  ) {
    final position = elementType == TextFieldType.title
        ? layout.titlePosition
        : layout.subtitlePosition;

    switch (position) {
      case TextPosition.above:
      case TextPosition.topLeft:
      case TextPosition.topRight:
        return VerticalPosition.top;

      case TextPosition.below:
      case TextPosition.bottomLeft:
      case TextPosition.bottomRight:
        return VerticalPosition.bottom;

      case TextPosition.left:
      case TextPosition.right:
      case TextPosition.overlay:
        return VerticalPosition.middle;
    }
  }

  /// Validates that a layout can be applied to a screen
  static bool canApplyLayout({
    required ScreenConfig screen,
    required LayoutConfig layout,
  }) {
    // Validate screen has valid ID
    if (screen.id.isEmpty) {
      return false;
    }

    // Validate layout has valid configuration
    if (layout.id.isEmpty || layout.name.isEmpty) {
      return false;
    }

    // Check if layout orientation matches screen orientation
    if (layout.isLandscape != screen.isLandscape) {
      // For now, allow different orientations - could add stricter validation later
    }

    // All validations passed
    return true;
  }

  /// Creates a preview of what the screen would look like with the layout applied
  /// Useful for UI previews before actual application
  static ScreenTextConfig previewLayoutApplication({
    required ScreenTextConfig existingTextConfig,
    required LayoutConfig layout,
  }) {
    return _applyLayoutToTextConfig(
      existingTextConfig: existingTextConfig,
      layout: layout,
    );
  }

  /// Gets a description of what changes will be made when applying a layout
  static List<String> getLayoutApplicationChanges({
    required ScreenTextConfig existingTextConfig,
    required LayoutConfig layout,
  }) {
    final changes = <String>[];

    // Check if text elements need to be created
    if (!existingTextConfig.hasElement(TextFieldType.title)) {
      changes.add('Create title text element');
    }
    if (!existingTextConfig.hasElement(TextFieldType.subtitle)) {
      changes.add('Create subtitle text element');
    }

    // Check if positioning will change
    changes.add('Apply layout positioning and alignment');
    changes.add('Override device frame positioning');

    if (changes.isEmpty) {
      changes.add('Apply layout configuration');
    }

    return changes;
  }
}
