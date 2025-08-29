import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/models/project_model.dart';
import '../models/editor_state.dart';
import '../providers/editor_provider.dart';

class ScreenshotGrid extends ConsumerWidget {
  const ScreenshotGrid({super.key, required this.project});
  
  final ProjectModel project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorProv = editorByProjectIdProvider(project.id);
    final editorState = ref.watch(editorProv);
    final editorNotifier = ref.read(editorProv.notifier);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: ReorderableListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: editorState.screenshots.length,
          onReorder: (oldIndex, newIndex) {
            // Handle reordering of screenshots
            editorNotifier.reorderScreenshots(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final screenshot = editorState.screenshots[index];
            return Padding(
              key: ValueKey(screenshot.id),
              padding: EdgeInsets.only(
                right: index < editorState.screenshots.length - 1 ? 32.0 : 0,
              ),
              child: ScreenshotCard(
                screenshot: screenshot,
                index: index,
              ),
            );
          },
        ),
      ),
    );
  }
}

class ScreenshotCard extends StatelessWidget {
  final ScreenshotItem screenshot;
  final int index;

  const ScreenshotCard({
    super.key,
    required this.screenshot,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320, // Fixed width for consistent card sizing
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                screenshot.backgroundColor,
                screenshot.gradientColor,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title text
                    Text(
                      screenshot.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    if (screenshot.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        screenshot.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                    const Spacer(),

                    // Full device frame with screenshot
                    Center(
                      child: Container(
                        width: 240,
                        height: 480,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Stack(
                                children: [
                                  // Status bar
                                  Container(
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2E7D32),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(28),
                                        topRight: Radius.circular(28),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Text(
                                            '9:41',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Row(
                                            children: [
                                              Icon(Icons.signal_cellular_alt,
                                                  color: Colors.white,
                                                  size: 12),
                                              SizedBox(width: 4),
                                              Icon(Icons.wifi,
                                                  color: Colors.white,
                                                  size: 12),
                                              SizedBox(width: 4),
                                              Icon(Icons.battery_full,
                                                  color: Colors.white,
                                                  size: 12),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Mock app content
                                  Positioned(
                                    top: 28,
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: _buildMockAppContent(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons overlay
              Positioned(
                bottom: 20,
                right: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionButton(
                      icon: Icons.drag_handle,
                      onPressed: () {},
                      tooltip: 'Drag to reorder',
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.open_in_full,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.content_copy,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.delete_outline,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMockAppContent() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // Header
          Container(
            height: 60,
            color: const Color(0xFF2E7D32),
            child: const Center(
              child: Text(
                'Índice Alfabético',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Search bar
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey, size: 16),
                SizedBox(width: 8),
                Text(
                  'Pesquisar...',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // List items
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'D',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lista item',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Descrição do item',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: Colors.grey, size: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 16,
          color: const Color(0xFF6C757D),
        ),
        onPressed: onPressed,
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    return button;
  }
}
