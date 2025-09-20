# Frame System Implementation

## Overview

This document describes the new device-specific frame system that automatically falls back to generic frames when real frame assets are not available.

## Features

### 1. Asset Validation

- **Runtime Asset Checking**: The system checks if frame assets exist at runtime before trying to use them
- **Automatic Fallback**: If a real frame asset is missing, the system automatically falls back to a generic frame
- **Caching**: Asset availability is cached to avoid repeated checks

### 2. Smart Frame Selection

- **Real Frames First**: Real frame variants are prioritized over generic ones
- **Manual Override**: Users can manually select between real and generic frames
- **Visual Indicators**: UI shows clear indicators for real vs generic frames

### 3. Generic Frame Fallback

- **Simple Border/Outline**: Generic frames show a clean border/outline instead of being invisible
- **Device-Aware**: Generic frames adapt to device type (phone vs tablet)
- **Consistent Styling**: Maintains visual consistency across all devices

## Implementation Details

### Core Services

#### FrameAssetService

- `isFrameAssetAvailable(String? assetPath)`: Checks if a frame asset exists
- `getAvailableFrameVariants(String deviceId)`: Returns only available frame variants
- `getBestAvailableFrameVariant(String deviceId)`: Returns the best available frame variant
- `getFrameVariantWithFallback(String deviceId, String variantId)`: Gets specific variant or falls back to generic

#### DeviceService (Updated)

- `getAvailableFrameVariants(String deviceId)`: Async method for available variants
- `getDefaultFrameVariant(String deviceId)`: Async method for best available variant
- `getFrameVariantWithFallback(String deviceId, String variantId)`: Smart fallback logic

### Frame Rendering

#### FrameRenderer (Enhanced)

- `buildSmartFrameContainer()`: New method with asset validation and smart fallback
- `renderGenericFrame()`: Updated to show simple border/outline instead of being invisible
- `_renderRealFrame()`: Renders real device frames when available

### UI Components

#### FrameSelector (Enhanced)

- **Stateful Widget**: Now loads available frame variants asynchronously
- **Visual Indicators**: Green checkmark for real frames, orange info icon for generic
- **Smart Sorting**: Real frames appear first, then generic frames
- **Loading States**: Shows loading indicator while checking asset availability

#### FrameDropdown (Enhanced)

- **Async Loading**: Loads available variants asynchronously
- **Clear Labels**: Shows frame type (Real vs Generic) in dropdown items
- **Smart Sorting**: Prioritizes real frames over generic ones

## Usage

### 1. Basic Frame Selection

```dart
FrameSelector(
  deviceId: 'iphone-15-pro',
  selectedFrameId: 'natural-titanium',
  onFrameSelected: (frameId) {
    // Handle frame selection
  },
)
```

### 2. Smart Frame Container

```dart
FutureBuilder<Widget>(
  future: FrameRenderer.buildSmartFrameContainer(
    deviceId: deviceId,
    containerSize: size,
    selectedVariantId: frameVariant,
    screenshotPath: screenshotUrl,
  ),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return LoadingWidget();
    }
    return snapshot.data ?? GenericFrame();
  },
)
```

### 3. Asset Availability Check

```dart
final isAvailable = await FrameAssetService.isFrameAssetAvailable(assetPath);
if (isAvailable) {
  // Use real frame
} else {
  // Fall back to generic frame
}
```

## Asset Organization

### Folder Structure

All frame assets should follow this consistent folder structure:

```
assets/frames/
├── iphone-15-pro/
│   ├── natural-titanium.png
│   ├── blue-titanium.png
│   └── ...
├── pixel-8-pro/
│   ├── obsidian.png
│   ├── porcelain.png
│   └── ...
└── galaxy-s24-ultra/
    ├── titanium-black.png
    └── ...
```

### Naming Convention

- **Device folders**: Use kebab-case (e.g., `iphone-15-pro`, `pixel-8-pro`)
- **Frame files**: Use descriptive names (e.g., `natural-titanium.png`, `obsidian.png`)
- **Generic frames**: No asset path, marked with `isGeneric: true`

## Configuration

### Frame Variants Data

Update `lib/features/shared/data/frame_variants_data.dart` to include:

- Real frame variants with correct asset paths
- Generic frame variants as fallbacks
- Consistent device IDs matching your device models

### Asset Declaration

Ensure all frame assets are declared in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/frames/
```

## Benefits

1. **Automatic Fallback**: No more broken frames when assets are missing
2. **Better UX**: Users can see which frames are real vs generic
3. **Performance**: Asset availability is cached to avoid repeated checks
4. **Maintainability**: Consistent folder structure and naming conventions
5. **Scalability**: Easy to add new frame variants and devices

## Future Enhancements

1. **Asset Preloading**: Preload frame assets for better performance
2. **Dynamic Asset Updates**: Support for runtime asset updates
3. **Frame Preview**: Show actual frame previews in selector
4. **Custom Frame Support**: Allow users to upload custom frames
5. **Frame Categories**: Group frames by style, color, or theme

## Troubleshooting

### Common Issues

1. **Frame Not Showing**: Check if asset path is correct and asset exists
2. **Generic Frame Always Used**: Verify asset availability with `FrameAssetService.isFrameAssetAvailable()`
3. **Performance Issues**: Clear asset cache with `FrameAssetService.clearCache()`
4. **Import Errors**: Ensure all services are properly imported

### Debug Information

Enable debug logging to see frame selection decisions:

```dart
print('DEBUG: Frame variant: ${frameVariant?.name}');
print('DEBUG: Asset available: ${await FrameAssetService.isFrameAssetAvailable(assetPath)}');
```
