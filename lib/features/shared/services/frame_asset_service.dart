import 'package:flutter/services.dart';

import '../data/frame_variants_data.dart';
import '../models/frame_variant_model.dart';

class FrameAssetService {
  FrameAssetService._();

  // Cache for asset availability to avoid repeated checks
  static final Map<String, bool> _assetAvailabilityCache = {};

  /// Check if a frame asset is available at runtime
  static Future<bool> isFrameAssetAvailable(String? assetPath) async {
    if (assetPath == null) return false;

    // Check cache first
    if (_assetAvailabilityCache.containsKey(assetPath)) {
      return _assetAvailabilityCache[assetPath]!;
    }

    try {
      // Try to load the asset to check if it exists
      await rootBundle.load(assetPath);
      _assetAvailabilityCache[assetPath] = true;
      return true;
    } catch (e) {
      _assetAvailabilityCache[assetPath] = false;
      return false;
    }
  }

  /// Get available frame variants for a device, filtering out unavailable assets
  static Future<List<FrameVariantModel>> getAvailableFrameVariants(
      String deviceId) async {
    final allVariants = FrameVariantsData.getFrameVariantsByDeviceId(deviceId);
    final availableVariants = <FrameVariantModel>[];

    for (final variant in allVariants) {
      if (variant.isGeneric) {
        // Generic frames are always available
        availableVariants.add(variant);
      } else if (variant.assetPath != null) {
        // Check if real frame asset is available
        final isAvailable = await isFrameAssetAvailable(variant.assetPath);
        if (isAvailable) {
          availableVariants.add(variant);
        }
      }
    }

    return availableVariants;
  }

  /// Get the best available frame variant for a device
  static Future<FrameVariantModel?> getBestAvailableFrameVariant(
      String deviceId) async {
    final availableVariants = await getAvailableFrameVariants(deviceId);

    if (availableVariants.isEmpty) return null;

    // Prioritize real frames over generic ones
    final realFrames = availableVariants.where((v) => !v.isGeneric).toList();
    if (realFrames.isNotEmpty) {
      return realFrames.first;
    }

    // Fallback to generic frame
    final genericFrames = availableVariants.where((v) => v.isGeneric).toList();
    return genericFrames.isNotEmpty ? genericFrames.first : null;
  }

  /// Get a specific frame variant if available, otherwise return generic
  static Future<FrameVariantModel?> getFrameVariantWithFallback(
      String deviceId, String variantId) async {
    final variant = FrameVariantsData.getFrameVariantById(deviceId, variantId);
    if (variant == null) return null;

    if (variant.isGeneric) {
      return variant;
    }

    if (variant.assetPath != null) {
      final isAvailable = await isFrameAssetAvailable(variant.assetPath);
      if (isAvailable) {
        return variant;
      }
    }

    // Fallback to generic frame
    return FrameVariantsData.getFrameVariantsByDeviceId(deviceId)
        .where((v) => v.isGeneric)
        .firstOrNull;
  }

  /// Check if a device has any real frame variants available
  static Future<bool> hasRealFrameVariants(String deviceId) async {
    final availableVariants = await getAvailableFrameVariants(deviceId);
    return availableVariants.any((v) => !v.isGeneric);
  }

  /// Get only the real frame variants that are available
  static Future<List<FrameVariantModel>> getAvailableRealFrameVariants(
      String deviceId) async {
    final availableVariants = await getAvailableFrameVariants(deviceId);
    return availableVariants.where((v) => !v.isGeneric).toList();
  }

  /// Clear the asset availability cache (useful for testing or when assets change)
  static void clearCache() {
    _assetAvailabilityCache.clear();
  }

  /// Preload asset availability for a list of frame variants
  static Future<void> preloadAssetAvailability(
      List<FrameVariantModel> variants) async {
    for (final variant in variants) {
      if (variant.assetPath != null && !variant.isGeneric) {
        await isFrameAssetAvailable(variant.assetPath);
      }
    }
  }
}
