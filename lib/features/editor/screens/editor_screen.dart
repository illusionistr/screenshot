import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/loading_widget.dart';
import '../../projects/providers/project_provider.dart';
import '../widgets/editor_control_panel.dart';
import '../widgets/editor_top_bar.dart';
import '../widgets/main_editor/dual_scroll_editor.dart';

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsState = ref.watch(projectsStreamProvider);
    
    return projectsState.when(
      data: (projects) {
        // Find the project with the matching ID
        final project = projects.where((p) => p.id == projectId).firstOrNull;
        
        if (project == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Project Not Found'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/dashboard'),
              ),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Project not found or you don\'t have access to it.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
        
        return _buildEditor(context, ref, project);
      },
      loading: () => const Scaffold(
        body: LoadingWidget(),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dashboard'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading project: $error',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEditor(BuildContext context, WidgetRef ref, dynamic project) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: EditorTopBar(project: project),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left control panel
          EditorControlPanel(project: project),

          // Main content area
          Expanded(
            child: DualScrollEditor(project: project),
          ),
        ],
      ),
    );
  }
}
