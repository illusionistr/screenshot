import 'package:flutter/material.dart';

class RTLService {
  static const Set<String> _rtlLanguageCodes = {
    'ar',  // Arabic
    'he',  // Hebrew
    'fa',  // Persian/Farsi
    'ur',  // Urdu
    'ku',  // Kurdish
    'ps',  // Pashto
    'sd',  // Sindhi
    'yi',  // Yiddish
    'arc', // Aramaic
    'ckb', // Central Kurdish
    'dv',  // Divehi/Maldivian
    'glk', // Gilaki
    'lrc', // Northern Luri
    'mzn', // Mazandarani
    'pnb', // Western Punjabi
  };

  /// Check if a language code represents an RTL language
  static bool isRTL(String languageCode) {
    final normalizedCode = languageCode.toLowerCase().split('-').first;
    return _rtlLanguageCodes.contains(normalizedCode);
  }

  /// Get the appropriate TextDirection for a language
  static TextDirection getTextDirection(String languageCode) {
    return isRTL(languageCode) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get the appropriate TextAlign for a language when centering is desired
  static TextAlign getCenterAlign(String languageCode) {
    // Center alignment works the same for both LTR and RTL
    return TextAlign.center;
  }

  /// Get the appropriate TextAlign for a language when start alignment is desired
  static TextAlign getStartAlign(String languageCode) {
    return isRTL(languageCode) ? TextAlign.right : TextAlign.left;
  }

  /// Get the appropriate TextAlign for a language when end alignment is desired
  static TextAlign getEndAlign(String languageCode) {
    return isRTL(languageCode) ? TextAlign.left : TextAlign.right;
  }

  /// Convert a TextAlign to be appropriate for the given language direction
  static TextAlign convertTextAlign(TextAlign align, String languageCode) {
    if (!isRTL(languageCode)) {
      return align; // No conversion needed for LTR languages
    }

    // Convert alignment for RTL languages
    switch (align) {
      case TextAlign.left:
        return TextAlign.right;
      case TextAlign.right:
        return TextAlign.left;
      case TextAlign.start:
        return TextAlign.right; // Start becomes right in RTL
      case TextAlign.end:
        return TextAlign.left;  // End becomes left in RTL
      case TextAlign.center:
      case TextAlign.justify:
        return align; // These remain the same
    }
  }

  /// Get the appropriate MainAxisAlignment for RTL layouts
  static MainAxisAlignment getMainAxisAlignment(MainAxisAlignment alignment, String languageCode) {
    if (!isRTL(languageCode)) {
      return alignment; // No conversion needed for LTR languages
    }

    // Convert alignment for RTL languages
    switch (alignment) {
      case MainAxisAlignment.start:
        return MainAxisAlignment.end;
      case MainAxisAlignment.end:
        return MainAxisAlignment.start;
      case MainAxisAlignment.center:
      case MainAxisAlignment.spaceAround:
      case MainAxisAlignment.spaceBetween:
      case MainAxisAlignment.spaceEvenly:
        return alignment; // These remain the same
    }
  }

  /// Get the appropriate CrossAxisAlignment for RTL layouts
  static CrossAxisAlignment getCrossAxisAlignment(CrossAxisAlignment alignment, String languageCode) {
    if (!isRTL(languageCode)) {
      return alignment; // No conversion needed for LTR languages
    }

    // Convert alignment for RTL languages
    switch (alignment) {
      case CrossAxisAlignment.start:
        return CrossAxisAlignment.end;
      case CrossAxisAlignment.end:
        return CrossAxisAlignment.start;
      case CrossAxisAlignment.center:
      case CrossAxisAlignment.stretch:
      case CrossAxisAlignment.baseline:
        return alignment; // These remain the same
    }
  }

  /// Wrap a widget with proper directionality for the given language
  static Widget wrapWithDirectionality(Widget child, String languageCode) {
    return Directionality(
      textDirection: getTextDirection(languageCode),
      child: child,
    );
  }

  /// Get appropriate EdgeInsets for RTL layout
  static EdgeInsets convertEdgeInsets(EdgeInsets insets, String languageCode) {
    if (!isRTL(languageCode)) {
      return insets; // No conversion needed for LTR languages
    }

    // Flip horizontal insets for RTL
    return EdgeInsets.fromLTRB(
      insets.right, // left becomes right
      insets.top,
      insets.left,  // right becomes left
      insets.bottom,
    );
  }

  /// Get the appropriate icon for directional navigation
  static IconData getDirectionalIcon(IconData ltrIcon, IconData rtlIcon, String languageCode) {
    return isRTL(languageCode) ? rtlIcon : ltrIcon;
  }

  /// Common directional icon mappings
  static IconData getBackIcon(String languageCode) {
    return getDirectionalIcon(Icons.arrow_back, Icons.arrow_forward, languageCode);
  }

  static IconData getForwardIcon(String languageCode) {
    return getDirectionalIcon(Icons.arrow_forward, Icons.arrow_back, languageCode);
  }

  static IconData getChevronLeftIcon(String languageCode) {
    return getDirectionalIcon(Icons.chevron_left, Icons.chevron_right, languageCode);
  }

  static IconData getChevronRightIcon(String languageCode) {
    return getDirectionalIcon(Icons.chevron_right, Icons.chevron_left, languageCode);
  }
}