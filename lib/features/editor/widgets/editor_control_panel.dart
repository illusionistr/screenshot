import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/models/project_model.dart';
import '../models/editor_state.dart';
import '../providers/editor_provider.dart';
import 'editor_screenshot_list.dart';
import 'screenshot_manager_modal.dart';

class EditorControlPanel extends ConsumerWidget {
  const EditorControlPanel({super.key, required this.project});

  final ProjectModel project;

  // Fixed height for screenshot thumbnails - adjust this value for testing
  static const double kScreenshotListHeight = 200.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProviderFamily(project));
    final editorNotifier = ref.read(editorProviderFamily(project).notifier);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Screenshot selected for layout'),
          backgroundColor: const Color(0xFFE91E63),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
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
        return _buildTextTab(editorState, editorNotifier);
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
        return _buildLayoutsTab(editorState, editorNotifier);
      case EditorTab.background:
        return _buildBackgroundTab(editorState, editorNotifier);
      case EditorTab.template:
        return _buildTemplateTab(editorState, editorNotifier);
    }
  }

  Widget _buildTextTab(EditorState editorState, EditorNotifier editorNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Caption Section
        _SectionTitle(
          title: 'Caption',
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE1E5E9)),
            ),
            child: Column(
              children: [
                TextField(
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                    hintText: 'Enter your caption...',
                  ),
                  onChanged: editorNotifier.updateCaption,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'English',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Font Family Section
        _SectionTitle(
          title: 'Font Family',
          child: _CustomDropdown(
            value: editorState.fontFamily,
            items: const ['Inter', 'Roboto', 'Open Sans', 'Lato', 'Montserrat'],
            onChanged: editorNotifier.updateFontFamily,
          ),
        ),

        const SizedBox(height: 20),

        // Font Size Section
        _SectionTitle(
          title: 'Font Size',
          child: _CustomDropdown(
            value: '${editorState.fontSize.toInt()}',
            items: const ['12', '14', '16', '18', '20', '24', '28', '32'],
            onChanged: (value) =>
                editorNotifier.updateFontSize(double.parse(value)),
          ),
        ),

        const SizedBox(height: 20),

        // Font Weight & Alignment Section
        _SectionTitle(
          title: 'Font Weight',
          child: Row(
            children: [
              // Text alignment buttons
              ...EditorTextAlign.values.map((align) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _IconButton(
                      icon: align.icon,
                      isSelected: editorState.textAlign == align.textAlign,
                      onPressed: () =>
                          editorNotifier.updateTextAlign(align.textAlign),
                    ),
                  )),
              const SizedBox(width: 12),
              // Color picker
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: editorState.textColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE1E5E9)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Apply to All Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: editorNotifier.applyToAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6C757D),
              elevation: 0,
              side: const BorderSide(color: Color(0xFFE1E5E9)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Apply to all',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
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
    return Column(
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

        const SizedBox(height: 24),

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

        // Spacer to push quick actions to bottom
        const Spacer(),

        // Quick Actions
        Row(
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
      ],
    );
  }

  Widget _buildLayoutsTab(
      EditorState editorState, EditorNotifier editorNotifier) {
    return const Center(
      child: Text(
        'Layouts management coming soon...',
        style: TextStyle(
          color: Color(0xFF6C757D),
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildBackgroundTab(
      EditorState editorState, EditorNotifier editorNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Background Tabs
        Row(
          children: [
            _BackgroundTabButton(
              label: 'Color',
              isSelected:
                  editorState.selectedBackgroundTab == BackgroundTab.color,
              onTap: () => editorNotifier
                  .updateSelectedBackgroundTab(BackgroundTab.color),
            ),
            const SizedBox(width: 8),
            _BackgroundTabButton(
              label: 'Gradient',
              isSelected:
                  editorState.selectedBackgroundTab == BackgroundTab.gradient,
              onTap: () => editorNotifier
                  .updateSelectedBackgroundTab(BackgroundTab.gradient),
            ),
            const SizedBox(width: 8),
            _BackgroundTabButton(
              label: 'Image',
              isSelected:
                  editorState.selectedBackgroundTab == BackgroundTab.image,
              onTap: () => editorNotifier
                  .updateSelectedBackgroundTab(BackgroundTab.image),
            ),
          ],
        ),

        const SizedBox(height: 24),

        if (editorState.selectedBackgroundTab == BackgroundTab.gradient) ...[
          // Gradient Controls
          _SectionTitle(
            title: 'Gradient Colors',
            child: Row(
              children: [
                Expanded(
                  child: _ColorInput(
                    label: 'Start Color',
                    color: editorState.gradientStartColor,
                    onColorChanged: editorNotifier.updateGradientStartColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ColorInput(
                    label: 'End Color',
                    color: editorState.gradientEndColor,
                    onColorChanged: editorNotifier.updateGradientEndColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _SectionTitle(
            title: 'Direction',
            child: _CustomDropdown(
              value: editorState.gradientDirection,
              items: const ['vertical', 'horizontal', 'diagonal'],
              onChanged: editorNotifier.updateGradientDirection,
            ),
          ),
        ],

        const Spacer(),

        // Apply to All Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: editorNotifier.applyToAll,
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
              'Apply to all',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateTab(
      EditorState editorState, EditorNotifier editorNotifier) {
    return const Center(
      child: Text(
        'Template management coming soon...',
        style: TextStyle(
          color: Color(0xFF6C757D),
          fontSize: 16,
        ),
      ),
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

class _ColorInput extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const _ColorInput({
    required this.label,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6C757D),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE1E5E9)),
                ),
                child: Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFE1E5E9)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
