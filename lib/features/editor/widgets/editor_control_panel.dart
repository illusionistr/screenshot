import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/models/project_model.dart';
import '../../shared/models/screenshot_model.dart';
import '../../shared/widgets/scrollable_tab_container.dart';
import '../models/background_models.dart';
import '../models/editor_state.dart';
import '../providers/editor_provider.dart';
import 'background/gradient_tab.dart';
import 'background/image_background_tab.dart';
import 'background/solid_color_tab.dart';
import 'editor_screenshot_list.dart';
import 'layout/layout_tab_content.dart';
import 'screenshot_manager_modal.dart';
import 'text/text_tab_content.dart';

class EditorControlPanel extends ConsumerWidget {
  const EditorControlPanel({super.key, required this.project});

  final ProjectModel project;

  // Fixed height for screenshot thumbnails - adjust this value for testing
  static const double kScreenshotListHeight = 200.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorProv = editorByProjectIdProvider(project.id);
    final editorState = ref.watch(editorProv);
    final editorNotifier = ref.read(editorProv.notifier);

    // Helper methods defined within build context
    String buildFilterText(EditorState editorState) {
      final parts = <String>[];

      if (editorState.selectedDevice.isNotEmpty) {
        try {
          final device = editorState.availableDevices
              .firstWhere((d) => d.id == editorState.selectedDevice);
          parts.add(device.name);
        } catch (e) {
          parts.add(editorState.selectedDevice);
        }
      }

      if (editorState.selectedLanguage.isNotEmpty) {
        parts.add(editorState.selectedLanguage.toUpperCase());
      }

      return parts.join(' • ');
    }

