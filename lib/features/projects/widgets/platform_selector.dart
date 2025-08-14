import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

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
      children: AppConstants.supportedPlatforms.map((p) {
        final isActive = _selected.contains(p);
        return Expanded(
          child: InkWell(
            onTap: () => _toggle(p),
            child: Card(
              color: isActive ? AppConstants.primaryColor.withValues(alpha: 0.1) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(p == 'android' ? Icons.android : Icons.apple,
                        color: isActive ? AppConstants.primaryColor : Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(p.toUpperCase()),
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


