import 'package:flutter/material.dart';

enum TextFieldType {
  title('title', 'Title'),
  subtitle('subtitle', 'Subtitle');

  const TextFieldType(this.id, this.displayName);

  final String id;
  final String displayName;

  factory TextFieldType.fromString(String value) {
    return TextFieldType.values.firstWhere(
      (type) => type.id == value,
      orElse: () => TextFieldType.title,
    );
  }
}

/// Text grouping options for title and subtitle
enum TextGrouping {
  separated('separated', 'Separated'),
  together('together', 'Together');

  const TextGrouping(this.id, this.displayName);

  final String id;
  final String displayName;

  factory TextGrouping.fromString(String value) {
    return TextGrouping.values.firstWhere(
      (grouping) => grouping.id == value,
      orElse: () => TextGrouping.separated,
    );
  }
}

/// Vertical positioning options for text elements
enum VerticalPosition {
  top('top', 'Top'),
  middle('middle', 'Middle'),
  bottom('bottom', 'Bottom');

  const VerticalPosition(this.id, this.displayName);

  final String id;
  final String displayName;

  factory VerticalPosition.fromString(String value) {
    return VerticalPosition.values.firstWhere(
      (position) => position.id == value,
      orElse: () => VerticalPosition.top,
    );
  }
}

class TextElement {
  final String id;
  final TextFieldType type;
  final Map<String, String> translations; // NEW: Multi-language support
  final String fontFamily;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final Color color;
  final bool isVisible;
  final VerticalPosition? verticalPosition; // NEW: Vertical positioning

  const TextElement({
    required this.id,
    required this.type,
    required this.translations,
    this.fontFamily = 'Inter',
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.center,
    this.color = Colors.black,
    this.isVisible = true,
    this.verticalPosition, // NEW: Vertical positioning parameter
  });

  // Backward compatibility getter - returns fallback content
  String get content {
    if (translations.isEmpty) return '';
    // Return English first, then any available translation
    return translations['en'] ?? translations.values.first;
  }

  factory TextElement.createDefault(TextFieldType type) {
    return TextElement(
      id: '${type.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      translations: {'en': type.displayName}, // Default to English
      fontSize: type == TextFieldType.title ? 24.0 : 16.0,
      fontWeight:
          type == TextFieldType.title ? FontWeight.bold : FontWeight.normal,
    );
  }

  // Convenience constructor for backward compatibility
  factory TextElement.withContent({
    required String id,
    required TextFieldType type,
    required String content,
    String languageCode = 'en',
    String fontFamily = 'Inter',
    double fontSize = 16.0,
    FontWeight fontWeight = FontWeight.normal,
    TextAlign textAlign = TextAlign.center,
    Color color = Colors.black,
    bool isVisible = true,
    VerticalPosition? verticalPosition,
  }) {
    return TextElement(
      id: id,
      type: type,
      translations: {languageCode: content},
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      textAlign: textAlign,
      color: color,
      isVisible: isVisible,
      verticalPosition: verticalPosition,
    );
  }

  TextElement copyWith({
    String? id,
    TextFieldType? type,
    Map<String, String>? translations,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    Color? color,
    bool? isVisible,
    VerticalPosition? verticalPosition,
  }) {
    return TextElement(
      id: id ?? this.id,
      type: type ?? this.type,
      translations: translations ?? this.translations,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      textAlign: textAlign ?? this.textAlign,
      color: color ?? this.color,
      isVisible: isVisible ?? this.isVisible,
      verticalPosition: verticalPosition ?? this.verticalPosition,
    );
  }

  // Translation management methods
  String getTranslation(String languageCode, {String? fallbackLanguage}) {
    if (translations.containsKey(languageCode)) {
      return translations[languageCode]!;
    }
    if (fallbackLanguage != null && translations.containsKey(fallbackLanguage)) {
      return translations[fallbackLanguage]!;
    }
    return content; // Use backward compatibility getter
  }

  bool hasTranslation(String languageCode) {
    return translations.containsKey(languageCode);
  }

  TextElement addTranslation(String languageCode, String translatedText) {
    final updatedTranslations = Map<String, String>.from(translations);
    updatedTranslations[languageCode] = translatedText;
    return copyWith(translations: updatedTranslations);
  }

  TextElement removeTranslation(String languageCode) {
    final updatedTranslations = Map<String, String>.from(translations);
    updatedTranslations.remove(languageCode);
    return copyWith(translations: updatedTranslations);
  }

  List<String> get availableLanguages => translations.keys.toList();