    void handleScreenshotSelection(
        dynamic screenshot, EditorNotifier editorNotifier) {
      // Get the current state instead of using the captured one
      final currentState = editorNotifier.state;

      if (screenshot is ScreenshotModel &&
          currentState.selectedScreenIndex != null) {
        // Assign screenshot to currently selected screen (same pattern as background assignment)
        editorNotifier.assignScreenshotToSelectedScreen(screenshot.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Screenshot assigned to Screen ${currentState.selectedScreenIndex! + 1}'),
            backgroundColor: const Color(0xFFE91E63),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a screen first'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }

    void showScreenshotOptions(dynamic screenshot) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Screenshot'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open screenshot editor
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Duplicate'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Duplicate screenshot
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Download screenshot
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Delete screenshot with confirmation
                },
              ),
            ],
          ),
        ),
      );
    }

    void handleScreenshotReorder(
        int oldIndex, int newIndex, EditorNotifier editorNotifier) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Screenshot moved from position ${oldIndex + 1} to ${newIndex + 1}'),
          backgroundColor: const Color(0xFFE91E63),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    void showScreenshotManagerModal() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ScreenshotManagerModal(
          project: project,
          onClose: () => Navigator.of(context).pop(),
        ),
      );
    }

    return Container(
      width: 420,
      height: double.infinity,
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          // Tab Navigation
          Container(
            height: 60,
            color: Colors.white,
            child: Row(
              children: [
                _TabButton(
                  icon: Icons.text_fields,
                  label: 'A Text',
                  isSelected: editorState.selectedTab == EditorTab.text,
                  onTap: () => editorNotifier.updateSelectedTab(EditorTab.text),
                ),
                _TabButton(
                  icon: Icons.upload,
                  label: 'Uploads',
                  isSelected: editorState.selectedTab == EditorTab.uploads,
                  onTap: () =>
                      editorNotifier.updateSelectedTab(EditorTab.uploads),
                ),
                _TabButton(
                  icon: Icons.grid_on,
                  label: 'Layouts',
                  isSelected: editorState.selectedTab == EditorTab.layouts,
                  onTap: () =>
                      editorNotifier.updateSelectedTab(EditorTab.layouts),
                ),
                _TabButton(
                  icon: Icons.landscape,
                  label: 'Background',
                  isSelected: editorState.selectedTab == EditorTab.background,
                  onTap: () =>
                      editorNotifier.updateSelectedTab(EditorTab.background),
                ),
                _TabButton(
                  icon: Icons.description,
                  label: 'Template',
                  isSelected: editorState.selectedTab == EditorTab.template,
                  onTap: () =>
                      editorNotifier.updateSelectedTab(EditorTab.template),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildTabContent(
                  editorState,
                  editorNotifier,
                  context,
                  ref,
                  buildFilterText,
                  handleScreenshotSelection,
                  showScreenshotOptions,
                  handleScreenshotReorder,
                  showScreenshotManagerModal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
      EditorState editorState,
      EditorNotifier editorNotifier,
      BuildContext context,
      WidgetRef ref,
      String Function(EditorState) buildFilterText,
      void Function(dynamic, EditorNotifier) handleScreenshotSelection,
      void Function(dynamic) showScreenshotOptions,
      void Function(int, int, EditorNotifier) handleScreenshotReorder,
      void Function() showScreenshotManagerModal) {
    switch (editorState.selectedTab) {
      case EditorTab.text:
        return TextTabContent(project: project);
      case EditorTab.uploads:
        return _buildUploadsTab(
            editorState,
            editorNotifier,
            context,
            ref,
            buildFilterText,
            handleScreenshotSelection,
            showScreenshotOptions,
            handleScreenshotReorder,
            showScreenshotManagerModal);
      case EditorTab.layouts:
        return LayoutTabContent(project: project);
      case EditorTab.background:
        return _buildBackgroundTab(editorState, editorNotifier);
      case EditorTab.template:
        return _buildTemplateTab(editorState, editorNotifier);
    }
  }

  Widget _buildUploadsTab(
      EditorState editorState,
      EditorNotifier editorNotifier,
      BuildContext context,
      WidgetRef ref,
      String Function(EditorState) buildFilterText,
      void Function(dynamic, EditorNotifier) handleScreenshotSelection,
      void Function(dynamic) showScreenshotOptions,
      void Function(int, int, EditorNotifier) handleScreenshotReorder,
      void Function() showScreenshotManagerModal) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Manage App Screens Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => showScreenshotManagerModal(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Manage App Screens',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Upload, organize, and manage your app screenshots',
            style: TextStyle(
              color: Color(0xFF6C757D),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 16),

          // Screen Selection Status
          _buildScreenSelectionStatus(editorState, ref),

          const SizedBox(height: 16),

          // Horizontal Screenshot List
          EditorScreenshotList(
            project: project,
            height: kScreenshotListHeight +
                75, // Fixed height + space for header/padding
            onScreenshotTap: (screenshot) {
              // Handle screenshot selection for layout
              handleScreenshotSelection(screenshot, editorNotifier);
            },
            onScreenshotLongPress: (screenshot) {
              // Show screenshot options menu
              showScreenshotOptions(screenshot);
            },
            onScreenshotReorder: (oldIndex, newIndex) {
              // Handle screenshot reordering
              handleScreenshotReorder(oldIndex, newIndex, editorNotifier);
            },
          ),

          const SizedBox(height: 24),

          // Quick Actions (moved to bottom but not using Spacer to avoid overflow)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => showScreenshotManagerModal(),
                    icon: const Icon(Icons.add_photo_alternate, size: 16),
                    label: const Text('Upload'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE91E63),
                      side: const BorderSide(color: Color(0xFFE91E63)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement batch operations
                    },
                    icon: const Icon(Icons.select_all, size: 16),
                    label: const Text('Select All'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6C757D),
                      side: const BorderSide(color: Color(0xFFE1E5E9)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundTab(
      EditorState editorState, EditorNotifier editorNotifier) {
    return ScrollableTabContainerWithSticky(
      padding: const EdgeInsets.all(20),
      fixedHeader: Row(
        children: [
          _BackgroundTabButton(
            label: 'Color',
            isSelected:
                editorState.selectedBackgroundTab == BackgroundTab.color,
            onTap: () {
              editorNotifier.updateSelectedBackgroundTab(BackgroundTab.color);
              editorNotifier.updateBackgroundType(BackgroundType.solid);
            },
          ),
          const SizedBox(width: 8),
          _BackgroundTabButton(
            label: 'Gradient',
            isSelected:
                editorState.selectedBackgroundTab == BackgroundTab.gradient,
            onTap: () {
              editorNotifier
                  .updateSelectedBackgroundTab(BackgroundTab.gradient);
              editorNotifier.updateBackgroundType(BackgroundType.gradient);
            },
          ),
          const SizedBox(width: 8),
          _BackgroundTabButton(
            label: 'Image',
            isSelected:
                editorState.selectedBackgroundTab == BackgroundTab.image,
            onTap: () {
              editorNotifier.updateSelectedBackgroundTab(BackgroundTab.image);
              editorNotifier.updateBackgroundType(BackgroundType.image);
            },
          ),
        ],
      ),
      scrollableContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Tab Content
          _buildBackgroundTabContent(editorState, editorNotifier),
        ],
      ),
      fixedFooter: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: editorNotifier.applyBackgroundToAllScreens,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFE91E63),
            elevation: 0,
            side: const BorderSide(color: Color(0xFFE91E63)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Apply to all screens',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundTabContent(
      EditorState editorState, EditorNotifier editorNotifier) {
    switch (editorState.selectedBackgroundTab) {
      case BackgroundTab.color:
        return SolidColorTab(
          currentColor: editorNotifier.getCurrentScreenSolidColor(),
          onColorChanged: editorNotifier.updateSolidBackgroundColor,
        );
      case BackgroundTab.gradient:
        return GradientTab(
          startColor: editorState.gradientStartColor,
          endColor: editorState.gradientEndColor,
          direction: editorState.gradientDirection,
          onStartColorChanged:
              editorNotifier.updateGradientStartColorWithPreview,
          onEndColorChanged: editorNotifier.updateGradientEndColorWithPreview,
          onDirectionChanged: editorNotifier.updateGradientDirectionWithPreview,
        );
      case BackgroundTab.image:
        return ImageBackgroundTab(
          selectedImageId: editorNotifier.getCurrentScreenImageId(),
          onImageSelected: editorNotifier.selectBackgroundImage,
        );
    }
  }

  Widget _buildScreenSelectionStatus(EditorState editorState, WidgetRef ref) {
    final selectedScreenIndex = editorState.selectedScreenIndex;

    if (selectedScreenIndex == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 20,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Select a screen in the canvas to assign screenshots',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Check if the selected screen already has a screenshot assigned
    final currentScreen = editorState.screens[selectedScreenIndex];
    final hasScreenshot = currentScreen.assignedScreenshotId != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasScreenshot ? Colors.blue.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasScreenshot ? Colors.blue.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasScreenshot ? Icons.photo_outlined : Icons.tab,
            size: 20,
            color:
                hasScreenshot ? Colors.blue.shade600 : Colors.orange.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasScreenshot
                  ? 'Screen ${selectedScreenIndex + 1} has screenshot - tap another to replace'
                  : 'Screen ${selectedScreenIndex + 1} selected - tap a screenshot to assign it',
              style: TextStyle(
                color: hasScreenshot
                    ? Colors.blue.shade800
                    : Colors.orange.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateTab(
      EditorState editorState, EditorNotifier editorNotifier) {
    return ScrollableTabContainer.unified(
      children: [
        const Center(
          child: Text(
            'Template management coming soon...',
            style: TextStyle(
              color: Color(0xFF6C757D),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionTitle({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF495057),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _CustomDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  const _IconButton({
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF007BFF) : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE1E5E9)),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : const Color(0xFF6C757D),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF333333) : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF333333)
                    : const Color(0xFFE1E5E9),
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : const Color(0xFF6C757D),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF6C757D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BackgroundTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF333333) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF6C757D),
            decoration: isSelected ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }
}
