import '../models/frame_variant_model.dart';

class FrameVariantsData {
  FrameVariantsData._();

  static const List<FrameVariantModel> allFrameVariants = [
    // iPhone 15 Pro variants
    FrameVariantModel(
      id: 'natural-titanium',
      name: 'Natural Titanium',
      assetPath: 'assets/frames/iphone-15-pro/natural-titanium.png',
      deviceId: 'iphone-15-pro',
    ),
    FrameVariantModel(
      id: 'blue-titanium',
      name: 'Blue Titanium',
      assetPath: 'assets/frames/iphone-15-pro/blue-titanium.png',
      deviceId: 'iphone-15-pro',
    ),
    FrameVariantModel(
      id: 'white-titanium',
      name: 'White Titanium',
      assetPath: 'assets/frames/iphone-15-pro/white-titanium.png',
      deviceId: 'iphone-15-pro',
    ),
    FrameVariantModel(
      id: 'black-titanium',
      name: 'Black Titanium',
      assetPath: 'assets/frames/iphone-15-pro/black-titanium.png',
      deviceId: 'iphone-15-pro',
    ),

    // iPhone 15 Pro Max variants (same colors, different device)
    FrameVariantModel(
      id: 'natural-titanium',
      name: 'Natural Titanium',
      assetPath: 'assets/frames/iphone-15-pro-max/natural-titanium.png',
      deviceId: 'iphone-15-pro-max',
    ),
    FrameVariantModel(
      id: 'blue-titanium',
      name: 'Blue Titanium',
      assetPath: 'assets/frames/iphone-15-pro-max/blue-titanium.png',
      deviceId: 'iphone-15-pro-max',
    ),
    FrameVariantModel(
      id: 'white-titanium',
      name: 'White Titanium',
      assetPath: 'assets/frames/iphone-15-pro-max/white-titanium.png',
      deviceId: 'iphone-15-pro-max',
    ),
    FrameVariantModel(
      id: 'black-titanium',
      name: 'Black Titanium',
      assetPath: 'assets/frames/iphone-15-pro-max/black-titanium.png',
      deviceId: 'iphone-15-pro-max',
    ),

    // iPhone 14 variants
    FrameVariantModel(
      id: 'blue',
      name: 'Blue',
      assetPath: 'assets/frames/iphone-14/blue.png',
      deviceId: 'iphone-14',
    ),
    FrameVariantModel(
      id: 'purple',
      name: 'Purple',
      assetPath: 'assets/frames/iphone-14/purple.png',
      deviceId: 'iphone-14',
    ),
    FrameVariantModel(
      id: 'midnight',
      name: 'Midnight',
      assetPath: 'assets/frames/iphone-14/midnight.png',
      deviceId: 'iphone-14',
    ),
    FrameVariantModel(
      id: 'starlight',
      name: 'Starlight',
      assetPath: 'assets/frames/iphone-14/starlight.png',
      deviceId: 'iphone-14',
    ),
    FrameVariantModel(
      id: 'red',
      name: '(PRODUCT)RED',
      assetPath: 'assets/frames/iphone-14/red.png',
      deviceId: 'iphone-14',
    ),

    // iPhone 14 Pro variants
    FrameVariantModel(
      id: 'deep-purple',
      name: 'Deep Purple',
      assetPath: 'assets/frames/iphone-14-pro/deep-purple.png',
      deviceId: 'iphone-14-pro',
    ),
    FrameVariantModel(
      id: 'gold',
      name: 'Gold',
      assetPath: 'assets/frames/iphone-14-pro/gold.png',
      deviceId: 'iphone-14-pro',
    ),
    FrameVariantModel(
      id: 'silver',
      name: 'Silver',
      assetPath: 'assets/frames/iphone-14-pro/silver.png',
      deviceId: 'iphone-14-pro',
    ),
    FrameVariantModel(
      id: 'space-black',
      name: 'Space Black',
      assetPath: 'assets/frames/iphone-14-pro/space-black.png',
      deviceId: 'iphone-14-pro',
    ),

    // iPhone 14 Pro Max variants (same colors, different device)
    FrameVariantModel(
      id: 'deep-purple',
      name: 'Deep Purple',
      assetPath: 'assets/frames/iphone-14-pro-max/deep-purple.png',
      deviceId: 'iphone-14-pro-max',
    ),
    FrameVariantModel(
      id: 'gold',
      name: 'Gold',
      assetPath: 'assets/frames/iphone-14-pro-max/gold.png',
      deviceId: 'iphone-14-pro-max',
    ),
    FrameVariantModel(
      id: 'silver',
      name: 'Silver',
      assetPath: 'assets/frames/iphone-14-pro-max/silver.png',
      deviceId: 'iphone-14-pro-max',
    ),
    FrameVariantModel(
      id: 'space-black',
      name: 'Space Black',
      assetPath: 'assets/frames/iphone-14-pro-max/space-black.png',
      deviceId: 'iphone-14-pro-max',
    ),

    // iPad Pro 12.9" variants
    FrameVariantModel(
      id: 'silver',
      name: 'Silver',
      assetPath: 'assets/frames/ipad-pro-12-9/silver.png',
      deviceId: 'ipad-pro-12-9',
    ),
    FrameVariantModel(
      id: 'space-gray',
      name: 'Space Gray',
      assetPath: 'assets/frames/ipad-pro-12-9/space-gray.png',
      deviceId: 'ipad-pro-12-9',
    ),

    // iPad Pro 11" variants
    FrameVariantModel(
      id: 'silver',
      name: 'Silver',
      assetPath: 'assets/frames/ipad-pro-11/silver.png',
      deviceId: 'ipad-pro-11',
    ),
    FrameVariantModel(
      id: 'space-gray',
      name: 'Space Gray',
      assetPath: 'assets/frames/ipad-pro-11/space-gray.png',
      deviceId: 'ipad-pro-11',
    ),

    // Pixel 8 Pro variants
    FrameVariantModel(
      id: 'obsidian',
      name: 'Obsidian',
      assetPath: 'assets/frames/pixel-8-pro/obsidian.png',
      deviceId: 'pixel-8-pro',
    ),
    FrameVariantModel(
      id: 'porcelain',
      name: 'Porcelain',
      assetPath: 'assets/frames/pixel-8-pro/porcelain.png',
      deviceId: 'pixel-8-pro',
    ),
    FrameVariantModel(
      id: 'bay',
      name: 'Bay',
      assetPath: 'assets/frames/pixel-8-pro/bay.png',
      deviceId: 'pixel-8-pro',
    ),

    // Pixel 8 variants
    FrameVariantModel(
      id: 'obsidian',
      name: 'Obsidian',
      assetPath: 'assets/frames/pixel-8/obsidian.png',
      deviceId: 'pixel-8',
    ),
    FrameVariantModel(
      id: 'hazel',
      name: 'Hazel',
      assetPath: 'assets/frames/pixel-8/hazel.png',
      deviceId: 'pixel-8',
    ),
    FrameVariantModel(
      id: 'rose',
      name: 'Rose',
      assetPath: 'assets/frames/pixel-8/rose.png',
      deviceId: 'pixel-8',
    ),

    // Galaxy S24 Ultra variants
    FrameVariantModel(
      id: 'titanium-black',
      name: 'Titanium Black',
      assetPath: 'assets/frames/galaxy-s24-ultra/titanium-black.png',
      deviceId: 'galaxy-s24-ultra',
    ),
    FrameVariantModel(
      id: 'titanium-gray',
      name: 'Titanium Gray',
      assetPath: 'assets/frames/galaxy-s24-ultra/titanium-gray.png',
      deviceId: 'galaxy-s24-ultra',
    ),
    FrameVariantModel(
      id: 'titanium-violet',
      name: 'Titanium Violet',
      assetPath: 'assets/frames/galaxy-s24-ultra/titanium-violet.png',
      deviceId: 'galaxy-s24-ultra',
    ),
    FrameVariantModel(
      id: 'titanium-yellow',
      name: 'Titanium Yellow',
      assetPath: 'assets/frames/galaxy-s24-ultra/titanium-yellow.png',
      deviceId: 'galaxy-s24-ultra',
    ),

    // Galaxy S24 variants
    FrameVariantModel(
      id: 'onyx-black',
      name: 'Onyx Black',
      assetPath: 'assets/frames/galaxy-s24/onyx-black.png',
      deviceId: 'galaxy-s24',
    ),
    FrameVariantModel(
      id: 'marble-gray',
      name: 'Marble Gray',
      assetPath: 'assets/frames/galaxy-s24/marble-gray.png',
      deviceId: 'galaxy-s24',
    ),
    FrameVariantModel(
      id: 'cobalt-violet',
      name: 'Cobalt Violet',
      assetPath: 'assets/frames/galaxy-s24/cobalt-violet.png',
      deviceId: 'galaxy-s24',
    ),
    FrameVariantModel(
      id: 'amber-yellow',
      name: 'Amber Yellow',
      assetPath: 'assets/frames/galaxy-s24/amber-yellow.png',
      deviceId: 'galaxy-s24',
    ),
  ];

  static List<FrameVariantModel> getFrameVariantsByDeviceId(String deviceId) {
    return allFrameVariants.where((variant) => variant.deviceId == deviceId).toList();
  }

  static FrameVariantModel? getFrameVariantById(String deviceId, String variantId) {
    try {
      return allFrameVariants.firstWhere(
        (variant) => variant.deviceId == deviceId && variant.id == variantId,
      );
    } catch (e) {
      return null;
    }
  }

  static FrameVariantModel? getDefaultFrameVariant(String deviceId) {
    final variants = getFrameVariantsByDeviceId(deviceId);
    return variants.isNotEmpty ? variants.first : null;
  }

  static List<String> getFrameVariantIds(String deviceId) {
    return getFrameVariantsByDeviceId(deviceId).map((variant) => variant.id).toList();
  }
}