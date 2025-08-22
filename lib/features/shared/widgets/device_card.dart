import 'package:flutter/material.dart';

import '../models/device_model.dart';
import '../models/frame_variant_model.dart';
import '../services/device_service.dart';

class DeviceCard extends StatefulWidget {
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
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  FrameVariantModel? _currentFrame;
  bool _isLoadingFrame = true;

  @override
  void initState() {
    super.initState();
    _loadFrameVariant();
  }

  @override
  void didUpdateWidget(DeviceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFrame != widget.selectedFrame || 
        oldWidget.device.id != widget.device.id) {
      _loadFrameVariant();
    }
  }

  Future<void> _loadFrameVariant() async {
    setState(() {
      _isLoadingFrame = true;
    });

    try {
      final frame = widget.selectedFrame ?? 
          await DeviceService.getDefaultFrameVariant(widget.device.id);
      setState(() {
        _currentFrame = frame;
        _isLoadingFrame = false;
      });
    } catch (e) {
      setState(() {
        _currentFrame = null;
        _isLoadingFrame = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final frameVariants = DeviceService.getFrameVariants(widget.device.id);

    return Card(
      elevation: widget.isSelected ? 8 : 2,
      color: widget.isSelected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(widget.compact ? 6.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: widget.compact ? 20 : 32,
                    height: widget.compact ? 20 : 32,
                    decoration: BoxDecoration(
                      color: widget.device.platform == Platform.ios
                          ? Colors.grey.shade200
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      widget.device.platform == Platform.ios
                          ? Icons.phone_iphone
                          : Icons.android,
                      color: widget.device.platform == Platform.ios
                          ? Colors.grey.shade600
                          : Colors.green.shade700,
                      size: widget.compact ? 12 : 18,
                    ),
                  ),
                  SizedBox(width: widget.compact ? 6 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.device.name,
                          style: (widget.compact
                                  ? theme.textTheme.bodyMedium
                                  : theme.textTheme.titleMedium)
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: widget.isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${widget.device.platform.displayName} • ${widget.device.appStoreDisplaySize}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: widget.isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.7)
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                            fontSize: widget.compact ? 10 : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.compact) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${widget.device.screenWidth}×${widget.device.screenHeight}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: widget.isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.7)
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                              fontSize: 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: widget.compact ? 16 : 20,
                    ),
                ],
              ),
              if (widget.showSpecs && !widget.compact) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SpecItem(
                        label: 'Screen',
                        value: '${widget.device.screenWidth}×${widget.device.screenHeight}',
                      ),
                    ),
                    Expanded(
                      child: _SpecItem(
                        label: 'Platform',
                        value: widget.device.platform.displayName,
                      ),
                    ),
                    Expanded(
                      child: _SpecItem(
                        label: 'Type',
                        value: widget.device.isTablet ? 'Tablet' : 'Phone',
                      ),
                    ),
                  ],
                ),
                if (frameVariants.isNotEmpty &&
                    _currentFrame != null &&
                    !widget.compact) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Frame: ${_currentFrame!.name}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
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
