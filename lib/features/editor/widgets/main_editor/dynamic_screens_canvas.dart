import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/models/project_model.dart';
import '../../../projects/providers/upload_provider.dart';
import '../../../shared/models/screenshot_model.dart';
import '../../models/editor_state.dart';
import '../../providers/editor_provider.dart';
import 'add_screen_button.dart';
import 'horizontal_reorderable_row.dart';
import 'screen_container.dart';
import 'screen_expand_modal.dart';

class DynamicScreensCanvas extends ConsumerWidget {
  final ProjectModel? project;

  const DynamicScreensCanvas({super.key, this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(
        project != null ? editorProviderFamily(project) : editorProvider);
    final editorNotifier = ref.read(project != null
        ? editorProviderFamily(project).notifier
        : editorProvider.notifier);

    // Watch the project screenshots to get ScreenshotModel objects
    final screenshotsAsync = project != null
        ? ref.watch(projectScreenshotsProvider(project!.id))
        : const AsyncValue<
            Map<String, Map<String, List<ScreenshotModel>>>>.data({});

    // Helper function to get ScreenshotModel by ID
    ScreenshotModel? getScreenshotById(String screenshotId) {
      return screenshotsAsync.when(
        data: (screenshots) {
          for (final languageEntry in screenshots.entries) {
            for (final deviceEntry in languageEntry.value.entries) {
              for (final screenshot in deviceEntry.value) {
                if (screenshot.id == screenshotId) {
                  return screenshot;
                }
              }
            }
          }
          return null;
        },
        loading: () => null,
        error: (_, __) => null,
      );
    }

    return SizedBox(
      height: 880,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            HorizontalReorderableRow(
              spacing: 16,
              onReorder: (oldIndex, newIndex) {
                editorNotifier.reorderScreens(oldIndex, newIndex);
              },
              children: [
                for (int i = 0; i < editorState.screens.length; i++)
                  ScreenContainer(
                    key: ValueKey(editorState.screens[i].id),
                    screenId: editorState.screens[i].id,
                    deviceId: editorState.selectedDevice,
                    isSelected: editorState.selectedScreenIndex == i,
                    isLandscape: editorState.screens[i].isLandscape,
                    background: editorState.screens[i].background,
                    textConfig: editorState.screens[i].textConfig,
                    assignedScreenshot:
                        editorState.screens[i].assignedScreenshotId != null
                            ? getScreenshotById(
                                editorState.screens[i].assignedScreenshotId!)
                            : null,
                    layoutId: editorState.screens[i].layoutId ??
                        editorState.selectedLayoutId,
                    frameVariant: editorState.selectedFrameVariant,
                    project: project,
                    onTap: () => editorNotifier.selectScreen(i),
                    onReorder: null, // Remove individual reorder callback
                    onExpand: () => _expandScreen(context,
                        editorState.screens[i], editorState.selectedDevice),
                    onDuplicate: () => editorNotifier.duplicateScreen(i),
                    onDelete: editorState.screens.length > 1
                        ? () => _confirmDelete(context, editorNotifier, i)
                        : null,
                    showDeleteButton: editorState.screens.length > 1,
                  ),
              ],
            ),
            const SizedBox(width: 16),
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

  void _expandScreen(
      BuildContext context, ScreenConfig screen, String deviceId) {
    ScreenExpandModal.show(
      context,
      screenId: screen.id,
      deviceId: deviceId,
      isLandscape: screen.isLandscape,
    );
  }

  void _confirmDelete(
      BuildContext context, EditorNotifier editorNotifier, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Screen'),
        content: const Text(
            'Are you sure you want to delete this screen layout? This action cannot be undone.'),
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
}
