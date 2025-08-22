import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/models/project_model.dart';
import '../../constants/layouts_data.dart';
import '../../models/editor_state.dart';
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
    final editorState = ref.watch(editorProviderFamily(project));
    final editorNotifier = ref.read(editorProviderFamily(project).notifier);

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
        ),

        const SizedBox(height: 24),

        // Layout Grid
        Expanded(
          child: _buildLayoutGrid(editorState, editorNotifier),
        ),

        const SizedBox(height: 16),

        // Apply Buttons
        _buildApplyButtons(editorState, editorNotifier),
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
          'Select a layout below to change in your screenshot',
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
                final isSelected =
                    editorState.selectedLayoutId == layout.config.id;

                return LayoutPreviewCard(
                  layout: layout,
                  isSelected: isSelected,
                  onTap: () {
                    editorNotifier.updateSelectedLayout(layout.config.id);
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

  Widget _buildApplyButtons(
      EditorState editorState, EditorNotifier editorNotifier) {
    return Builder(
      builder: (context) => Column(
        children: [
          // Apply to Current Screen
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: editorState.selectedScreenIndex != null
                  ? () => editorNotifier
                      .applyLayoutToCurrentScreen(editorState.selectedLayoutId)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                editorState.selectedScreenIndex != null
                    ? 'Apply to Screen ${editorState.selectedScreenIndex! + 1}'
                    : 'Select a screen first',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Apply to All Screens
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: editorState.screens.isNotEmpty
                  ? () => _showApplyToAllConfirmation(
                      context, editorNotifier, editorState)
                  : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE91E63),
                side: const BorderSide(color: Color(0xFFE91E63)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Apply to all screens',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApplyToAllConfirmation(
    BuildContext context,
    EditorNotifier editorNotifier,
    EditorState editorState,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Layout to All Screens'),
        content: Text(
          'This will apply the "${LayoutsData.getLayoutById(editorState.selectedLayoutId)?.config.name ?? 'selected'}" layout to all ${editorState.screens.length} screens. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              editorNotifier
                  .applyLayoutToAllScreens(editorState.selectedLayoutId);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Layout applied to all screens'),
                  backgroundColor: Color(0xFFE91E63),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
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
