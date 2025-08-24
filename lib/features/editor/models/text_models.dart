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
  final String content;
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
    required this.content,
    this.fontFamily = 'Inter',
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.center,
    this.color = Colors.black,
    this.isVisible = true,
    this.verticalPosition, // NEW: Vertical positioning parameter
  });

  factory TextElement.createDefault(TextFieldType type) {
    return TextElement(
      id: '${type.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      content: type.displayName,
      fontSize: type == TextFieldType.title ? 24.0 : 16.0,
      fontWeight:
          type == TextFieldType.title ? FontWeight.bold : FontWeight.normal,
    );
  }

  TextElement copyWith({
    String? id,
    TextFieldType? type,
    String? content,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    Color? color,
    bool? isVisible,
    VerticalPosition? verticalPosition, // NEW: Vertical position parameter
  }) {
    return TextElement(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      textAlign: textAlign ?? this.textAlign,
      color: color ?? this.color,
      isVisible: isVisible ?? this.isVisible,
      verticalPosition: verticalPosition ??
          this.verticalPosition, // NEW: Vertical position field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.id,
      'content': content,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'fontWeight': fontWeight.index,
      'textAlign': textAlign.index,
      'color': color.value,
      'isVisible': isVisible,
      'verticalPosition':
          verticalPosition?.id, // NEW: Serialize vertical position
    };
  }

  factory TextElement.fromJson(Map<String, dynamic> json) {
    return TextElement(
      id: json['id'] as String,
      type: TextFieldType.fromString(json['type'] as String),
      content: json['content'] as String,
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
          : null, // NEW: Deserialize vertical position
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextElement &&
        other.id == id &&
        other.type == type &&
        other.content == content &&
        other.fontFamily == fontFamily &&
        other.fontSize == fontSize &&
        other.fontWeight == fontWeight &&
        other.textAlign == textAlign &&
        other.color == color &&
        other.isVisible == isVisible &&
        other.verticalPosition ==
            verticalPosition; // NEW: Include verticalPosition in equality
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      content,
      fontFamily,
      fontSize,
      fontWeight,
      textAlign,
      color,
      isVisible,
      verticalPosition, // NEW: Include verticalPosition in hashCode
    );
  }

  @override
  String toString() {
    return 'TextElement(id: $id, type: $type, content: $content, fontFamily: $fontFamily, fontSize: $fontSize, fontWeight: $fontWeight, textAlign: $textAlign, color: $color, isVisible: $isVisible, verticalPosition: $verticalPosition)'; // NEW: Include verticalPosition in toString
  }
}

class ScreenTextConfig {
  final Map<TextFieldType, TextElement> elements;

  const ScreenTextConfig({
    this.elements = const {},
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

  ScreenTextConfig addElement(TextElement element) {
    final updatedElements = Map<TextFieldType, TextElement>.from(elements);
    updatedElements[element.type] = element;
    return ScreenTextConfig(elements: updatedElements);
  }

  ScreenTextConfig updateElement(TextElement element) {
    if (!elements.containsKey(element.type)) {
      return this;
    }
    final updatedElements = Map<TextFieldType, TextElement>.from(elements);
    updatedElements[element.type] = element;
    return ScreenTextConfig(elements: updatedElements);
  }

  ScreenTextConfig removeElement(TextFieldType type) {
    final updatedElements = Map<TextFieldType, TextElement>.from(elements);
    updatedElements.remove(type);
    return ScreenTextConfig(elements: updatedElements);
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

  ScreenTextConfig createElementIfNotExists(TextFieldType type) {
    if (hasElement(type)) {
      return this;
    }

    final newElement = TextElement.createDefault(type);
    return addElement(newElement);
  }

  ScreenTextConfig copyWith({
    Map<TextFieldType, TextElement>? elements,
  }) {
    return ScreenTextConfig(
      elements: elements ?? this.elements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'elements': elements.map(
        (key, value) => MapEntry(key.id, value.toJson()),
      ),
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

    return ScreenTextConfig(elements: elements);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScreenTextConfig && _mapEquals(other.elements, elements);
  }

  @override
  int get hashCode {
    return elements.hashCode;
  }

  @override
  String toString() {
    return 'ScreenTextConfig(elements: $elements)';
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
