import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class DeviceSelector extends StatefulWidget {
  const DeviceSelector({
    super.key,
    required this.selectedPlatform,
    required this.onChanged,
    this.initialDevices = const <String>[],
  });

  final String? selectedPlatform;
  final ValueChanged<List<String>> onChanged;
  final List<String> initialDevices;

  @override
  State<DeviceSelector> createState() => _DeviceSelectorState();
}

class _DeviceSelectorState extends State<DeviceSelector> {
  late List<String> _devices;

  @override
  void initState() {
    super.initState();
    _devices = [...widget.initialDevices];
  }

  @override
  void didUpdateWidget(covariant DeviceSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPlatform != widget.selectedPlatform ||
        oldWidget.initialDevices != widget.initialDevices) {
      // Sync internal state from new props; no callbacks during build
      _devices = [...widget.initialDevices];
    }
  }

  void _toggle(String device) {
    setState(() {
      if (_devices.contains(device)) {
        _devices.remove(device);
      } else {
        _devices.add(device);
      }
    });
    widget.onChanged(_devices);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedPlatform == null) {
      return const Text('Select a platform to choose devices');
    }
    final devices = AppConstants.devicesByPlatform[widget.selectedPlatform] ??
        const <String>[];
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (final device in devices)
          FilterChip(
            label: Text(device),
            selected: _devices.contains(device),
            onSelected: (_) => _toggle(device),
          ),
      ],
    );
  }
}
