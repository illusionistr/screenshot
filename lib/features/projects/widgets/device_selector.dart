import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class DeviceSelector extends StatefulWidget {
  const DeviceSelector({
    super.key,
    required this.selectedPlatforms,
    required this.onChanged,
    this.initialSelection = const <String, List<String>>{},
  });

  final List<String> selectedPlatforms;
  final void Function(Map<String, List<String>> selections) onChanged;
  final Map<String, List<String>> initialSelection;

  @override
  State<DeviceSelector> createState() => _DeviceSelectorState();
}

class _DeviceSelectorState extends State<DeviceSelector> {
  late Map<String, List<String>> _selection;

  @override
  void initState() {
    super.initState();
    _selection = {
      for (final platform in AppConstants.supportedPlatforms)
        platform: List<String>.from(widget.initialSelection[platform] ?? const <String>[]),
    };
  }

  void _toggle(String platform, String device) {
    setState(() {
      final list = _selection[platform] ?? <String>[];
      if (list.contains(device)) {
        list.remove(device);
      } else {
        list.add(device);
      }
      _selection[platform] = list;
    });
    widget.onChanged(_selection);
  }

  @override
  Widget build(BuildContext context) {
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
                  selected: _selection[platform]?.contains(device) ?? false,
                  onSelected: (_) => _toggle(platform, device),
                ),
            ],
          ),
        ],
      ],
    );
  }
}


