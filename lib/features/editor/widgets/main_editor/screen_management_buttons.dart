import 'package:flutter/material.dart';

class ScreenManagementButtons extends StatelessWidget {
  final VoidCallback? onReorder;
  final VoidCallback? onExpand;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final bool showDeleteButton;

  const ScreenManagementButtons({
    super.key,
    this.onReorder,
    this.onExpand,
    this.onDuplicate,
    this.onDelete,
    this.showDeleteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ManagementButton(
            icon: Icons.drag_handle,
            tooltip: 'Reorder',
            onPressed: onReorder,
          ),
          _ManagementButton(
            icon: Icons.fullscreen,
            tooltip: 'Expand',
            onPressed: onExpand,
          ),
          _ManagementButton(
            icon: Icons.copy,
            tooltip: 'Duplicate',
            onPressed: onDuplicate,
          ),
          if (showDeleteButton)
            _ManagementButton(
              icon: Icons.delete,
              tooltip: 'Delete',
              onPressed: onDelete,
              color: Colors.red.shade600,
            ),
        ],
      ),
    );
  }
}

class _ManagementButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  const _ManagementButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: color ?? Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}