import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../shared/models/device_model.dart';
import '../../shared/services/device_service.dart';
import '../../shared/widgets/device_card.dart';

class DeviceSelector extends StatefulWidget {
  const DeviceSelector({
    super.key,
    required this.selectedPlatforms,
    required this.onChanged,
    this.initialSelection = const <String>[],
    this.useNewModel = true,
  });

  final List<String> selectedPlatforms;
  final void Function(List<String> selectedDeviceIds) onChanged;
  final List<String> initialSelection; // Now uses device IDs instead of platform -> device names
  final bool useNewModel; // For backward compatibility

  @override
  State<DeviceSelector> createState() => _DeviceSelectorState();
}

class _DeviceSelectorState extends State<DeviceSelector> {
  late List<String> _selectedDeviceIds;

  @override
  void initState() {
    super.initState();
    _selectedDeviceIds = List<String>.from(widget.initialSelection);
  }

  void _toggle(String deviceId) {
    setState(() {
      if (_selectedDeviceIds.contains(deviceId)) {
        _selectedDeviceIds.remove(deviceId);
      } else {
        _selectedDeviceIds.add(deviceId);
      }
    });
    widget.onChanged(_selectedDeviceIds);
  }

  List<DeviceModel> _getDevicesForPlatforms() {
    final devices = <DeviceModel>[];
    for (final platformId in widget.selectedPlatforms) {
      try {
        final platform = Platform.fromString(platformId);
        devices.addAll(DeviceService.getDevicesByPlatform(platform));
      } catch (e) {
        // Handle invalid platform ID gracefully
        continue;
      }
    }
    return devices;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useNewModel) {
      return _buildNewDeviceSelector();
    } else {
      return _buildLegacyDeviceSelector();
    }
  }

  Widget _buildNewDeviceSelector() {
    final availableDevices = _getDevicesForPlatforms();
    final groupedDevices = <Platform, List<DeviceModel>>{};
    
    for (final device in availableDevices) {
      groupedDevices.putIfAbsent(device.platform, () => []).add(device);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in groupedDevices.entries) ...[
          const SizedBox(height: 16),
          Text(
            entry.key.displayName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: entry.value.length,
            itemBuilder: (context, index) {
              final device = entry.value[index];
              return DeviceCard(
                device: device,
                isSelected: _selectedDeviceIds.contains(device.id),
                onTap: () => _toggle(device.id),
                compact: true,
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLegacyDeviceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final platform in widget.selectedPlatforms) ...[
          const SizedBox(height: 8),
          Text(platform.toUpperCase(), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              for (final device in AppConstants.devicesByPlatform[platform] ?? const <String>[])
                FilterChip(
                  label: Text(device),
                  selected: _selectedDeviceIds.contains(device),
                  onSelected: (_) => _toggle(device),
                ),
            ],
          ),
        ],
      ],
    );
  }
}


