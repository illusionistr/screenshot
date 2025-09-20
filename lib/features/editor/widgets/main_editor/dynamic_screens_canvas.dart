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
    final editorProv = project != null ? editorByProjectIdProvider(project!.id) : editorProvider;
    final editorNotifier = ref.read(editorProv.notifier);

    // Watch only stable, low-churn slices to avoid full rebuilds while typing
    final screenIds = ref.watch(
      editorProv.select((s) => s.screens.map((e) => e.id).toList()),
    );
    final selectedScreenIndex = ref.watch(
      editorProv.select((s) => s.selectedScreenIndex),
    );
    final selectedDevice = ref.watch(
      editorProv.select((s) => s.selectedDevice),
    );
    final frameVariant = ref.watch(
      editorProv.select((s) => s.selectedFrameVariant),
    );

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
                for (int i = 0; i < screenIds.length; i++)
                  Consumer(builder: (context, ref, _) {
                    final screen = ref.watch(
                      editorProv.select((s) => s.screens[i]),
                    );
                    final isSelected = selectedScreenIndex == i;
                    final assigned = screen.assignedScreenshotId != null
                        ? getScreenshotById(screen.assignedScreenshotId!)
                        : null;
                    return ScreenContainer(
                      key: ValueKey(screen.id),
                      screenId: screen.id,
                      deviceId: selectedDevice,
                      isSelected: isSelected,
                      isLandscape: screen.isLandscape,
                      background: screen.background,
                      textConfig: screen.textConfig,
                      assignedScreenshot: assigned,
                      layoutId: screen.layoutId,
                      customSettings: screen.customSettings,
                      frameVariant: frameVariant,
                      project: project,
                      onTap: () => editorNotifier.selectScreen(i),
                      onReorder: null,
                      onExpand: () => _expandScreen(context, screen, selectedDevice),
                      onDuplicate: () => editorNotifier.duplicateScreen(i),
                      onDelete: screenIds.length > 1
                          ? () => _confirmDelete(context, editorNotifier, i)
                          : null,
                      showDeleteButton: screenIds.length > 1,
                    );
                  }),
              ],
            ),
            const SizedBox(width: 16),
            AddScreenButton(
              deviceId: selectedDevice,
              currentScreenCount: screenIds.length,
              maxScreens: 10,
              onPressed: screenIds.length < 10
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
