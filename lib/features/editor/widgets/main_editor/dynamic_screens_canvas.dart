import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/editor_state.dart';
import '../../providers/editor_provider.dart';
import 'screen_container.dart';
import 'add_screen_button.dart';
import 'screen_expand_modal.dart';

class DynamicScreensCanvas extends ConsumerWidget {
  const DynamicScreensCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    return Container(
      height: 880,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < editorState.screens.length; i++) ...[
              ScreenContainer(
                screenId: editorState.screens[i].id,
                deviceId: editorState.selectedDevice,
                isSelected: editorState.selectedScreenIndex == i,
                isLandscape: editorState.screens[i].isLandscape,
                onTap: () => editorNotifier.selectScreen(i),
                onReorder: () => _showReorderDialog(context, editorNotifier, i),
                onExpand: () => _expandScreen(context, editorState.screens[i], editorState.selectedDevice),
                onDuplicate: () => editorNotifier.duplicateScreen(i),
                onDelete: editorState.screens.length > 1 
                  ? () => _confirmDelete(context, editorNotifier, i)
                  : null,
                showDeleteButton: editorState.screens.length > 1,
              ),
              const SizedBox(width: 16),
            ],
            AddScreenButton(
              deviceId: editorState.selectedDevice,
              currentScreenCount: editorState.screens.length,
              maxScreens: 10,
              onPressed: editorState.screens.length < 10 
                ? () => editorNotifier.addScreen()
                : null,
            ),
          ],
        ),
      ),
    );
  }

  void _expandScreen(BuildContext context, ScreenConfig screen, String deviceId) {
    ScreenExpandModal.show(
      context,
      screenId: screen.id,
      deviceId: deviceId,
      isLandscape: screen.isLandscape,
    );
  }

  void _confirmDelete(BuildContext context, EditorNotifier editorNotifier, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Screen'),
        content: const Text('Are you sure you want to delete this screen layout? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              editorNotifier.deleteScreen(index);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showReorderDialog(BuildContext context, EditorNotifier editorNotifier, int currentIndex) {
    showDialog(
      context: context,
      builder: (context) => _ReorderDialog(
        currentIndex: currentIndex,
        onReorder: (newIndex) {
          if (newIndex != currentIndex) {
            editorNotifier.reorderScreens(currentIndex, newIndex);
          }
        },
      ),
    );
  }
}

class _ReorderDialog extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onReorder;

  const _ReorderDialog({
    required this.currentIndex,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final screenCount = editorState.screens.length;

    return AlertDialog(
      title: const Text('Reorder Screen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Move screen from position ${currentIndex + 1} to:'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: List.generate(screenCount, (index) {
              final isCurrentPosition = index == currentIndex;
              return FilterChip(
                label: Text('${index + 1}'),
                selected: isCurrentPosition,
                onSelected: isCurrentPosition ? null : (selected) {
                  if (selected) {
                    Navigator.of(context).pop();
                    onReorder(index);
                  }
                },
                backgroundColor: isCurrentPosition ? Colors.grey.shade300 : null,
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}