  // Backward compatibility method for setting content
  TextElement updateContent(String content, {String languageCode = 'en'}) {
    return addTranslation(languageCode, content);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.id,
      'translations': translations, // NEW: Serialize translations map
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'fontWeight': fontWeight.index,
      'textAlign': textAlign.index,
      'color': color.value,
      'isVisible': isVisible,
      'verticalPosition': verticalPosition?.id,
    };
  }

  factory TextElement.fromJson(Map<String, dynamic> json) {
    // Migration logic: handle both old and new formats
    Map<String, String> translations;
    
    if (json.containsKey('translations')) {
      // New format with translations map
      final rawTranslations = json['translations'] as Map<String, dynamic>;
      translations = rawTranslations.map((key, value) => MapEntry(key, value.toString()));
    } else if (json.containsKey('content')) {
      // Legacy format with single content field - migrate to translations
      final legacyContent = json['content'] as String;
      translations = {'en': legacyContent}; // Default to English
    } else {
      // Fallback - empty translations
      translations = {};
    }
    
    return TextElement(
      id: json['id'] as String,
      type: TextFieldType.fromString(json['type'] as String),
      translations: translations,
      fontFamily: json['fontFamily'] as String? ?? 'Inter',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      fontWeight: FontWeight
          .values[json['fontWeight'] as int? ?? FontWeight.normal.index],
      textAlign:
          TextAlign.values[json['textAlign'] as int? ?? TextAlign.center.index],
      color: Color(json['color'] as int? ?? Colors.black.value),
      isVisible: json['isVisible'] as bool? ?? true,
      verticalPosition: json['verticalPosition'] != null
          ? VerticalPosition.fromString(json['verticalPosition'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextElement &&
        other.id == id &&
        other.type == type &&
        _mapEquals(other.translations, translations) &&
        other.fontFamily == fontFamily &&
        other.fontSize == fontSize &&
        other.fontWeight == fontWeight &&
        other.textAlign == textAlign &&
        other.color == color &&
        other.isVisible == isVisible &&
        other.verticalPosition == verticalPosition;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      translations,
      fontFamily,
      fontSize,
      fontWeight,
      textAlign,
      color,
      isVisible,
      verticalPosition,
    );
  }

  @override
  String toString() {
    return 'TextElement(id: $id, type: $type, translations: $translations, fontFamily: $fontFamily, fontSize: $fontSize, fontWeight: $fontWeight, textAlign: $textAlign, color: $color, isVisible: $isVisible, verticalPosition: $verticalPosition)';
  }

  // Helper method for map equality check
  static bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

class ScreenTextConfig {
  final Map<TextFieldType, TextElement> elements;
  final TextGrouping textGrouping;

  const ScreenTextConfig({
    this.elements = const {},
    this.textGrouping = TextGrouping.separated,
  });

  factory ScreenTextConfig.empty() {
    return const ScreenTextConfig();
  }

  TextElement? getElement(TextFieldType type) {
    return elements[type];
  }

  bool hasElement(TextFieldType type) {
    return elements.containsKey(type) && elements[type]!.isVisible;
  }

  List<TextElement> get visibleElements {
    return elements.values.where((element) => element.isVisible).toList();
  }

  List<TextElement> get allElements {
    return elements.values.toList();
  }

  int get elementCount {
    return elements.length;
  }

  int get visibleElementCount {
    return visibleElements.length;
  }

  /// Checks if both title and subtitle elements exist and are visible
  bool get hasBothElementsVisible {
    return hasElement(TextFieldType.title) &&
        hasElement(TextFieldType.subtitle);
  }

  /// Gets the primary element for positioning when grouped (title takes precedence)
  TextElement? get primaryElement {
    return getElement(TextFieldType.title) ??
        getElement(TextFieldType.subtitle);
  }

  ScreenTextConfig addElement(TextElement element) {
    final updatedElements = Map<TextFieldType, TextElement>.from(elements);
    updatedElements[element.type] = element;
    return ScreenTextConfig(
        elements: updatedElements, textGrouping: textGrouping);
  }

  ScreenTextConfig updateElement(TextElement element) {
    if (!elements.containsKey(element.type)) {
      return this;
    }
    final updatedElements = Map<TextFieldType, TextElement>.from(elements);
    updatedElements[element.type] = element;
    return ScreenTextConfig(
        elements: updatedElements, textGrouping: textGrouping);
  }

  ScreenTextConfig removeElement(TextFieldType type) {
    final updatedElements = Map<TextFieldType, TextElement>.from(elements);
    updatedElements.remove(type);
    return ScreenTextConfig(
        elements: updatedElements, textGrouping: textGrouping);
  }

  ScreenTextConfig copyFormattingFrom(
      TextElement sourceElement, TextFieldType targetType) {
    if (!elements.containsKey(targetType)) {
      return this;
    }

    final targetElement = elements[targetType]!;
    final updatedElement = targetElement.copyWith(
      fontFamily: sourceElement.fontFamily,
      fontSize: sourceElement.fontSize,
      fontWeight: sourceElement.fontWeight,
      textAlign: sourceElement.textAlign,
      color: sourceElement.color,
    );

    return updateElement(updatedElement);
  }

  ScreenTextConfig updateGrouping(TextGrouping newGrouping) {
    return ScreenTextConfig(elements: elements, textGrouping: newGrouping);
  }

  ScreenTextConfig createElementIfNotExists(TextFieldType type) {
    if (hasElement(type)) {
      return this;
    }

    final newElement = TextElement.createDefault(type);
    return addElement(newElement);
  }

  ScreenTextConfig copyWith({
    Map<TextFieldType, TextElement>? elements,
    TextGrouping? textGrouping,
  }) {
    return ScreenTextConfig(
      elements: elements ?? this.elements,
      textGrouping: textGrouping ?? this.textGrouping,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'elements': elements.map(
        (key, value) => MapEntry(key.id, value.toJson()),
      ),
      'textGrouping': textGrouping.id,
    };
  }

  factory ScreenTextConfig.fromJson(Map<String, dynamic> json) {
    final elementsData = json['elements'] as Map<String, dynamic>? ?? {};
    final elements = <TextFieldType, TextElement>{};

    for (final entry in elementsData.entries) {
      final type = TextFieldType.fromString(entry.key);
      final element = TextElement.fromJson(entry.value as Map<String, dynamic>);
      elements[type] = element;
    }

    final textGrouping = json['textGrouping'] != null
        ? TextGrouping.fromString(json['textGrouping'] as String)
        : TextGrouping.separated;

    return ScreenTextConfig(
      elements: elements,
      textGrouping: textGrouping,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScreenTextConfig &&
        _mapEquals(other.elements, elements) &&
        other.textGrouping == textGrouping;
  }

  @override
  int get hashCode {
    return Object.hash(elements, textGrouping);
  }

  @override
  String toString() {
    return 'ScreenTextConfig(elements: $elements, textGrouping: $textGrouping)';
  }

  static bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
