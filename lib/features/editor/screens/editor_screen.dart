import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/editor_provider.dart';
import '../providers/screen_provider.dart';
import '../widgets/top_navigation_bar.dart';
import '../widgets/screen_carousel.dart';
import '../widgets/settings_panel.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEditor();
    });
  }

  void _loadEditor() {
    final editorProvider = Provider.of<EditorProvider>(context, listen: false);
    final screenProvider = Provider.of<ScreenProvider>(context, listen: false);
    
    // Load project first
    editorProvider.loadProject(widget.projectId).then((_) {
      // Then load screens for this project
      screenProvider.loadProjectScreens(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<EditorProvider, ScreenProvider>(
      builder: (context, editorProvider, screenProvider, child) {
        if (editorProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (editorProvider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${editorProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      editorProvider.clearError();
                      _loadEditor();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!editorProvider.hasProject) {
          return const Scaffold(
            body: Center(
              child: Text('Project not found'),
            ),
          );
        }

        return Scaffold(
          body: Column(
            children: [
              // Top Navigation Bar
              const TopNavigationBar(),
              
              // Main content area
              Expanded(
                child: Row(
                  children: [
                    // Left side - Screen Carousel (70%)
                    Expanded(
                      flex: 7,
                      child: Container(
                        color: Colors.grey[50],
                        child: const ScreenCarousel(),
                      ),
                    ),
                    
                    // Right side - Settings Panel (30%)
                    Expanded(
                      flex: 3,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 300),
                        child: const SettingsPanel(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
