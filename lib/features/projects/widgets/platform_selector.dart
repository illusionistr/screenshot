import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../shared/models/device_model.dart';

class PlatformSelector extends StatefulWidget {
  const PlatformSelector({
    super.key,
    required this.onChanged,
    this.initialSelection = const <String>[],
  });

  final void Function(List<String> selected) onChanged;
  final List<String> initialSelection;

  @override
  State<PlatformSelector> createState() => _PlatformSelectorState();
}

class _PlatformSelectorState extends State<PlatformSelector> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = [...widget.initialSelection];
  }

  void _toggle(String platform) {
    setState(() {
      if (_selected.contains(platform)) {
        _selected.remove(platform);
      } else {
        _selected.add(platform);
      }
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Platform.values.map((platform) {
        final isActive = _selected.contains(platform.id);
        return Expanded(
          child: InkWell(
            onTap: () => _toggle(platform.id),
            child: Card(
              color: isActive ? AppConstants.primaryColor.withValues(alpha: 0.1) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      platform == Platform.android ? Icons.android : Icons.apple,
                      color: isActive ? AppConstants.primaryColor : Colors.grey[700],
                    ),
                    const SizedBox(width: 8),
                    Text(platform.displayName.toUpperCase()),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}


