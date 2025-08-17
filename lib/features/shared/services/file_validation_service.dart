import 'dart:html' as html;
import 'dart:typed_data';

import '../models/screenshot_model.dart';

class FileValidationService {
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB in bytes
  
  static const List<String> allowedMimeTypes = [
    'image/png',
    'image/jpeg',
    'image/jpg',
  ];

  /// Validate file type
  static bool isValidFileType(String? mimeType) {
    if (mimeType == null) return false;
    return allowedMimeTypes.contains(mimeType.toLowerCase());
  }

  /// Validate file size
  static bool isValidFileSize(int fileSize) {
    return fileSize <= maxFileSize;
  }

  /// Get file extension from filename
  static String getFileExtension(String filename) {
    final parts = filename.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return 'png'; // Default extension
  }

  /// Comprehensive file validation
  static FileValidationResult validateFile(html.File file) {
    final errors = <String>[];

    // Check file type
    if (!isValidFileType(file.type)) {
      errors.add('Invalid file type. Only PNG, JPG, and JPEG files are allowed.');
    }

    // Check file size
    if (!isValidFileSize(file.size)) {
      final sizeMB = (file.size / (1024 * 1024)).toStringAsFixed(1);
      errors.add('File size too large ($sizeMB MB). Maximum size is 10MB.');
    }

    // Check filename
    if (file.name.isEmpty) {
      errors.add('Filename cannot be empty.');
    }

    return FileValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Convert HTML File to Uint8List
  static Future<Uint8List> fileToBytes(html.File file) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    
    await reader.onLoad.first;
    
    return Uint8List.fromList(reader.result as List<int>);
  }

  /// Get image dimensions from bytes
  static Future<Dimensions> getImageDimensions(Uint8List bytes) async {
    // Create a temporary image element to get dimensions
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrl(blob);
    
    try {
      final image = html.ImageElement();
      image.src = url;
      
      // Wait for image to load
      await image.onLoad.first;
      
      return Dimensions(
        width: image.naturalWidth,
        height: image.naturalHeight,
      );
    } finally {
      html.Url.revokeObjectUrl(url);
    }
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

class FileValidationResult {
  final bool isValid;
  final List<String> errors;

  const FileValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get errorMessage => errors.join(' ');
}