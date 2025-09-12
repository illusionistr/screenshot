import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/models/project_model.dart';
import '../../constants/layouts_data.dart';
import '../../models/editor_state.dart';
import '../../models/layout_models.dart';
import '../../providers/editor_provider.dart';
import 'layout_controls.dart';
import 'layout_preview_card.dart';

class LayoutTabContent extends ConsumerWidget {
  const LayoutTabContent({
    super.key,
    required this.project,
  });

  final ProjectModel project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorProv = editorByProjectIdProvider(project.id);
    final editorState = ref.watch(editorProv);
    final editorNotifier = ref.read(editorProv.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(),

        const SizedBox(height: 24),

        // Layout Controls
        LayoutControls(
          selectedFrameVariant: editorState.selectedFrameVariant,
          deviceId: editorState.selectedDevice,
          onFrameVariantChanged: (variant) {
            editorNotifier.updateSelectedFrameVariant(variant);
          },
          projectId: project.id,
        ),

        const SizedBox(height: 24),

        // Layout Grid
        Expanded(
          child: _buildLayoutGrid(editorState, editorNotifier),
        ),

        const SizedBox(height: 16),

        // Apply to All Button (since individual application is now immediate)
        _buildApplyToAllButton(editorState, editorNotifier),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Device Layout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select a layout to apply immediately to the current screen',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6C757D),
          ),
        ),
      ],
    );
  }

  Widget _buildLayoutGrid(
      EditorState editorState, EditorNotifier editorNotifier) {
    final categories = LayoutsData.getCategories();

    return ListView.builder(
      padding: const EdgeInsets.only(right: 8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final layouts = LayoutsData.getLayoutsByCategory(category);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF495057),
                ),
              ),
            ),

            // Layout Grid for this category
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: layouts.length,
              itemBuilder: (context, layoutIndex) {
                final layout = layouts[layoutIndex];
                // Check if this layout is applied to the current screen
                final currentScreenLayoutId =
                    editorNotifier.getCurrentScreenLayoutId();
                final isSelected = currentScreenLayoutId == layout.config.id;

                return LayoutPreviewCard(
                  layout: layout,
                  isSelected: isSelected,
                  onTap: () {
                    // Apply layout immediately to current screen
                    if (editorState.selectedScreenIndex != null) {
                      editorNotifier
                          .applyLayoutToCurrentScreen(layout.config.id);

                      // Show feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Applied "${layout.config.name}" to Screen ${editorState.selectedScreenIndex! + 1}'),
                          backgroundColor: const Color(0xFFE91E63),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          duration: const Duration(seconds: 2),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),

            if (index < categories.length - 1) const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildApplyToAllButton(
      EditorState editorState, EditorNotifier editorNotifier) {
    final currentScreenLayoutId = editorNotifier.getCurrentScreenLayoutId();
    final currentLayout = currentScreenLayoutId != null
        ? LayoutsData.getLayoutById(currentScreenLayoutId)
        : null;

    return Builder(
      builder: (context) => SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: currentLayout != null && editorState.screens.isNotEmpty
              ? () => _showApplyToAllConfirmation(
                  context, editorNotifier, editorState, currentLayout)
              : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFE91E63),
            side: const BorderSide(color: Color(0xFFE91E63)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            currentLayout != null
                ? 'Apply "${currentLayout.config.name}" to all ${editorState.screens.length} screens'
                : 'Select a layout first',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showApplyToAllConfirmation(
    BuildContext context,
    EditorNotifier editorNotifier,
    EditorState editorState,
    LayoutModel currentLayout,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Layout to All Screens'),
        content: Text(
          'This will apply the "${currentLayout.config.name}" layout to all ${editorState.screens.length} screens.\n\n⚠️ This will override existing text positioning and grouping on all screens.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              editorNotifier.applyLayoutToAllScreens(currentLayout.config.id);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Applied "${currentLayout.config.name}" to all ${editorState.screens.length} screens'),
                  backgroundColor: const Color(0xFFE91E63),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 3),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply to All'),
          ),
        ],
      ),
    );
  }
}
