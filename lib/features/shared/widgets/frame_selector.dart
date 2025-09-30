import 'package:flutter/material.dart';

import '../models/device_model.dart';
import '../models/frame_variant_model.dart';
import '../services/device_service.dart';

class FrameSelector extends StatefulWidget {
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
  State<FrameSelector> createState() => _FrameSelectorState();
}

class _FrameSelectorState extends State<FrameSelector> {
  List<FrameVariantModel> _availableFrameVariants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableFrameVariants();
  }

  @override
  void didUpdateWidget(FrameSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deviceId != widget.deviceId) {
      _loadAvailableFrameVariants();
    }
  }

  Future<void> _loadAvailableFrameVariants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final variants =
          await DeviceService.getAvailableFrameVariants(widget.deviceId);
      setState(() {
        _availableFrameVariants = variants;
        _isLoading = false;
      });

      // If no frame is selected and we have variants, select the first one
      if (widget.selectedFrameId == null || widget.selectedFrameId!.isEmpty) {
        if (variants.isNotEmpty) {
          // Notify parent of the default selection
          widget.onFrameSelected(variants.first.id);
        }
      }
    } catch (e) {
      setState(() {
        _availableFrameVariants = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final device = DeviceService.getDeviceById(widget.deviceId);

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_availableFrameVariants.isEmpty || device == null) {
      return const SizedBox.shrink();
    }

    // Sort variants: real frames first, then generic
    final sortedVariants = List<FrameVariantModel>.from(_availableFrameVariants)
      ..sort((a, b) {
        if (a.isGeneric && !b.isGeneric) return 1;
        if (!a.isGeneric && b.isGeneric) return -1;
        return a.name.compareTo(b.name);
      });

    if (widget.direction == Axis.horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: sortedVariants.map((frame) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _FrameVariantCard(
                frame: frame,
                device: device,
                isSelected: widget.selectedFrameId == frame.id,
                onTap: () => widget.onFrameSelected(frame.id),
                showName: widget.showFrameNames,
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return Column(
        children: sortedVariants.map((frame) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FrameVariantCard(
              frame: frame,
              device: device,
              isSelected: widget.selectedFrameId == frame.id,
              onTap: () => widget.onFrameSelected(frame.id),
              showName: widget.showFrameNames,
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
                Stack(
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
                            borderRadius:
                                BorderRadius.circular(device.isTablet ? 8 : 6),
                          ),
                        ),
                      ),
                    ),
                    // Indicator for real vs generic frames
                    if (!frame.isGeneric)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (frame.isGeneric)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.info_outline,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                if (showName) ...[
                  const SizedBox(height: 8),
                  Text(
                    frame.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : null,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Show frame type indicator
                  Text(
                    frame.isGeneric ? 'Generic' : 'Real Frame',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: frame.isGeneric ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
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

    if (frameName.contains('black') ||
        frameName.contains('midnight') ||
        frameName.contains('obsidian') ||
        frameName.contains('space')) {
      return Colors.grey.shade800;
    } else if (frameName.contains('white') ||
        frameName.contains('silver') ||
        frameName.contains('starlight') ||
        frameName.contains('porcelain')) {
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

class FrameDropdown extends StatefulWidget {
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
  State<FrameDropdown> createState() => _FrameDropdownState();
}

class _FrameDropdownState extends State<FrameDropdown> {
  List<FrameVariantModel> _availableFrameVariants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableFrameVariants();
  }

  @override
  void didUpdateWidget(FrameDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deviceId != widget.deviceId) {
      _loadAvailableFrameVariants();
    }
  }

  Future<void> _loadAvailableFrameVariants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final variants =
          await DeviceService.getAvailableFrameVariants(widget.deviceId);
      setState(() {
        _availableFrameVariants = variants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _availableFrameVariants = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_availableFrameVariants.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort variants: real frames first, then generic
    final sortedVariants = List<FrameVariantModel>.from(_availableFrameVariants)
      ..sort((a, b) {
        if (a.isGeneric && !b.isGeneric) return 1;
        if (!a.isGeneric && b.isGeneric) return -1;
        return a.name.compareTo(b.name);
      });

    return DropdownButtonFormField<String>(
      value: widget.selectedFrameId,
      hint: Text(widget.hint ?? 'Select frame'),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: sortedVariants.map((frame) {
        return DropdownMenuItem<String>(
          value: frame.id,
          child: Row(
            children: [
              Icon(
                frame.isGeneric ? Icons.info_outline : Icons.check,
                size: 16,
                color: frame.isGeneric ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${frame.name} (${frame.isGeneric ? 'Generic' : 'Real'})',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          widget.onFrameSelected(value);
        }
      },
    );
  }
}
