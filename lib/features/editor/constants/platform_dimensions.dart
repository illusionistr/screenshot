import '../../shared/models/device_model.dart';

enum DeviceType {
  iphonePortrait,
  iphoneLandscape,
  ipadPortrait,
  ipadLandscape,
  androidPhonePortrait,
  androidPhoneLandscape,
  androidTabletPortrait,
  androidTabletLandscape,
}

class PlatformDimensions {
  final int width;
  final int height;
  final double aspectRatio;
  final DeviceType deviceType;

  const PlatformDimensions({
    required this.width,
    required this.height,
    required this.deviceType,
  }) : aspectRatio = width / height;

  static const Map<DeviceType, PlatformDimensions> appStoreDimensions = {
    DeviceType.iphonePortrait: PlatformDimensions(
      width: 1290,
      height: 2796,
      deviceType: DeviceType.iphonePortrait,
    ),
    DeviceType.iphoneLandscape: PlatformDimensions(
      width: 2796,
      height: 1290,
      deviceType: DeviceType.iphoneLandscape,
    ),
    DeviceType.ipadPortrait: PlatformDimensions(
      width: 2064,
      height: 2752,
      deviceType: DeviceType.ipadPortrait,
    ),
    DeviceType.ipadLandscape: PlatformDimensions(
      width: 2752,
      height: 2064,
      deviceType: DeviceType.ipadLandscape,
    ),
    DeviceType.androidPhonePortrait: PlatformDimensions(
      width: 1080,
      height: 1920,
      deviceType: DeviceType.androidPhonePortrait,
    ),
    DeviceType.androidPhoneLandscape: PlatformDimensions(
      width: 1920,
      height: 1080,
      deviceType: DeviceType.androidPhoneLandscape,
    ),
    DeviceType.androidTabletPortrait: PlatformDimensions(
      width: 1080,
      height: 1920,
      deviceType: DeviceType.androidTabletPortrait,
    ),
    DeviceType.androidTabletLandscape: PlatformDimensions(
      width: 1920,
      height: 1080,
      deviceType: DeviceType.androidTabletLandscape,
    ),
  };

  static PlatformDimensions? getDimensionsByType(DeviceType deviceType) {
    return appStoreDimensions[deviceType];
  }

  static DeviceType getDeviceTypeFromDevice(DeviceModel device, {bool isLandscape = false}) {
    final isTablet = device.isTablet;
    final isIOS = device.platform == Platform.ios;

    if (isIOS) {
      if (isTablet) {
        return isLandscape ? DeviceType.ipadLandscape : DeviceType.ipadPortrait;
      } else {
        return isLandscape ? DeviceType.iphoneLandscape : DeviceType.iphonePortrait;
      }
    } else {
      if (isTablet) {
        return isLandscape ? DeviceType.androidTabletLandscape : DeviceType.androidTabletPortrait;
      } else {
        return isLandscape ? DeviceType.androidPhoneLandscape : DeviceType.androidPhonePortrait;
      }
    }
  }

  static PlatformDimensions getDimensionsForDevice(DeviceModel device, {bool isLandscape = false}) {
    final deviceType = getDeviceTypeFromDevice(device, isLandscape: isLandscape);
    return getDimensionsByType(deviceType) ?? appStoreDimensions[DeviceType.iphonePortrait]!;
  }

  double getWidthForHeight(double height) {
    return height * aspectRatio;
  }

  double getHeightForWidth(double width) {
    return width / aspectRatio;
  }

  @override
  String toString() {
    return 'PlatformDimensions(${width}x$height, ratio: ${aspectRatio.toStringAsFixed(2)}, type: $deviceType)';
  }
}