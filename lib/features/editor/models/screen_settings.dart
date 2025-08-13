class ScreenSettings {
  final BackgroundSettings background;
  final LayoutSettings layout;
  final TextSettings text;
  final DeviceSettings device;
  final FontSettings font;

  const ScreenSettings({
    required this.background,
    required this.layout,
    required this.text,
    required this.device,
    required this.font,
  });

  ScreenSettings copyWith({
    BackgroundSettings? background,
    LayoutSettings? layout,
    TextSettings? text,
    DeviceSettings? device,
    FontSettings? font,
  }) {
    return ScreenSettings(
      background: background ?? this.background,
      layout: layout ?? this.layout,
      text: text ?? this.text,
      device: device ?? this.device,
      font: font ?? this.font,
    );
  }

  factory ScreenSettings.fromMap(Map<String, dynamic> map) {
    return ScreenSettings(
      background: BackgroundSettings.fromMap(map['background'] ?? {}),
      layout: LayoutSettings.fromMap(map['layout'] ?? {}),
      text: TextSettings.fromMap(map['text'] ?? {}),
      device: DeviceSettings.fromMap(map['device'] ?? {}),
      font: FontSettings.fromMap(map['font'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'background': background.toMap(),
      'layout': layout.toMap(),
      'text': text.toMap(),
      'device': device.toMap(),
      'font': font.toMap(),
    };
  }
}

class BackgroundSettings {
  final String type; // "color", "gradient", "image"
  final String? color;
  final String? gradientStart;
  final String? gradientEnd;
  final double? gradientAngle;

  const BackgroundSettings({
    required this.type,
    this.color,
    this.gradientStart,
    this.gradientEnd,
    this.gradientAngle,
  });

  BackgroundSettings copyWith({
    String? type,
    String? color,
    String? gradientStart,
    String? gradientEnd,
    double? gradientAngle,
  }) {
    return BackgroundSettings(
      type: type ?? this.type,
      color: color ?? this.color,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      gradientAngle: gradientAngle ?? this.gradientAngle,
    );
  }

  factory BackgroundSettings.fromMap(Map<String, dynamic> map) {
    return BackgroundSettings(
      type: map['type'] ?? 'gradient',
      color: map['color'],
      gradientStart: map['gradientStart'],
      gradientEnd: map['gradientEnd'],
      gradientAngle: map['gradientAngle']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'color': color,
      'gradientStart': gradientStart,
      'gradientEnd': gradientEnd,
      'gradientAngle': gradientAngle,
    };
  }
}

class LayoutSettings {
  final String mode; // "text_above", "text_below", etc.
  final String orientation; // "portrait", "landscape"
  final String frameStyle; // "flat_black", etc.

  const LayoutSettings({
    required this.mode,
    required this.orientation,
    required this.frameStyle,
  });

  LayoutSettings copyWith({
    String? mode,
    String? orientation,
    String? frameStyle,
  }) {
    return LayoutSettings(
      mode: mode ?? this.mode,
      orientation: orientation ?? this.orientation,
      frameStyle: frameStyle ?? this.frameStyle,
    );
  }

  factory LayoutSettings.fromMap(Map<String, dynamic> map) {
    return LayoutSettings(
      mode: map['mode'] ?? 'text_above',
      orientation: map['orientation'] ?? 'portrait',
      frameStyle: map['frameStyle'] ?? 'flat_black',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mode': mode,
      'orientation': orientation,
      'frameStyle': frameStyle,
    };
  }
}

class TextSettings {
  final String alignment; // "center", "left", "right"
  final double containerHeight; // percentage
  final Map<String, double> margins; // {"top": 2, "bottom": 2, "left": 10, "right": 10}
  final double angle;

  const TextSettings({
    required this.alignment,
    required this.containerHeight,
    required this.margins,
    required this.angle,
  });

  TextSettings copyWith({
    String? alignment,
    double? containerHeight,
    Map<String, double>? margins,
    double? angle,
  }) {
    return TextSettings(
      alignment: alignment ?? this.alignment,
      containerHeight: containerHeight ?? this.containerHeight,
      margins: margins ?? this.margins,
      angle: angle ?? this.angle,
    );
  }

  factory TextSettings.fromMap(Map<String, dynamic> map) {
    return TextSettings(
      alignment: map['alignment'] ?? 'center',
      containerHeight: map['containerHeight']?.toDouble() ?? 15.0,
      margins: Map<String, double>.from(
        map['margins'] ?? {'top': 2.0, 'bottom': 2.0, 'left': 10.0, 'right': 10.0}
      ),
      angle: map['angle']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'alignment': alignment,
      'containerHeight': containerHeight,
      'margins': margins,
      'angle': angle,
    };
  }
}

class DeviceSettings {
  final Map<String, double> margins; // {"top": 2, "bottom": 2, "left": 10, "right": 10}
  final double angle;

  const DeviceSettings({
    required this.margins,
    required this.angle,
  });

  DeviceSettings copyWith({
    Map<String, double>? margins,
    double? angle,
  }) {
    return DeviceSettings(
      margins: margins ?? this.margins,
      angle: angle ?? this.angle,
    );
  }

  factory DeviceSettings.fromMap(Map<String, dynamic> map) {
    return DeviceSettings(
      margins: Map<String, double>.from(
        map['margins'] ?? {'top': 2.0, 'bottom': 2.0, 'left': 10.0, 'right': 10.0}
      ),
      angle: map['angle']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'margins': margins,
      'angle': angle,
    };
  }
}

class FontSettings {
  final String family; // "Raleway", etc.
  final double size;
  final String weight; // "Regular", "Bold", etc.
  final String color;
  final double lineHeight;

  const FontSettings({
    required this.family,
    required this.size,
    required this.weight,
    required this.color,
    required this.lineHeight,
  });

  FontSettings copyWith({
    String? family,
    double? size,
    String? weight,
    String? color,
    double? lineHeight,
  }) {
    return FontSettings(
      family: family ?? this.family,
      size: size ?? this.size,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }

  factory FontSettings.fromMap(Map<String, dynamic> map) {
    return FontSettings(
      family: map['family'] ?? 'Raleway',
      size: map['size']?.toDouble() ?? 40.0,
      weight: map['weight'] ?? 'Regular',
      color: map['color'] ?? '#FFFFFF',
      lineHeight: map['lineHeight']?.toDouble() ?? 1.2,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'family': family,
      'size': size,
      'weight': weight,
      'color': color,
      'lineHeight': lineHeight,
    };
  }
}