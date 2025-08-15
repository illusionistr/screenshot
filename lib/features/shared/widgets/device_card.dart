import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../models/frame_variant_model.dart';
import '../services/device_service.dart';

class DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final bool isSelected;
  final VoidCallback? onTap;
  final FrameVariantModel? selectedFrame;
  final bool showSpecs;
  final bool compact;

  const DeviceCard({
    super.key,
    required this.device,
    this.isSelected = false,
    this.onTap,
    this.selectedFrame,
    this.showSpecs = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final frameVariants = DeviceService.getFrameVariants(device.id);
    final currentFrame =
        selectedFrame ?? DeviceService.getDefaultFrameVariant(device.id);

    return Card(
      elevation: isSelected ? 8 : 2,
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(compact ? 6.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: compact ? 20 : 32,
                    height: compact ? 20 : 32,
                    decoration: BoxDecoration(
                      color: device.platform == Platform.ios
                          ? Colors.grey.shade200
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      device.platform == Platform.ios
                          ? Icons.phone_iphone
                          : Icons.android,
                      color: device.platform == Platform.ios
                          ? Colors.grey.shade600
                          : Colors.green.shade700,
                      size: compact ? 12 : 18,
                    ),
                  ),
                  SizedBox(width: compact ? 6 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: (compact
                                  ? theme.textTheme.bodyMedium
                                  : theme.textTheme.titleMedium)
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${device.platform.displayName} • ${device.appStoreDisplaySize}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.7)
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                            fontSize: compact ? 10 : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (compact) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${device.screenWidth}×${device.screenHeight}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.6)
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: compact ? 14 : 20,
                    ),
                ],
              ),
              if (showSpecs && !compact) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Specifications',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _SpecItem(
                              label: 'Resolution',
                              value:
                                  '${device.screenWidth}×${device.screenHeight}',
                            ),
                          ),
                          Expanded(
                            child: _SpecItem(
                              label: 'Aspect Ratio',
                              value: device.aspectRatio.toStringAsFixed(2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: _SpecItem(
                              label: 'Type',
                              value: device.isTablet ? 'Tablet' : 'Phone',
                            ),
                          ),
                          Expanded(
                            child: _SpecItem(
                              label: 'Frames',
                              value: '${frameVariants.length} available',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              if (frameVariants.isNotEmpty &&
                  currentFrame != null &&
                  !compact) ...[
                const SizedBox(height: 12),
                Text(
                  'Frame: ${currentFrame.name}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final String label;
  final String value;

  const _SpecItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class DeviceListTile extends StatelessWidget {
  final DeviceModel device;
  final bool isSelected;
  final VoidCallback? onTap;

  const DeviceListTile({
    super.key,
    required this.device,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      selected: isSelected,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: device.platform == Platform.ios
              ? Colors.grey.shade200
              : Colors.green.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          device.platform == Platform.ios ? Icons.phone_iphone : Icons.android,
          color: device.platform == Platform.ios
              ? Colors.grey.shade600
              : Colors.green.shade700,
          size: 20,
        ),
      ),
      title: Text(device.name),
      subtitle: Text(
        '${device.platform.displayName} • ${device.appStoreDisplaySize} • ${device.screenWidth}×${device.screenHeight}',
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            )
          : null,
    );
  }
}
