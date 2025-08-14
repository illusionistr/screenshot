class UploadConstants {
  UploadConstants._();

  // File size limits
  static const int maxFileSizeBytes = 1024 * 1024; // 1MB
  static const int thumbnailTargetSizeBytes = 400 * 1024; // 400KB target (within 300-500KB range)
  static const int thumbnailMaxSizeBytes = 500 * 1024; // 500KB max

  // Allowed file formats
  static const List<String> allowedExtensions = ['png', 'jpg', 'jpeg'];
  static const List<String> allowedMimeTypes = [
    'image/png',
    'image/jpeg',
    'image/jpg',
  ];

  // JPEG compression settings
  static const int jpegQualityHigh = 95; // For originals
  static const int jpegQualityMedium = 85; // For thumbnails
  static const int jpegQualityLow = 70; // Fallback if still too large

  // Storage paths
  static const String screenshotsBasePath = 'screenshots';
  static const String originalsSubpath = 'originals';
  static const String thumbnailsSubpath = 'thumbnails';

  // File naming
  static const String originalSuffix = '_original';
  static const String thumbnailSuffix = '_thumb';

  // Validation messages
  static const String errorFileTooLarge = 'File size must be less than 1MB';
  static const String errorInvalidFormat = 'Only PNG and JPEG files are allowed';
  static const String errorUploadFailed = 'Failed to upload screenshot';
  static const String errorCompressionFailed = 'Failed to process image';
}