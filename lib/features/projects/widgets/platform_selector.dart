import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class PlatformSelector extends StatefulWidget {
  const PlatformSelector({
    super.key,
    required this.onChanged,
    this.initialPlatform,
  });

  final ValueChanged<String> onChanged;
  final String? initialPlatform;

  @override
  State<PlatformSelector> createState() => _PlatformSelectorState();
}

class _PlatformSelectorState extends State<PlatformSelector> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialPlatform;
  }

  void _select(String platform) {
    setState(() => _selected = platform);
    widget.onChanged(platform);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppConstants.supportedPlatforms.map((p) {
        final isActive = _selected == p;
        return Expanded(
          child: InkWell(
            onTap: () => _select(p),
            child: Card(
              color: isActive
                  ? AppConstants.primaryColor.withValues(alpha: 0.1)
                  : Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<String>(
                      value: p,
                      groupValue: _selected,
                      onChanged: (_) => _select(p),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      p == 'android' ? Icons.android : Icons.apple,
                      color: isActive
                          ? AppConstants.primaryColor
                          : Colors.grey[700],
                    ),
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
