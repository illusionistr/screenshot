import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../models/frame_variant_model.dart';
import '../services/device_service.dart';

class FrameSelector extends StatelessWidget {
  final String deviceId;
  final String? selectedFrameId;
  final ValueChanged<String> onFrameSelected;
  final bool showFrameNames;
  final Axis direction;

  const FrameSelector({
    super.key,
    required this.deviceId,
    this.selectedFrameId,
    required this.onFrameSelected,
    this.showFrameNames = true,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final frameVariants = DeviceService.getFrameVariants(deviceId);
    final device = DeviceService.getDeviceById(deviceId);
    
    if (frameVariants.isEmpty || device == null) {
      return const SizedBox.shrink();
    }

    if (direction == Axis.horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: frameVariants.map((frame) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _FrameVariantCard(
                frame: frame,
                device: device,
                isSelected: selectedFrameId == frame.id,
                onTap: () => onFrameSelected(frame.id),
                showName: showFrameNames,
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return Column(
        children: frameVariants.map((frame) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FrameVariantCard(
              frame: frame,
              device: device,
              isSelected: selectedFrameId == frame.id,
              onTap: () => onFrameSelected(frame.id),
              showName: showFrameNames,
              isWide: true,
            ),
          );
        }).toList(),
      );
    }
  }
}

class _FrameVariantCard extends StatelessWidget {
  final FrameVariantModel frame;
  final DeviceModel device;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showName;
  final bool isWide;

  const _FrameVariantCard({
    required this.frame,
    required this.device,
    required this.isSelected,
    required this.onTap,
    this.showName = true,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: isWide ? double.infinity : 120,
      child: Card(
        elevation: isSelected ? 4 : 1,
        color: isSelected ? theme.colorScheme.primaryContainer : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isWide ? 60 : 48,
                  height: isWide ? 80 : 64,
                  decoration: BoxDecoration(
                    color: _getFramePreviewColor(),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: isWide ? 40 : 32,
                      height: isWide ? 56 : 44,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(device.isTablet ? 8 : 6),
                      ),
                    ),
                  ),
                ),
                
                if (showName) ...[
                  const SizedBox(height: 8),
                  Text(
                    frame.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? theme.colorScheme.onPrimaryContainer : null,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getFramePreviewColor() {
    final frameName = frame.name.toLowerCase();
    
    if (frameName.contains('black') || frameName.contains('midnight') || 
        frameName.contains('obsidian') || frameName.contains('space')) {
      return Colors.grey.shade800;
    } else if (frameName.contains('white') || frameName.contains('silver') ||
               frameName.contains('starlight') || frameName.contains('porcelain')) {
      return Colors.grey.shade200;
    } else if (frameName.contains('gold')) {
      return Colors.amber.shade200;
    } else if (frameName.contains('blue') || frameName.contains('bay')) {
      return Colors.blue.shade300;
    } else if (frameName.contains('purple') || frameName.contains('violet')) {
      return Colors.purple.shade300;
    } else if (frameName.contains('red')) {
      return Colors.red.shade300;
    } else if (frameName.contains('green') || frameName.contains('emerald')) {
      return Colors.green.shade300;
    } else if (frameName.contains('titanium')) {
      return Colors.grey.shade400;
    } else if (frameName.contains('pink') || frameName.contains('rose')) {
      return Colors.pink.shade200;
    } else if (frameName.contains('yellow') || frameName.contains('amber')) {
      return Colors.yellow.shade300;
    } else {
      return Colors.grey.shade300;
    }
  }
}

class FrameDropdown extends StatelessWidget {
  final String deviceId;
  final String? selectedFrameId;
  final ValueChanged<String> onFrameSelected;
  final String? hint;

  const FrameDropdown({
    super.key,
    required this.deviceId,
    this.selectedFrameId,
    required this.onFrameSelected,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final frameVariants = DeviceService.getFrameVariants(deviceId);
    
    if (frameVariants.isEmpty) {
      return const SizedBox.shrink();
    }

    return DropdownButtonFormField<String>(
      value: selectedFrameId,
      hint: Text(hint ?? 'Select frame'),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: frameVariants.map((frame) {
        return DropdownMenuItem<String>(
          value: frame.id,
          child: Text(frame.name),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onFrameSelected(value);
        }
      },
    );
  }
}