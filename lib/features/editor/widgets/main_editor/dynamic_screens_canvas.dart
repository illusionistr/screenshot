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
    final editorProv = project != null
        ? editorByProjectIdProvider(project!.id)
        : editorProvider;
    final editorNotifier = ref.read(editorProv.notifier);

    // Watch only stable, low-churn slices to avoid full rebuilds while typing
    final screenCount = ref.watch(
      editorProv.select((s) => s.screens.length),
    );
    final screenIds = [
      for (int i = 0; i < screenCount; i++)
        ref.watch(editorProv.select((s) => s.screens[i].id)),
    ];
    final selectedScreenIndex = ref.watch(
      editorProv.select((s) => s.selectedScreenIndex),
    );
    final selectedDevice = ref.watch(
      editorProv.select((s) => s.selectedDevice),
    );
    final frameVariant = ref.watch(
      editorProv.select((s) => s.selectedFrameVariant),
    );
    final currentLanguage = ref.watch(
      editorProv.select((s) => s.selectedLanguage),
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
                  _OptimizedScreenContainer(
                    key: ValueKey(screenIds[i]),
                    screenIndex: i,
                    isSelected: selectedScreenIndex == i,
                    selectedDevice: selectedDevice,
                    frameVariant: frameVariant,
                    currentLanguage: currentLanguage,
                    project: project,
                    editorProv: editorProv,
                    editorNotifier: editorNotifier,
                    screenCount: screenIds.length,
                    getScreenshotById: getScreenshotById,
                    onExpand: (screen) =>
                        _expandScreen(context, screen, selectedDevice),
                  ),
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

/// Optimized wrapper for ScreenContainer that watches only necessary screen properties
class _OptimizedScreenContainer extends ConsumerWidget {
  final int screenIndex;
  final bool isSelected;
  final String selectedDevice;
  final String frameVariant;
  final String currentLanguage;
  final ProjectModel? project;
  final ProviderBase editorProv;
  final EditorNotifier editorNotifier;
  final int screenCount;
  final ScreenshotModel? Function(String) getScreenshotById;
  final void Function(ScreenConfig) onExpand;

  const _OptimizedScreenContainer({
    super.key,
    required this.screenIndex,
    required this.isSelected,
    required this.selectedDevice,
    required this.frameVariant,
    required this.currentLanguage,
    required this.project,
    required this.editorProv,
    required this.editorNotifier,
    required this.screenCount,
    required this.getScreenshotById,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only the specific screen data with deep equality check
    // This should prevent rebuilds when other screens change but this one doesn't
    final screen = ref.watch(
      editorProv.select((s) => s.screens[screenIndex]),
    );

    // Get screenshot for current language and device (language+device-aware lookup)
    final screenshotId = screen.getScreenshotForLanguageAndDevice(currentLanguage, selectedDevice);
    final assignedScreenshot = screenshotId != null
        ? getScreenshotById(screenshotId)
        : null;

    return ScreenContainer(
      screenId: screen.id,
      screenIndex: screenIndex,
      deviceId: selectedDevice,
      isSelected: isSelected,
      isLandscape: screen.isLandscape,
      background: screen.background,
      textConfig: screen.textConfig,
      assignedScreenshot: assignedScreenshot,
      layoutId: screen.layoutId,
      customSettings: screen.customSettings,
      frameVariant: frameVariant,
      currentLanguage: currentLanguage,
      project: project,
      onTap: () => editorNotifier.selectScreen(screenIndex),
      onReorder: null,
      onExpand: () => onExpand(screen),
      onDuplicate: () => editorNotifier.duplicateScreen(screenIndex),
      onDelete: screenCount > 1
          ? () => _confirmDelete(context, editorNotifier, screenIndex)
          : null,
      showDeleteButton: screenCount > 1,
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
