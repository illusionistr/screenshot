import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/editor_provider.dart';
import '../providers/screen_provider.dart';
import 'screen_thumbnail.dart';

class ScreenCarousel extends StatelessWidget {
  const ScreenCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<EditorProvider, ScreenProvider>(
      builder: (context, editorProvider, screenProvider, child) {
        final screens = screenProvider.screens;
        final selectedIndex = editorProvider.selectedScreenIndex;
        final projectId = editorProvider.currentProject?.id;

        if (projectId == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (screenProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (screenProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${screenProvider.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    screenProvider.clearError();
                    screenProvider.loadProjectScreens(projectId);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel area
            Container(
              height: 280,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Left arrow
                  IconButton(
                    onPressed: selectedIndex > 0
                        ? () => editorProvider.selectPreviousScreen()
                        : null,
                    icon: const Icon(Icons.arrow_back_ios),
                    iconSize: 20,
                  ),
                  
                  // Thumbnails
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          // Existing screens
                          ...screens.asMap().entries.map((entry) {
                            final index = entry.key;
                            final screen = entry.value;
                            
                            return ScreenThumbnail(
                              screen: screen,
                              isSelected: index == selectedIndex,
                              screenNumber: index + 1,
                              onTap: () => editorProvider.selectScreen(index),
                            );
                          }),
                          
                          // Add new screen button
                          if (screens.length < 10)
                            GestureDetector(
                              onTap: () => screenProvider.addScreen(projectId),
                              child: Container(
                                width: 120,
                                height: 200,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[400]!,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[50],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      size: 40,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add Screen',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Right arrow
                  IconButton(
                    onPressed: selectedIndex < screens.length - 1
                        ? () => editorProvider.selectNextScreen()
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
            
            // Bottom info area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected screen info
                  if (screens.isNotEmpty && selectedIndex < screens.length)
                    Row(
                      children: [
                        Text(
                          'Screen #${selectedIndex + 1}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Edit icon (placeholder)
                        IconButton(
                          onPressed: () {
                            // TODO: Implement edit screen name
                          },
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'Edit screen name',
                        ),
                        
                        // Delete icon
                        if (screens.length > 1)
                          IconButton(
                            onPressed: () => _showDeleteConfirmation(
                              context,
                              screenProvider,
                              editorProvider,
                              screens[selectedIndex].id,
                            ),
                            icon: const Icon(Icons.delete, size: 20),
                            tooltip: 'Delete screen',
                          ),
                      ],
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Replace screenshots button
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Implement screenshot replacement
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Replace and manage screenshots'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ScreenProvider screenProvider,
    EditorProvider editorProvider,
    String screenId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Screen'),
        content: const Text(
          'Are you sure you want to delete this screen? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              
              // Adjust selected index if necessary
              final screens = screenProvider.screens;
              final currentIndex = editorProvider.selectedScreenIndex;
              
              if (currentIndex >= screens.length - 1 && currentIndex > 0) {
                editorProvider.selectScreen(currentIndex - 1);
              }
              
              screenProvider.deleteScreen(screenId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}