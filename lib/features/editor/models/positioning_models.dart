import 'package:flutter/material.dart';

/// Horizontal anchor reference used for positioning elements
enum HorizontalAnchor {
  left,
  center,
  right,
}

/// Vertical anchor reference used for positioning elements
enum VerticalAnchor {
  top,
  center,
  bottom,
}

/// Unified transform/positioning specification for any visual element
/// - scale: relative scale to apply (e.g., device size multiplier or text size multiplier)
/// - rotationDeg: clockwise rotation in degrees
/// - hAnchor/vAnchor: base reference point in the container to measure offsets from
/// - hPercent/vPercent: offset from the anchor in [-1.0, 1.0] (i.e., -100% to +100% of container size)
class ElementTransform {
  final double scale;
  final double rotationDeg;
  final HorizontalAnchor hAnchor;
  final VerticalAnchor vAnchor;
  final double hPercent; // -1.0 to 1.0 of container width
  final double vPercent; // -1.0 to 1.0 of container height

  const ElementTransform({
    this.scale = 1.0,
    this.rotationDeg = 0.0,
    this.hAnchor = HorizontalAnchor.center,
    this.vAnchor = VerticalAnchor.center,
    this.hPercent = 0.0,
    this.vPercent = 0.0,
  });

  ElementTransform copyWith({
    double? scale,
    double? rotationDeg,
    HorizontalAnchor? hAnchor,
    VerticalAnchor? vAnchor,
    double? hPercent,
    double? vPercent,
  }) {
    return ElementTransform(
      scale: scale ?? this.scale,
      rotationDeg: rotationDeg ?? this.rotationDeg,
      hAnchor: hAnchor ?? this.hAnchor,
      vAnchor: vAnchor ?? this.vAnchor,
      hPercent: hPercent ?? this.hPercent,
      vPercent: vPercent ?? this.vPercent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scale': scale,
      'rotationDeg': rotationDeg,
      'hAnchor': hAnchor.name,
      'vAnchor': vAnchor.name,
      'hPercent': hPercent,
      'vPercent': vPercent,
    };
  }

  factory ElementTransform.fromJson(Map<String, dynamic> json) {
    return ElementTransform(
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      rotationDeg: (json['rotationDeg'] as num?)?.toDouble() ?? 0.0,
      hAnchor: _parseHAnchor(json['hAnchor'] as String?),
      vAnchor: _parseVAnchor(json['vAnchor'] as String?),
      hPercent: (json['hPercent'] as num?)?.toDouble() ?? 0.0,
      vPercent: (json['vPercent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static HorizontalAnchor _parseHAnchor(String? value) {
    switch (value) {
      case 'left':
        return HorizontalAnchor.left;
      case 'right':
        return HorizontalAnchor.right;
      case 'center':
      default:
        return HorizontalAnchor.center;
    }
  }

  static VerticalAnchor _parseVAnchor(String? value) {
    switch (value) {
      case 'top':
        return VerticalAnchor.top;
      case 'bottom':
        return VerticalAnchor.bottom;
      case 'center':
      default:
        return VerticalAnchor.center;
    }
  }

  /// Resolves the element center position based on container size and anchors.
  /// This does not account for the element's own size; callers should offset
  /// by half width/height as needed when positioning top-left corners.
  Offset resolveCenter(Size containerSize) {
    final baseX = switch (hAnchor) {
      HorizontalAnchor.left => 0.0,
      HorizontalAnchor.center => containerSize.width / 2,
      HorizontalAnchor.right => containerSize.width,
    };
    final baseY = switch (vAnchor) {
      VerticalAnchor.top => 0.0,
      VerticalAnchor.center => containerSize.height / 2,
      VerticalAnchor.bottom => containerSize.height,
    };
    final dx = hPercent * containerSize.width;
    final dy = vPercent * containerSize.height;
    return Offset(baseX + dx, baseY + dy);
  }
}

